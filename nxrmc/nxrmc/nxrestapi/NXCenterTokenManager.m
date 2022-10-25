//
//  NXCenterTokenManager.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/10/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXCenterTokenManager.h"
#import "NXGetAccessTokenAPI.h"
static NXCenterTokenManager *sharedInstance = nil;

@interface NXCenterTokenManager()
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *tokenCache;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *refreshTokenTask;
@property(nonatomic, weak) NXGetAccessTokenAPIRequest *curTaskReq;
@end
@implementation NXCenterTokenManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NXCenterTokenManager alloc] init];
    });
    return sharedInstance;
}

- (NSString *)accessTokenForRepository:(NSString *)repoId {
    NSString *accessToken = self.tokenCache[repoId];
    return accessToken;
}

- (void)setAccessToken:(NSString *)token forRepository:(NSString *)repoId {
    [self.tokenCache setObject:token forKey:repoId];
}

- (void)refreshAccessTokenForRepository:(NSString *)repoId withCompletion:(refreshAccessTokenCompletion)comp {
    if (self.refreshTokenTask[repoId] == nil) {
        NSMutableArray *taskCompBlockArray = [[NSMutableArray alloc] initWithArray:@[comp]];
        [self.refreshTokenTask setObject:taskCompBlockArray forKey:repoId];
        
        NXGetAccessTokenAPIRequest *getAccessTokenReq = [[NXGetAccessTokenAPIRequest alloc] init];
        self.curTaskReq = getAccessTokenReq;
        WeakObj(self);
        [getAccessTokenReq requestWithObject:repoId Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            StrongObj(self);
            if (self) {
                if (error == nil) {
                    if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                        NSString *token = ((NXGetAccessTokenAPIResponse *)response).accessToken;
                        NSArray *compArray = self.refreshTokenTask[repoId];
                        for (refreshAccessTokenCompletion compBlock in compArray) {
                            compBlock(repoId, token, nil);
                        }
                        [self.tokenCache setObject:token forKey:repoId];
                        [self.refreshTokenTask removeObjectForKey:repoId];
                    }else {
                        NSError *rmsError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_GET_REPO_ACCESS_TOKEN_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_REPO_TOKEN_FAILED", nil)}];
                        NSArray *compArray = self.refreshTokenTask[repoId];
                        for (refreshAccessTokenCompletion compBlock in compArray) {
                            compBlock(repoId, nil, rmsError);
                        }
                        [self.refreshTokenTask removeObjectForKey:repoId];
                    }
                }else {
                    NSArray *compArray = self.refreshTokenTask[repoId];
                    for (refreshAccessTokenCompletion compBlock in compArray) {
                        compBlock(repoId, nil, error);
                    }
                    [self.refreshTokenTask removeObjectForKey:repoId];
                }
                
            }
        }];
    }else {
        NSMutableArray *taskCompBlockArray = self.refreshTokenTask[repoId];
        [taskCompBlockArray addObject:comp];
    }
}

- (void)resetAllAccessToken {
    self.tokenCache = nil;
    [self.curTaskReq cancelRequest];
    [self.refreshTokenTask removeAllObjects];
}

- (NSMutableDictionary *)tokenCache {
    @synchronized (self) {
        if (_tokenCache == nil) {
            _tokenCache = [[NSMutableDictionary alloc] init];
        }
        return _tokenCache;
    }
}

- (NSMutableDictionary *)refreshTokenTask {
    @synchronized (self) {
        if (_refreshTokenTask == nil) {
            _refreshTokenTask = [[NSMutableDictionary alloc] init];
        }
        return _refreshTokenTask;
    }
}
@end
