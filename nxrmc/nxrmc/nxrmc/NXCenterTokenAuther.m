//
//  NXCenterTokenAuther.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 12/26/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXCenterTokenAuther.h"
#import "NXGetAuthURLAPI.h"
#import "NXCloudAccountUserInforViewController.h"

@implementation NXCenterTokenAuther
- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repositoryAuthFlowFinished:) name:NOTIFICATION_REPO_AUTH_FINISHED object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)authRepoInViewController:(UIViewController *) vc repostioryAlias:(NSString *)repoAlias
{
    self.authVC = vc;
    
    NXCloudAccountUserInforViewController *SPAuthVC = [[NXCloudAccountUserInforViewController alloc] init];
    SPAuthVC.serviceBindType = kServiceSharepointOnline;
    SPAuthVC.repoName = repoAlias;

    SPAuthVC.siteUrlEnterFinishedBlock = ^(NSString *siteUrl){
        if (siteUrl.length > 0) {
            [self.authVC.navigationController popViewControllerAnimated:YES];
            self.siteUrl = siteUrl;
            [self authRepoWithRepostioryAlias:repoAlias];
        }else{
             [self.delegate repoAuthCanceled:self];
        }
    };

    [vc.navigationController pushViewController:SPAuthVC animated:YES];
}

- (void)authRepoInViewController:(UIViewController *)vc {
    
}

- (void)authRepoWithRepostioryAlias:(NSString *)repoAlias {
    NXGetAuthURLRequest *getAuthURLReq = [[NXGetAuthURLRequest alloc] init];
    getAuthURLReq.repoType = self.repoType;
    getAuthURLReq.repoName = repoAlias;
    if (self.siteUrl.length > 0) {
        getAuthURLReq.sharepointOnlineSiteUrl = self.siteUrl;
    }
    WeakObj(self);
    [getAuthURLReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (response.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(repoAuther:authFailed:))) {
                NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_ADD_REPO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"SERVICE_CONNECT_ERROR", nil)}];
                [self.delegate repoAuther:self authFailed:error];
            }
        }else {
            NXGetAuthURLResponse *getAuthURLResponse = (NXGetAuthURLResponse *)response;
            StrongObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([NXCommonUtils iosVersion] >= 10.0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:getAuthURLResponse.authURL] options:@{} completionHandler:^(BOOL success) {
                        if (success == NO) {
                            if (DELEGATE_HAS_METHOD(self.delegate, @selector(repoAuther:authFailed:))) {
                                NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_ADD_REPO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"SERVICE_CONNECT_ERROR", nil)}];
                                [self.delegate repoAuther:self authFailed:error];
                            }
                        }
                    }];
                } else {
                    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:getAuthURLResponse.authURL]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:getAuthURLResponse.authURL] options:@{} completionHandler:nil];
                    } else {
                        if (DELEGATE_HAS_METHOD(self.delegate, @selector(repoAuther:authFailed:))) {
                            NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_ADD_REPO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"SERVICE_CONNECT_ERROR", nil)}];
                            [self.delegate repoAuther:self authFailed:error];
                        }
                    }
                }
            });
        }
    }];
}

#pragma mark - response to notification
- (void)repositoryAuthFlowFinished:(NSNotification *)notification {
    if (notification.userInfo) {
        NSInteger statusCode = ((NSString *)notification.userInfo[AUTH_RESULT_STATUS_CODE]).integerValue;
        if (statusCode == NXRMS_ERROR_CODE_SUCCESS) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(repoAuther:didFinishAuth:))) {
                NSNumber *repoType = [NXCommonUtils rmsToRMCRepoType:notification.userInfo[AUTH_RESULT_REPO_TYPE]];
                
                NSDictionary *authResultDict = @{AUTH_RESULT_REPO_ID:notification.userInfo[AUTH_RESULT_REPO_ID],
                                                 AUTH_RESULT_ALIAS:notification.userInfo[AUTH_RESULT_ALIAS],
                                                 AUTH_RESULT_REPO_TYPE:repoType,
                                                 AUTH_RESULT_ACCOUNT:notification.userInfo[AUTH_RESULT_ACCOUNT],
                                                 AUTH_RESULT_ACCOUNT_ID:notification.userInfo[AUTH_RESULT_ACCOUNT_ID]
                                                 };
                [self.delegate repoAuther:self didFinishAuth:authResultDict];
            }
        }else if(statusCode == NXRMS_ERROR_CODE_REPO_EXISTS || statusCode == 410){
            // fix bug:47796
            // check if local have the repo or not
            NSString *repoId = notification.userInfo[AUTH_RESULT_REPO_ID];
            NXRepositoryModel *model = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:repoId];
            if (model) {
                NSString *errorMsg = (NSString *)notification.userInfo[AUTH_RESULT_STATUS_MESSAGE];
                NSError *error =  [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_ADD_REPO_ERROR userInfo:@{NSLocalizedDescriptionKey:errorMsg?: NSLocalizedString(@"MSG_COM_REPO_EXISTED", nil)}];
                [self.delegate repoAuther:self authFailed:error];
            }else if(repoId && model == nil){
                NSNumber *successCode = [NSNumber numberWithInteger:200];
                [notification.userInfo setValue:successCode forKey:AUTH_RESULT_STATUS_CODE];
                [self repositoryAuthFlowFinished:notification];
            }else {
                NSString *errorMsg = (NSString *)notification.userInfo[AUTH_RESULT_STATUS_MESSAGE];
                NSError *error =  [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_ADD_REPO_ERROR userInfo:@{NSLocalizedDescriptionKey:errorMsg?: NSLocalizedString(@"SERVICE_CONNECT_ERROR", nil)}];
                [self.delegate repoAuther:self authFailed:error];
            }
            
        } else {
            NSString *errorMsg = (NSString *)notification.userInfo[AUTH_RESULT_STATUS_MESSAGE];
            NSError *error =  [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_ADD_REPO_ERROR userInfo:@{NSLocalizedDescriptionKey:errorMsg?: NSLocalizedString(@"SERVICE_CONNECT_ERROR", nil)}];
            [self.delegate repoAuther:self authFailed:error];
        }
        
    }
}
@end
