//
//  NXTokenManager.h
//  nxrmc
//
//  Created by nextlabs on 6/22/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLProfile.h"

// Token Define
#define TOKEN_AG_KEY @"token_agreement"
#define TOKEN_AG_ICA @"token_agreement_ica"
#define TOKEN_ML_KEY @"token_ml"
#define TOKEN_TOKENS_PAIR_KEY @"token_pair"

@interface NXLTokenManager : NSObject

+ (instancetype)sharedInstance;

- (NSDictionary *)getEncryptionTokenWithClientProfile:(NXLProfile *) clientProfile error:(NSError**)err;
- (NSString *)getDecryptionToken:(NSString *)duid agreement: (NSData*) pubKey owner: (NSString*) owner ml: (NSString*)ml profile:(NXLProfile *) userProfile error: (NSError**)err;

-(void) cleanUserCacheData;
- (void)deleteEncryptTokensInkeyChain;

@end
