//
//  NXSharePointOnlineAuther.m
//  nxrmc
//
//  Created by EShi on 11/1/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSharePointOnlineAuther.h"
#import "NXRMCDef.h"
#import "NXCloudAccountUserInforViewController.h"
#import "NXCommonUtils.h"
#import "NXGetAuthURLAPI.h"

@interface NXSharePointOnlineAuther() <NXCloudAccountUserInforViewControllerDelegate>

@end

@implementation NXSharePointOnlineAuther
#pragma mark - Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        _repoType = kServiceSharepointOnline;
    }
    return self;
}

#pragma mark - Overwrite

- (void) authRepoInViewController:(UIViewController *) vc
{
}

- (void)authRepoInViewController:(UIViewController *)vc repostioryAlias:(NSString *)repoAlias {
  
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
