//
//  NXRepositoryHelper.h
//  nxrmc
//
//  Created by EShi on 1/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRepositorySysManager.h"

@class NXRepositoryHelper;

@protocol NXRepositoryHelperDelegate <NSObject>

// bound repo
@required
- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper repository:(NXRepositoryModel *)repo inputRepositoryAliasHandler:(void(^)(NXRepositorySysManagerBoundRepoInputAliasOption processOpt, NSString *inputAlias)) processHandler;
- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper didSuccessfullyBoundRepo:(NXRepositoryModel *)repo;
- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper didFailedBoundRepo:(NXRepositoryModel *)repo withError:(NSError *)error;
- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper didCancelBoundRepo:(NXRepositoryModel *)repo;
@end



typedef void(^authRepositoryCompletion)(NXRepositoryModel *repo, NSError *error);
typedef void(^deleteRepositoryCompletion)(NXRepositoryModel *repo, NSError *error);

// This class is used to add/update/auth/delete/get repositories, but won't store any repository
@interface NXRepositoryHelper : NSObject
- (instancetype) initWithUserProfile:(NXLProfile *)userProfile;
- (void)boundRepositoryInViewController:(UIViewController *)vc repoType:(ServiceType) repoType withDelegate:(id<NXRepositoryHelperDelegate>) boundRepoDelegate;
- (void)authRepositoryInViewController:(UIViewController *)vc forRepository:(NXRepositoryModel *)repository withCompletion:(authRepoCompletion)authRepoCompletion;
- (void)deleteRepository:(NXRepositoryModel *)repository withCompletion:(deleteRepositoryCompletion)deleteRepoCompletion;
@end
