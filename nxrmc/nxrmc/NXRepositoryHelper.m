//
//  NXRepositoryHelper.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 12/26/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRepositoryHelper.h"
#import "NXGetAuthURLAPI.h"
#import "NXRepoAuthStrategy.h"
#import "NXRemoveRepositoryAPI.h"
#import "NXSharePointAuther.h"
#import "NXLProfile.h"
typedef void(^repoHelperNeedRepoAliasHandler)(NXRepositorySysManagerBoundRepoInputAliasOption processOpt, NSString *inputAlias);

@interface NXRepositoryHelper()<NXRepoAutherDelegate>
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, weak) id<NXRepositoryHelperDelegate> boundRepoDelegate;
@property(nonatomic, strong) id<NXRepoAutherBase> repoAuther;
@property(nonatomic, strong) repoHelperNeedRepoAliasHandler inputRepoAliasHandler;
@property(nonatomic, strong) NXRepositoryModel *repoModel;
@end

@implementation NXRepositoryHelper
- (instancetype) initWithUserProfile:(NXLProfile *)userProfile {
    if (self = [super init]) {
        _userProfile = userProfile;
    }
    return self;
}

- (void)boundRepositoryInViewController:(UIViewController *)vc repoType:(ServiceType) repoType withDelegate:(id<NXRepositoryHelperDelegate>) boundRepoDelegate {
    id<NXRepoAutherBase> repoAuther = [NXRepoAuthStrategy repoAutherByRepoType:repoType];
    repoAuther.delegate = self;
    self.repoAuther = repoAuther;
    self.boundRepoDelegate = boundRepoDelegate;
    WeakObj(self);
    _inputRepoAliasHandler = ^(NXRepositorySysManagerBoundRepoInputAliasOption processOpt, NSString *inputAlias){
        StrongObj(self);
        if (self) {
            [self processInputAlias:processOpt repoAlias:inputAlias boundInViewController:vc];
        }
    };
    
    if (DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositoryHelper:repository:inputRepositoryAliasHandler:))) {
        [self.boundRepoDelegate nxRepositoryHelper:self repository:nil inputRepositoryAliasHandler:_inputRepoAliasHandler];
    }
    
}

- (void)authRepositoryInViewController:(UIViewController *)vc forRepository:(NXRepositoryModel *)repository withCompletion:(authRepoCompletion)authRepoCompletion {
    
    id<NXRepoAutherBase> repoAuther = [NXRepoAuthStrategy repoAutherByRepoType:repository.service_type.integerValue];
    repoAuther.delegate = self;
    self.repoAuther = repoAuther;
    
    if ([repoAuther isKindOfClass:[NXSharePointAuther class]]) {
        NXSharePointAuther *repoAu = (NXSharePointAuther *)repoAuther;
        [repoAu authRepoInViewController:vc repostioryAlias:repository.service_alias isReAuth:YES accountName:repository.service_account repoId:repository.service_id completBlock:^(NXRepositoryModel *repoModel, NSError *error) {
            authRepoCompletion(repoModel,error);
        }];
    }
}

- (void)deleteRepository:(NXRepositoryModel *)repository withCompletion:(deleteRepositoryCompletion)deleteRepoCompletion {
    NXRemoveRepositoryAPIRequest *removeRepoRequest = [[NXRemoveRepositoryAPIRequest alloc] init];
    [removeRepoRequest requestWithObject:repository.service_id Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (response && [response isKindOfClass:[NXRemoveRepositoryAPIResponse class]]) {
            if (((NXRemoveRepositoryAPIResponse *)response).rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS || ((NXRemoveRepositoryAPIResponse *)response).rmsStatuCode == NXRMS_ERROR_CODE_NOT_FOUND || ((NXRemoveRepositoryAPIResponse *)response).rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS_NO_NEED_REFRESH) { // NXRMS_ERROR_CODE_SUCCESS success, NXRMS_ERROR_CODE_NOT_FOUND means RMS do not have this repo
                deleteRepoCompletion(repository, nil);
            }else{
                deleteRepoCompletion(repository, REMOVE_REPO_ERROR);
            }
        }else
        {
            deleteRepoCompletion(repository, REMOVE_REPO_ERROR);
        }
    }];
}

- (void)processInputAlias:(NXRepositorySysManagerBoundRepoInputAliasOption) processOption repoAlias:(NSString *)repoName boundInViewController:(UIViewController *)boundInViewController {
    if (processOption == NXRepositorySysManagerBoundRepoInputAliasCancel) {
        if (DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositoryHelper:didCancelBoundRepo:))) {
            [self.boundRepoDelegate nxRepositoryHelper:self didCancelBoundRepo:nil];
        }
    }else if (processOption == NXRepositorySysManagerBoundRepoInputAliasProcess) {
        if (self.repoAuther.repoType == kServiceSharepoint || self.repoAuther.repoType == kServiceSharepointOnline) {
            [self.repoAuther authRepoInViewController:boundInViewController repostioryAlias:repoName];
        }else{
            [self.repoAuther authRepoWithRepostioryAlias:repoName];
        }
    }
}

#pragma mark - NXRepoAutherDelegate
-(void) repoAuther:(id<NXRepoAutherBase>) repoAuther didFinishAuth:(NSDictionary *) authInfo {
    self.repoModel = [[NXRepositoryModel alloc] initWithAccountInfoDict:authInfo];
    [self.repoModel setValue:[NSNumber numberWithInteger:self.userProfile.userId.integerValue] forKey:@"user_id"];
    [NXRepositoryStorage stroreRepoIntoCoreData:self.repoModel];
    
    if (DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositoryHelper:didSuccessfullyBoundRepo:))) {
        [self.boundRepoDelegate nxRepositoryHelper:self didSuccessfullyBoundRepo:[self.repoModel copy]];
    }
}
-(void) repoAuther:(id<NXRepoAutherBase>) repoAuther authFailed:(NSError *) error {
    if(DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositoryHelper:didFailedBoundRepo:withError:))) {
        [self.boundRepoDelegate nxRepositoryHelper:self didFailedBoundRepo:self.repoModel withError:error];
    }
}

-(void) repoAuthCanceled:(id<NXRepoAutherBase>) repoAuther {
    if(DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositoryHelper:didCancelBoundRepo:))) {
        [self.boundRepoDelegate nxRepositoryHelper:self didCancelBoundRepo:self.repoModel];
    }
}
@end
