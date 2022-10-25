//
//  NXDropBoxAuther.m
//  nxrmc
//
//  Created by EShi on 8/5/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXDropBoxAuther.h"
#import "ObjectiveDropboxOfficial.h"
#import "NXCommonUtils.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "AppDelegate.h"
#import "NXMBManager.h"

@interface NXDropBoxAuther()
@property(nonatomic, strong) DBUserClient *dbClient;
@end

@implementation NXDropBoxAuther
-(instancetype) init
{
    self = [super init];
    if (self) {
        _repoType = kServiceDropbox;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectServiceFinished:) name:@"dropbox" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxBindCancel:) name:NOTIFICATION_DROP_BOX_CANCEL object:nil];
    }
    return self;
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) authRepoInViewController:(UIViewController *) vc
{
    self.authViewController = vc;
    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                   controller:vc
                                      openURL:^(NSURL *url) {
                                
                                              [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];

                                        
                                      }];
    
}

- (void)authRepoInViewController:(UIViewController *)vc repostioryAlias:(NSString *)repoAlias {
  
}


- (void)authRepoWithRepostioryAlias:(NSString *)repoAlias {
  
}


#pragma mark - Dropbox DBRestClientDelegate
-(void) connectServiceFinished:(NSNotification*) notification {
    NSDictionary *inforDic = notification.userInfo;
    NSString *accessToken = [inforDic objectForKey:@"ACCESS_TOKEN"];
    NSString *tokenId = [inforDic objectForKey:@"USER_TOKEN_ID"];
    NSError *error = [inforDic objectForKey:@"KEY_ERROR"];
    if (error) {
        if([self.delegate respondsToSelector:@selector(repoAuther:authFailed:)])
        {
            NSError *boundError = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_AUTHFAILED userInfo:@{NSLocalizedDescriptionKey:error}];
            dispatch_main_async_safe(^{
                [self.delegate repoAuther:self authFailed:boundError];
            });
        }
    } else {
        self.dbClient = [[DBUserClient alloc] initWithAccessToken:accessToken];
        WeakObj(self);
        dispatch_main_async_safe(^{
            [NXMBManager showLoadingToView:[self.authViewController view]];
        });
        
        [[self.dbClient.usersRoutes getCurrentAccount] setResponseBlock:^(DBUSERSFullAccount * _Nullable result, DBNilObject * _Nullable routeError, DBRequestError * _Nullable networkError) {
            StrongObj(self);
            if(self){
                dispatch_main_async_safe(^{
                     [NXMBManager hideHUDForView:[self.authViewController view]];
                });
                if (routeError || networkError) {
                    NSError *boundError = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_AUTHFAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"DROPBOX_SIGNIN_ERROR", nil)}];
                    dispatch_main_async_safe(^{
                        [self.delegate repoAuther:self authFailed:boundError];
                    });
                }else{
                 
                    NSDictionary *authResult = @{AUTH_RESULT_ACCOUNT:result.email, AUTH_RESULT_ACCOUNT_ID:tokenId, AUTH_RESULT_ACCOUNT_TOKEN:accessToken, AUTH_RESULT_REPO_TYPE:[NSNumber numberWithInteger:kServiceDropbox]};
                    [self.delegate repoAuther:self didFinishAuth:authResult];
                }
            }
        }];
    }
}

-(void) dropBoxBindCancel:(NSNotification *) notification
{
    if ([self.delegate respondsToSelector:@selector(repoAuthCanceled:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate repoAuthCanceled:self];
        });
    }
}




@end
