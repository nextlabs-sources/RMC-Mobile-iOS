//
//  NXTokenManager.m
//  nxrmc
//
//  Created by nextlabs on 6/22/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLTokenManager.h"

#import "NXLKeyChain.h"

#import "NXLSDKDef.h"
#import "NXLEncryptToken.h"
#import "NXLDecryptTokenAPI.h"
#import "NXLMemshipAPI.h"
#import "NXLOpenSSL.h"
#import "NSString+Codec.h"
#import "NXLProfile.h"
#import "NXLSDKDef.h"


#define kCacheMinCount 1

#define kEncrypKeyChainKey (@"EncryptTokens")


NXLTokenManager *nxlSharedInstance = nil;

NSLock* nxlKeyChainLock = nil;
@interface NXLDecryptionTokenCache : NSObject

@property (nonatomic, strong) NSString* DUID;
@property (nonatomic, strong) NSString* agreement;
@property (nonatomic, strong) NSString* ml;
@property (nonatomic, strong) NSString* owner;
@property (nonatomic, strong) NSString* aeshexkey;

@end

@implementation NXLDecryptionTokenCache



- (id) initWith: (NSString*) duid agreement: (NSString*)agreement ml:(NSString*)ml owner:(NSString*)owner aeshexkey: (NSString*)aeshexkey
{
    if (self = [super init]) {
        self.DUID = duid;
        self.agreement = agreement;
        self.ml = ml;
        self.owner = owner;
        self.aeshexkey = aeshexkey;
    }
    return self;
}

- (BOOL) isEqualWith: (NXLDecryptionTokenCache*)obj
{
    if ([self.DUID isEqualToString:obj.DUID] && [self.agreement isEqualToString:obj.agreement] && [self.ml isEqualToString:obj.ml] && [self.owner isEqualToString:obj.owner])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

@interface NXLTokenManager ()
{
    NSMutableArray* cachedDecryptionTokens;
}

@end

@implementation NXLTokenManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        nxlSharedInstance = [[self alloc] init];
    });
    
    return nxlSharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commitInit];
        
        cachedDecryptionTokens = [NSMutableArray array];
    }
    return self;
}

- (void)commitInit {
    nxlKeyChainLock = [[NSLock alloc] init];
}

-(void) cleanUserCacheData
{
    [cachedDecryptionTokens removeAllObjects];
}

#pragma mark

- (NSDictionary *)getEncryptionTokenWithClientProfile:(NXLProfile *) clientProfile error:(NSError**)err {
    // step1. try to get token from cache keychain
    NSMutableDictionary *tokens = [[NSMutableDictionary alloc]initWithDictionary:[self getEncryptTokensFromKeyChain]];
    // step2. if can not get token from keychain, generate new tokens from RMS
    if (tokens == nil || ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count == 0)
    {
        tokens = [NSMutableDictionary dictionaryWithDictionary:[self getEncryptionTokensFromServerWithClientProfile:clientProfile error:err]];
    }
    //if both server and keychain is nil. return false.
    if (tokens == nil || ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count == 0) {
        return nil;
    }
    
    //it cache is less than min count. get more tokens and cache them
    if (tokens && ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count < kCacheMinCount + 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError* error = nil;
            [self getEncryptionTokensFromServerWithClientProfile:clientProfile error:&error];
        });
    }
    
    if (tokens && ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count) {
        NSMutableDictionary *tokensPair = [[NSMutableDictionary alloc]initWithDictionary:tokens[TOKEN_TOKENS_PAIR_KEY]];
        NSString *key = [[tokensPair allKeys] objectAtIndex:0];  // just get first token pair
        
        NSDictionary *token = @{key: [tokensPair objectForKey:key]};
        // when using a token, remove it.
        [tokensPair removeObjectForKey:key];
        tokens[TOKEN_TOKENS_PAIR_KEY] = tokensPair;
        // update keychain
        [self saveEncryptTokensToKeyChain:tokens];
        
        NSDictionary *retToken = @{TOKEN_AG_KEY:tokens[TOKEN_AG_KEY], TOKEN_AG_ICA: tokens[TOKEN_AG_ICA], TOKEN_ML_KEY:tokens[TOKEN_ML_KEY], TOKEN_TOKENS_PAIR_KEY:token};
        return retToken;
    }
    
    return nil;
}

- (NSString *)getDecryptionToken:(NSString *)uuid agreement:(NSData *)pubKey owner:(NSString *)owner ml:(NSString *)ml profile:(NXLProfile *) userProfile error: (NSError**)err{
    /*
     in nxl, we have stored agreement public key, this is binary.
     so, we need to convert binary format publick key to PEM agreement.
     */
    NSString *agreement = [NXLOpenSSL DHAgreementFromBinary:pubKey];
    
    NXLDecryptionTokenCache* newToken = [[NXLDecryptionTokenCache alloc]initWith:uuid agreement:agreement ml:ml owner:owner aeshexkey:nil];
    
    // step1. check memory cache to see if decrytion key is there.
    for (NXLDecryptionTokenCache* cache in cachedDecryptionTokens) {
        if ([cache isEqualWith:newToken]) {
            return cache.aeshexkey;
        }
    }
    
   // step2. if no memory cache, then get decrypt token from server
    
    NSString *token = [self getDecryptionTokenFromServer:uuid agreement:agreement owner:owner ml:ml profile:(NXLProfile *) userProfile error: err];
    
    if (token == nil) {
        return nil;
    }
    
    newToken.aeshexkey = token;
    
    // cache in memory.
 //   [cachedDecryptionTokens removeAllObjects];
    [cachedDecryptionTokens addObject:newToken];
    
    return token;
}

#pragma mark -

- (NSDictionary *)getEncryptionTokensFromServerWithClientProfile:(NXLProfile *)clientProfile  error:(NSError**)err{
    
    __block NSDictionary *certificates = nil;
    
    // call membership first
    NXLMemshipAPIRequestModel *model = [[NXLMemshipAPIRequestModel alloc]initWithUserId:clientProfile.userId ticket:clientProfile.ticket membership:clientProfile.defaultMembership.ID publickey:[NXLOpenSSL generateDHKeyPair][DH_PUBLIC_KEY]];
    
    NXLMemshipAPI *memshipAPI = [[NXLMemshipAPI alloc]initWithRequest:model];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSError* apiError = nil;
    [memshipAPI requestWithObject:nil Completion:^(id response, NSError *error) {
        if (error) {
            apiError = error;
            NSLog(@"error %@", error.localizedDescription);
            
        } else {
            NXLMemshipAPIResponse *membershipResponse = (NXLMemshipAPIResponse *)response;
            if (membershipResponse.rmsStatuCode != 200) {
                NSLog(@"error %@", membershipResponse.rmsStatuMessage);

                apiError = [NSError errorWithDomain:NXLSDKErrorRestDomain code:membershipResponse.rmsStatuCode userInfo:nil];
                
            } else {
                certificates = membershipResponse.results;
            }
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (apiError) {
        if (err) {
            *err = apiError;
        }
        
        return nil;
    }
    
    if (certificates == nil || certificates.count < 2) {
        if (err) {
            *err = [NSError errorWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorFailedRequestMembership userInfo:nil];
        }
        return nil;
    }
    
    NSString* rootCA = nil;
    if (certificates.count >= 3) {
        rootCA = [certificates objectForKey:@"certficate3"];
    }
    else
    {
        rootCA = [certificates objectForKey:@"certficate2"];
    }
    
    NSString *tokenAgreement = nil;
    NSData* binPubKey = nil;
    [NXLOpenSSL DHAgreementPublicKey:rootCA binPublicKey:&binPubKey agreement:&tokenAgreement];
    
    // calculate agreement between member private key and iCA public key
    NSString* iCA = [certificates objectForKey:@"certficate2"];
    NSData* agreementICA = nil;
    NSString* sAgreementICA = nil;
    [NXLOpenSSL DHAgreementPublicKey:iCA binPublicKey:&agreementICA agreement:&sAgreementICA];
    
    // Generate "create encryption token" request
    NXLEncryptTokenAPIRequestModel *encryptmodel = [[NXLEncryptTokenAPIRequestModel alloc] initWithUserId:clientProfile.userId ticket:clientProfile.ticket membership:clientProfile.defaultMembership.ID agreement:tokenAgreement];
    
    dispatch_semaphore_t sema2 = dispatch_semaphore_create(0);
    NXLEncryptTokenAPI *encryptAPI = [[NXLEncryptTokenAPI alloc]initWithRequest:encryptmodel];
    apiError = nil;
    __block NSDictionary *tokens = nil;
    [encryptAPI requestWithObject:nil Completion:^(id response, NSError *error) {
        if (error) {
            apiError = error;
            NSLog(@"encryptTokenAPI Requset model error");
        } else {
            NXLEncryptTokenAPIResponse *encryptResponse = (NXLEncryptTokenAPIResponse *)response;
            if (encryptResponse.rmsStatuCode != 200) {
                NSLog(@"error %@", encryptResponse.rmsStatuMessage);

                apiError = [NSError errorWithDomain:NXLSDKErrorRestDomain code:encryptResponse.rmsStatuCode userInfo:nil];
            } else {
                
                tokens = @{TOKEN_AG_KEY:binPubKey, TOKEN_AG_ICA: agreementICA, TOKEN_ML_KEY:encryptResponse.ml, TOKEN_TOKENS_PAIR_KEY:encryptResponse.tokens};
               [self saveEncryptTokensToKeyChain:tokens];
               
            }
        }
        dispatch_semaphore_signal(sema2);
    }];
    dispatch_semaphore_wait(sema2, DISPATCH_TIME_FOREVER);
    
    if (err) {
        *err = apiError;
    }
    
    return tokens;
    return nil;
}

- (NSString *)getDecryptionTokenFromServer:(NSString *)uuid agreement: (NSString*)agreement owner:(NSString *)owner ml:(NSString *)ml profile:(NXLProfile *) userProfile error: (NSError**)err{

    NXLDecryptTokenAPIRequestModel *decryptModel = [[NXLDecryptTokenAPIRequestModel alloc] init];
    decryptModel.userid = userProfile.userId;
    decryptModel.ticket = userProfile.ticket;
    decryptModel.tenant = [NXLTenant currentTenant].tenantID;
    
    decryptModel.ml = ml;
    decryptModel.owner = owner;

    decryptModel.agreement = agreement;
    decryptModel.duid = uuid;

    
    NXLDecryptTokenAPI *decryptTokenAPI = [[NXLDecryptTokenAPI alloc] initWithRequest:decryptModel];
    
    
    
    __block NSString *token = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSError* apiError = nil;
    [decryptTokenAPI requestWithObject:nil Completion:^(id response, NSError *error) {
        if (error) {
            apiError = error;
            
            NSLog(@"error:%@", error.localizedDescription);
        } else {
            NXLDecryptTokenResponse *decryptResponse = (NXLDecryptTokenResponse *)response;
            if (decryptResponse.rmsStatuCode != 200) {
                NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey:decryptResponse.rmsStatuMessage};
                apiError = [NSError errorWithDomain:NXLSDKErrorRestDomain code:decryptResponse.rmsStatuCode userInfo:userInfoDict];
                
                NSLog(@"NXDecryptTokenAPI error: %@", decryptResponse.rmsStatuMessage);
             
            }
            else
            {
                token = decryptResponse.token;
             //   NSLog(@"get token from server: %@", token);
            }
            
            
        }
        dispatch_semaphore_signal(sema);
    }];
    
    // wait for api access to finish
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if (err) {
        *err = apiError;
    }
    return token;
}

#pragma mark

- (NSDictionary *)getEncryptTokensFromKeyChain {
    [nxlKeyChainLock lock];
    NSMutableDictionary *tokens = [NXLKeyChain load:kEncrypKeyChainKey];
    [nxlKeyChainLock unlock];
    return tokens;
}

- (void)saveEncryptTokensToKeyChain:(NSDictionary *)tokens {
    [nxlKeyChainLock lock];
    NSMutableDictionary *oldTokens = [NXLKeyChain load:kEncrypKeyChainKey];
    if (oldTokens) {
        [NXLKeyChain delete:kEncrypKeyChainKey];
    }
    [NXLKeyChain save:kEncrypKeyChainKey data:[NSMutableDictionary dictionaryWithDictionary:tokens]];
    
    [nxlKeyChainLock unlock];
}

- (void)deleteEncryptTokensInkeyChain {
    [nxlKeyChainLock lock];
    [NXLKeyChain delete:kEncrypKeyChainKey];
    [nxlKeyChainLock unlock];
}


@end
