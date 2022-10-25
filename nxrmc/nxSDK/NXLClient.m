//
//  NXClient.m
//  nxSDK
//
//  Created by EShi on 8/31/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLClient.h"
#import "NXLProfile.h"
#import "NXLMetaData.h"
#import "NXLCommonUtils.h"
#import "NXLSharingAPI.h"
#import "NXLLogAPI.h"
#import "NXLSyncHelper.h"
#import "NXLCacheManager.h"
#import "NXLTenant.h"
#import "NXLClientSessionStorage.h"
@interface NXLClient()

@property(nonatomic, strong) NXLTenant *userTenant;
@property(nonatomic, strong) NSString *userID;

@property(nonatomic, strong) NXLProfile *profile;
@property(nonatomic, strong) NSMutableDictionary *compBlockDict;
@end

@implementation NXLClient

#pragma mark - INIT/GETTER/SETTER
- (NSMutableDictionary *) compBlockDict
{
    if (_compBlockDict == nil) {
        _compBlockDict = [[NSMutableDictionary alloc] init];
    }
    return _compBlockDict;
}

- (instancetype) initWithNXProfile:(NXLProfile *) profile tenantID:(NSString *) tenantID
{
    self = [super init];
    if (self) {
        _profile = profile;
        _userID = profile.userId;
        [NXLTenant setCurrentTenantWithID:tenantID rmsServer:profile.rmserver];
        _userTenant = [NXLTenant currentTenant];
    }
    return self;
}

+ (instancetype) clientWithTenant:(NXLTenant *)tenant userID:(NSString *)userID error:(NSError **)error
{
    NXLClient *client = [[NXLClientSessionStorage sharedInstance] getClientWithTenant:tenant userID:userID];
    if ([client isSessionTimeout]) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorUserSessionTimeout userInfo:nil];
        }
        [[NXLClientSessionStorage sharedInstance] delClient:client];
        return nil;
    }
    [NXLTenant setCurrentTenantWithID:client.userTenant.tenantID rmsServer:client.userTenant.rmsServerAddress];
    return client;
}


- (void) encryptToNXLFile:(NSURL *)filePath
                 destPath:(NSURL *)destPath
                overwrite:(BOOL)isOverwrite
              permissions:(NXLRights *)permissions
           withCompletion:(encryptToNXLFileCompletion)completion
{
    NSError *destPathError = nil;
    [self checkOperationDestPath:destPath isOverwrite:isOverwrite error:&destPathError];
    if (destPathError) {
        completion(nil, destPathError);
        return;
    }
    BOOL isCustomDestPath = destPath? YES: NO;
    
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    // default have view right
    if (permissions == nil) {
        permissions = [[NXLRights alloc] init];
    }
    [permissions setRight:NXLRIGHTVIEW value:YES]; // default have view rights
    
    NSString *fileName = [filePath pathComponents].lastObject;
    NSString *encryptDestPath = nil;
    if (destPath) {
        encryptDestPath = [destPath.path copy];
    }else
    {
        encryptDestPath = [NXLCommonUtils getTempNXLFilePath:fileName];
    }
    
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
    [NXLMetaData encrypt:filePath.path destPath:encryptDestPath clientProfile:self.profile complete:^(NSError *error, id appendInfo) {

        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            if (strongSelf.compBlockDict[operationIdentify]) {
               ((encryptToNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
            }
        }else if(strongSelf.compBlockDict[operationIdentify]){  // add rights
            [NXLMetaData addAdHocSharingPolicy:encryptDestPath issuer:strongSelf.profile.defaultMembership.ID rights:permissions timeCondition:nil clientProfile:strongSelf.profile complete:^(NSError *error) {
                if (error) {
                    if (strongSelf.compBlockDict[operationIdentify]) {
                        ((encryptToNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, error);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    }
                }else
                {
                    if (strongSelf.compBlockDict[operationIdentify]) {
                        ((encryptToNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))([NSURL fileURLWithPath:encryptDestPath isDirectory:NO], nil);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    }
                }
                
                NSError *fileMgrError = nil;
                if (!isCustomDestPath) {
                     [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
                }
            }];
        }else
        {
            NSError *fileMgrError = nil;
            if (!isCustomDestPath) {
                [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
            }
        }
    }];
}


- (void) decryptNXLFile:(NSURL *)filePath destPath:(NSURL *)destPath overwrite:(BOOL)isOverwrite withCompletion:(decryptNXLFileCompletion) completion
{
    NSError *destPathError = nil;
    [self checkOperationDestPath:destPath isOverwrite:isOverwrite error:&destPathError];
    if (destPathError) {
        completion(nil, nil, destPathError);
        return;
    }
    BOOL isCustomDestPath = destPath? YES: NO;
    NSError *error = nil;
    NSString *decryptPath = nil;
    if (destPath) {
        decryptPath = [destPath.path copy];
    }else
    {
        decryptPath = [NXLCommonUtils getTempDecryptFilePath:filePath.path clientProfile:self.profile error:&error];
    }
   
    if (decryptPath == nil) {
        completion(nil, nil, error);
        return;
    }
     NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
    [NXLMetaData decrypt:filePath.path destPath:decryptPath clientProfile:self.profile complete:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            ((decryptNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, nil, error);
            return;
        }
        
        if (strongSelf.compBlockDict[operationIdentify]) {
            [strongSelf getNXLFileRights:filePath withCompletion:^(NXLRights *rights, NSError *error) {
//                if(strongSelf.decryptCompletion)
                if (error) {
                    ((decryptNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, nil, error);
                    
                }else
                {
                    ((decryptNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))([NSURL fileURLWithPath:decryptPath isDirectory:NO], rights, error);
                }
                
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                
                NSError *fileMgrError = nil;
                if (!isCustomDestPath) {
                    [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
                }
            }];
            
        }else // strongSelf.decryptCompletion == nil
        {
            NSError *fileMgrError = nil;
            if (!isCustomDestPath) {
                [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
            }
        }
    }];
}

- (void) shareFile:(NSURL *) filePath
          destPath:(NSURL *)destPath
         overwrite:(BOOL)isOverwrite
        recipients:(NSArray *)recipients
         permissions:(NXLRights *)permissions
         expiredDate:(NSDate *)date
      withCompletion:(shareFileCompletion)completion
{
    
    NSError *destPathError = nil;
    [self checkOperationDestPath:destPath isOverwrite:isOverwrite error:&destPathError];
    if (destPathError) {
        completion(nil, destPathError);
        return;
    }
    
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
     __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([NXLMetaData isNxlFile:filePath.path]) {
            __block NSString* owner = nil;
            [NXLMetaData getOwner:filePath.path complete:^(NSString *ownerId, NSError *error) {
                if (error) {
                    NSLog(@"getOwner %@", error);
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                    [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    return;
                }
                owner = ownerId;
            }];
            
            NXLRights *rights = nil;
            
            dispatch_semaphore_t semi = dispatch_semaphore_create(0);
            
            // get rights from ad-hoc section in nxl
            __block NSDictionary *blockPolicySection = nil;
            [NXLMetaData getPolicySection:filePath.path clientProfile:self.profile complete:^(NSDictionary *policySection, NSError *error) {
                if (error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                    [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    dispatch_semaphore_signal(semi);
                    return;
                } else {
                    blockPolicySection = policySection;
                }
                dispatch_semaphore_signal(semi);
            }];
            dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
            
            if (blockPolicySection == nil) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            
            NSArray* policies = [blockPolicySection objectForKey:@"policies"];
            if (policies.count == 0) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            NSDictionary* policy = [policies objectAtIndex:0];
            NSArray* namedRights = [policy objectForKey:@"rights"];
            NSArray* namedObs = [policy objectForKey:@"obligations"];
            rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
            
            BOOL isstward = [NXLCommonUtils isStewardUser:owner clientProfile:self.profile];
            if (isstward || (rights && [rights SharingRight])) {
                NSDictionary *token = nil;
                NSError* err = nil;
                [NXLMetaData getFileToken:filePath.path tokenDict:&token clientProfile:self.profile error: &err];
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (token) {
                    [strongSelf shareFile:filePath.path emails:recipients token:token permission:[rights getRights] owner:owner];
                    
                    if (strongSelf.compBlockDict[operationIdentify]) {
                        ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(filePath, nil);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    }
                } else {
                    ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, err);
                    [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                }
                
            }
        }
        else
        {  // not nxl file, do encrypt first, and then handle nxl header, like ad-hoc policy
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf encryptToNXLFile:filePath destPath:destPath overwrite:isOverwrite permissions:permissions withCompletion:^(NSURL *filePath, NSError *error) {
                if (filePath) {
                    __block NSString* owner = nil;
                    [NXLMetaData getOwner:filePath.path complete:^(NSString *ownerId, NSError *error) {
                        if (error) {
                            NSLog(@"getOwner %@", error);
                        }
                        owner = ownerId;
                    }];
                    
                    NXLRights *rights = nil;
                    
                    dispatch_semaphore_t semi = dispatch_semaphore_create(0);
                    
                    // get rights from ad-hoc section in nxl
                    __block NSDictionary *blockPolicySection = nil;
                    [NXLMetaData getPolicySection:filePath.path clientProfile:self.profile complete:^(NSDictionary *policySection, NSError *error) {
                        if (error) {
                            //
                        } else {
                            blockPolicySection = policySection;
                        }
                        dispatch_semaphore_signal(semi);
                    }];
                    dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
                    
                    if (blockPolicySection == nil) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                        ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                        return;
                    }
                    
                    
                    NSArray* policies = [blockPolicySection objectForKey:@"policies"];
                    if (policies.count == 0) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                        ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                        return;
                    }
                    
                    NSDictionary* policy = [policies objectAtIndex:0];
                    NSArray* namedRights = [policy objectForKey:@"rights"];
                    NSArray* namedObs = [policy objectForKey:@"obligations"];
                    rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
                    
                    BOOL isstward = [NXLCommonUtils isStewardUser:owner clientProfile:self.profile];
                    if (isstward || (rights && [rights SharingRight])) {
                        NSDictionary *token = nil;
                        NSError* err = nil;
                        [NXLMetaData getFileToken:filePath.path tokenDict:&token clientProfile:self.profile error: &err];
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if (token) {
                            [strongSelf shareFile:filePath.path emails:recipients token:token permission:[rights getRights] owner:owner];
                            
                            if (strongSelf.compBlockDict[operationIdentify]) {
                                ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(filePath, nil);
                                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                            }
                        } else {
                            ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, err);
                            [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                        }
                        
                    }
                }
            }];
        }

    });
    
}

- (void)shareFile:(NSString *)filePath emails:(NSArray *)emailsAddresses token:(NSDictionary *) token permission:(long) permissions owner:(NSString *) owner;
{
    // step1. generate sharing rest and store it
    NSMutableArray *recipientArray = [[NSMutableArray alloc] init];
    
    NSDictionary * recipient = nil;
    if (emailsAddresses.count) {
        for (NSInteger index = 0; index < emailsAddresses.count; ++index) {
            recipient = @{@"email":emailsAddresses[index]};
            [recipientArray addObject:recipient];
        }
    }
    
    NSString *udid = [token allKeys].firstObject;
    
    NSArray *fileNameCompont = [filePath componentsSeparatedByString:@"/" ];
    NSDictionary *sharedDocumentDic = @{DUID_KEY:udid, MEMBER_SHIP_ID_KEY:self.profile.defaultMembership.ID,
                                        PERMISSIONS_KEY:[NSNumber numberWithLong:permissions],
                                        METADATA_KEY:@"{}",
                                        FILENAME_KEY:fileNameCompont.lastObject,
                                        RECIPIENTS_KEY:recipientArray};
    NSError *error = nil;
    NSData *recipientsData = [NSJSONSerialization dataWithJSONObject:sharedDocumentDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *recipientsString = [[NSString alloc] initWithData:recipientsData encoding:NSUTF8StringEncoding];
    NSString *checkSUM = [NXLMetaData hmacSha256Token:token[udid] content:recipientsData];
    NSDictionary *sharingDic = @{USER_ID_KEY:self.profile.userId,
                                 TIKECT_KEY:self.profile.ticket,
                                 DEVICE_ID_KEY:[NXLCommonUtils deviceID],
                                 DEVICE_TYPE_KEY:[NXLCommonUtils getPlatformId],
                                 CHECK_SUM_KEY:checkSUM,
                                 SHARED_DOC_KEY:recipientsString};
    
    NXLSharingAPIRequest *sharingReq = [[NXLSharingAPIRequest alloc] init];
    [sharingReq requestWithObject:sharingDic Completion:^(id response, NSError *error) {
        if ([response isKindOfClass:[NXLSharingAPIResponse class]] && error ==nil ) {
            NXLLogAPIRequestModel *model = [[NXLLogAPIRequestModel alloc]init];
            model.duid = [[token allKeys] firstObject];
            model.owner = owner;
            model.operation = [NSNumber numberWithInteger:kNXLShareOperation];
            model.repositoryId = @" ";
            model.filePathId = @" ";
            model.accessTime = [NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970] * 1000)];
            model.accessResult = [NSNumber numberWithInteger:1];
            model.filePath = filePath;
            model.fileName = fileNameCompont.lastObject;
            model.activityData = @"";
            model.ticket = self.profile.ticket;
            model.userID = self.profile.userId;
            NXLLogAPI *logAPI = [[NXLLogAPI alloc]init];
            [logAPI requestWithObject:model Completion:^(id response, NSError *error) {
                
            }];

        }
    }];
  
    
}


- (void) getNXLFileRights:(NSURL *)filePath withCompletion:(getNXLFileRightsCompletion)completion
{
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
        // get rights from ad-hoc section in nxl
    __block NSDictionary *blockPolicySection = nil;
    [NXLMetaData getPolicySection:filePath.path clientProfile:self.profile complete:^(NSDictionary *policySection, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            ((getNXLFileRightsCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, error);
            [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
            
        } else {
            blockPolicySection = policySection;
            
            if (policySection == nil) {
                // create no policySection error
                // strongSelf.getNXLFileRightsCompletion(nil, error);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((getNXLFileRightsCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            NSArray *policies = [policySection objectForKey:@"policies"];
            if(policies.count == 0)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((getNXLFileRightsCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            NSDictionary* policy = [policies objectAtIndex:0];
            NSArray* namedRights = [policy objectForKey:@"rights"];
            NSArray* namedObs = [policy objectForKey:@"obligations"];

            NXLRights *rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
            ((getNXLFileRightsCompletion)(strongSelf.compBlockDict[operationIdentify]))(rights, nil);
            [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
        }
       
    }];
}

- (BOOL) isNXLFile:(NSURL *) filePath
{
    return [NXLMetaData isNxlFile:filePath.path];
}

// signOut
- (BOOL) signOut:(NSError **)error
{
    [[NXLClientSessionStorage sharedInstance] delClient:self];
    return YES;
}

- (BOOL) isSessionTimeout
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if (self.profile.ttl.doubleValue - timeInterval * 1000  > 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma makr - Private function
- (void) checkOperationDestPath:(NSURL *)filePath isOverwrite:(BOOL)isOverwrite error:(NSError **)error
{
    assert(error);
    if (!isOverwrite) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:filePath.path])
        {
            *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLClientDomain code:NXLSDKErrorFileExisted userInfo:nil];
        }
        return;
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_profile forKey:@"profile"];
    [aCoder encodeObject:self.userID forKey:@"userId"];
    [aCoder encodeObject:self.userTenant forKey:@"usertenant"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.profile = [aDecoder decodeObjectForKey:@"profile"];
        _userID = [aDecoder decodeObjectForKey:@"userId"];
        _userTenant = [aDecoder decodeObjectForKey:@"usertenant"];
    }
    return self;
}

@end
