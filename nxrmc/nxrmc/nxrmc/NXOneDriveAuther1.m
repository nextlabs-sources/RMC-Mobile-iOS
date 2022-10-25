//
//  NXOneDriveAuther.m
//  nxrmc
//
//  Created by EShi on 8/5/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXOneDriveAuther.h"
#import "NXCommonUtils.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "AppDelegate.h"
#import "NXCacheManager.h"
#import "NXMBManager.h"

typedef NS_ENUM(NSInteger, NXOneDriveBoundCase)
{
    NXONEDRIVEBOUNDED_UNSET = 1,
    NXONEDRIVEBOUNDED,
};

typedef NS_ENUM(NSInteger, NXOneDriveUserSet)
{
    NXONEDRIVEUSERSET_UNSET = 0,
    NXONEDRIVEUSERSET_LOGIN,
    NXONEDRIVEUSERSET_LOGOUT,
    NXONEDRIVEUSERSET_LOGOUTFORBOUNDING,
};

@interface NXOneDriveAuther() <LiveAuthDelegate,LiveOperationDelegate>
@property(nonatomic, strong) NXRepositoryModel *anotherUserOneDrive;
@end

@implementation NXOneDriveAuther
-(instancetype) init
{
    self = [super init];
    if (self) {
        _repoType = kServiceOneDrive;
    }
    return self;
}
- (void) authRepoInViewController:(UIViewController *) vc
{
    self.authViewController = vc;
    NXOneDriveBoundCase cs = [self getOneDriveBoundedCase];
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if(cs == NXONEDRIVEBOUNDED)
    {
        [NXCommonUtils showAlertViewInViewController:self.authViewController
                                               title:[NXCommonUtils currentBundleDisplayName]
                                             message:NSLocalizedString(@"MSG_ONE_MORE_ONEDRIVE", nil)];
        if ([self.delegate respondsToSelector:@selector(repoAuthCanceled:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate repoAuthCanceled:self];
            });
            
        }
        return;
    }
    else if(app.liveClient.session)
    {
        NSLog(@"One Drive has bounded by another");
        if(app.liveClient.session)
        {
            [app.liveClient logoutWithDelegate:self userState:@(NXONEDRIVEUSERSET_LOGOUTFORBOUNDING)];
            return;
        }
    }
    [self oneDriveDoLogin];
}

#pragma mark - liveClient LiveAuthDelegate
- (void) authCompleted:(LiveConnectSessionStatus)status
               session:(LiveConnectSession *)session
             userState:(id)userState
{
    NSInteger iuserState = [((NSNumber*)userState) integerValue];
    if(iuserState == NXONEDRIVEUSERSET_LOGIN)
    {
        [self getOneDriveAccountInfo];
    }
    else if(iuserState == NXONEDRIVEUSERSET_LOGOUTFORBOUNDING)
    {
        [self oneDriveDoLogin];
        if(_anotherUserOneDrive)
        {
#pragma mark if it is need to delete the cache file and record file,now delete the all record for another user
            //delete record cache  file in database
            [NXCacheFileStorage deleteCacheFilesFromCoreDataForRepo:_anotherUserOneDrive];
            // delete cache files.
            NSURL* url = [NXCacheManager getLocalUrlForServiceCache:_anotherUserOneDrive];
            
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            // delete record in database
            [NXRepositoryStorage deleteRepoFromCoreData:_anotherUserOneDrive];
        }
    }
}

- (void) authFailed:(NSError *)error
          userState:(id)userState
{
    NSInteger iuserState = [((NSNumber*)userState) integerValue];
    if(iuserState == NXONEDRIVEUSERSET_LOGIN)
    {
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.liveClient logout];
        if (error.code == 2 || error.code == 1) { // 1 means user deny auth connect to onedrvie 2 means user cancel auth
            if ([self.delegate respondsToSelector:@selector(repoAuthCanceled:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate repoAuthCanceled:self];
                });
                
            }
        }else
        {
            if ([self.delegate respondsToSelector:@selector(repoAuther:authFailed:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate repoAuther:self authFailed:error];
                });
                
            }
        }
    }
    else if(iuserState == NXONEDRIVEUSERSET_LOGOUTFORBOUNDING)
    {
        if ([self.delegate respondsToSelector:@selector(repoAuther:authFailed:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate repoAuther:self authFailed:error];
            });
        }
    }
}

#pragma mark  liveClient iveOperationDelegate
- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    if([operation.userState isEqualToString:@"get user info"])
    {
        dispatch_main_async_safe(^{
            [NXMBManager hideHUDForView:[self.authViewController view]];
        });
        NSString *account = [operation.result objectForKey:@"name"];
        if (((NSNull *)account)== [NSNull null]) {
            account = @"";
        }
        NSString *ID = [operation.result objectForKey:@"id"];
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSString *token = app.liveClient.session.refreshToken;
        
        NSDictionary *authInfoDict = @{AUTH_RESULT_ACCOUNT:account, AUTH_RESULT_ACCOUNT_ID:ID, AUTH_RESULT_ACCOUNT_TOKEN:token, AUTH_RESULT_REPO_TYPE:[NSNumber numberWithInteger:kServiceOneDrive]};
        if ([self.delegate respondsToSelector:@selector(repoAuther:didFinishAuth:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate repoAuther:self didFinishAuth:authInfoDict];
            });
            
        }
    }
}

-(void)liveOperationFailed:(NSError *)error operation:(LiveOperation *)operation
{
    if([operation.userState isEqualToString:@"get user info"])
    {
        dispatch_main_async_safe(^{
            [NXMBManager hideHUDForView:[self.authViewController view]];
        });
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.liveClient logout];
        if ([self.delegate respondsToSelector:@selector(repoAuther:authFailed:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate repoAuther:self authFailed:error];
            });
        }
    }
}

#pragma mark - OneDrive help method
-(void)getOneDriveAccountInfo
{
    dispatch_main_async_safe(^{
        [NXMBManager showLoadingToView:[self.authViewController view]];
    });
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.liveClient getWithPath:@"me"
                       delegate:self
                      userState:@"get user info"];
}

- (NXOneDriveBoundCase)getOneDriveBoundedCase
{
    NXBoundService *service = [NXRepositoryStorage getOneDriveBoundedCase];
    NSDictionary *repoDic = [[NSUserDefaults standardUserDefaults] valueForKey:@"isExistOneDrive"];
    if (repoDic) {
        return NXONEDRIVEBOUNDED;
    }
    if(service == nil)
    {
        return NXONEDRIVEBOUNDED_UNSET;
    }

    if(service.user_id.integerValue == [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId].integerValue)
    {
        // if current user already have onedrive and already authed,return bound
        // if not authed, we allow auth
        if (self.workType == NXOneDriveAutherWorkTypeBoundRepo) {
            return NXONEDRIVEBOUNDED;
        }else if(self.workType == NXOneDriveAutherWorkTypeAuthRepo){
            if (!service.service_isAuthed.boolValue) {
                return NXONEDRIVEBOUNDED_UNSET;
            }else{
                return NXONEDRIVEBOUNDED;
            }
        
        }
    }
    else
    {
        _anotherUserOneDrive = [[NXRepositoryModel alloc] initWithBoundService:service];
        return NXONEDRIVEBOUNDED;
    }
    return NXONEDRIVEBOUNDED_UNSET;
}

- (void)oneDriveDoLogin
{
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if(app.liveClient.session == nil)
    {
        [app.liveClient login:self.authViewController
                       scopes:[NSArray arrayWithObjects:@"wl.signin", @"wl.basic", @"wl.offline_access", @"wl.skydrive",@"wl.emails", @"wl.skydrive_update", nil]
                     delegate:self
                    userState:[NSNumber numberWithInteger:NXONEDRIVEUSERSET_LOGIN]];
    }
}

@end
