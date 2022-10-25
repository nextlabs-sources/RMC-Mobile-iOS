//
//  NXCenterTokenManager.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/10/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^refreshAccessTokenCompletion)(NSString *repoId, NSString *accessToken, NSError *error);
@interface NXCenterTokenManager : NSObject
+ (instancetype)sharedInstance;
- (void)setAccessToken:(NSString *)token forRepository:(NSString *)repoId;
- (NSString *)accessTokenForRepository:(NSString *)repoId;
- (void)refreshAccessTokenForRepository:(NSString *)repoId withCompletion:(refreshAccessTokenCompletion)comp;

- (void)resetAllAccessToken;
@end
