//
//  NXSharePointAuther.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 16/05/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXSharePointAuther.h"
#import "NXRMCDef.h"
#import "NXCloudAccountUserInforViewController.h"
#import "NXCommonUtils.h"

@interface NXSharePointAuther() <NXCloudAccountUserInforViewControllerDelegate>

@end

@implementation NXSharePointAuther
#pragma mark - Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        _repoType = kServiceSharepoint;
    }
    return self;
}

- (void)authRepoInViewController:(UIViewController *)vc repostioryAlias:(NSString *)repoAlias isReAuth:(BOOL)isReAuth accountName:(NSString *)accountName repoId:(NSString *)repoId completBlock:(authRepositoryCompletion)compBlock
{
    self.authViewController = vc;
    
    NXCloudAccountUserInforViewController *SPAuthVC = [[NXCloudAccountUserInforViewController alloc] init];
    SPAuthVC.delegate = self;
    SPAuthVC.serviceBindType = kServiceSharepoint;
    SPAuthVC.repoName = repoAlias;
    SPAuthVC.isReAuth = isReAuth;
    SPAuthVC.accountName = accountName;
    SPAuthVC.repoId = repoId;
    
    SPAuthVC.addRepoAccountFinishBlock = ^(NXRepositoryModel *repoModel,NSError *error){
        [self.authViewController.navigationController popViewControllerAnimated:YES];
        compBlock(repoModel,error);
    };
    [vc.navigationController pushViewController:SPAuthVC animated:YES];
}

#pragma mark - Overwrite
- (void)authRepoInViewController:(UIViewController *) vc repostioryAlias:(NSString *)repoAlias
{
    self.authViewController = vc;
    
    NXCloudAccountUserInforViewController *SPAuthVC = [[NXCloudAccountUserInforViewController alloc] init];
    SPAuthVC.delegate = self;
    SPAuthVC.serviceBindType = kServiceSharepoint;
    SPAuthVC.repoName = repoAlias;
    
    SPAuthVC.addRepoAccountFinishBlock = ^(NXRepositoryModel *repoModel,NSError *error){
        if (!error) {
            [self.authViewController.navigationController popViewControllerAnimated:YES];
        }else{
            [NXCommonUtils showAlertViewInViewController:self.authViewController title:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription];
        }
    };
    
    [vc.navigationController pushViewController:SPAuthVC animated:YES];
}

- (void) authRepoInViewController:(UIViewController *) vc
{
    self.authViewController = vc;
    
    NXCloudAccountUserInforViewController *SPAuthVC = [[NXCloudAccountUserInforViewController alloc] init];
    SPAuthVC.delegate = self;
    SPAuthVC.serviceBindType = kServiceSharepoint;
    SPAuthVC.dismissBlock = ^(BOOL res){
        if (res) {
            [self.authViewController.navigationController popViewControllerAnimated:YES];
        }else
        {
            [NXCommonUtils showAlertViewInViewController:self.authViewController title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_REPO_ACCOUNT_EXISTED", nil)];
        }
        
    };
//    SPAuthVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [vc.navigationController pushViewController:SPAuthVC animated:YES];
}

- (void)authRepoWithRepostioryAlias:(NSString *)repoAlias {
  
}


#pragma mark - NXCloudAccountUserInforViewControllerDelegate
-(void) cloudAccountUserInfoVCDidPressCancelBtn:(NXCloudAccountUserInforViewController *)cloudAccountInfoVC
{
    if ([self.delegate respondsToSelector:@selector(repoAuthCanceled:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate repoAuthCanceled:self];
        });
    }
}

-(void) cloudAccountUserInfoDidAuthSuccess:(NSDictionary *) authInfo
{
    if ([self.delegate respondsToSelector:@selector(repoAuthCanceled:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate repoAuther:self didFinishAuth:authInfo];
        });
    }
}
@end
