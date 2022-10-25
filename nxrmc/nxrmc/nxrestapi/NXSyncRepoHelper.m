//
//  NXSyncRepoHelper.m
//  nxrmc
//
//  Created by EShi on 6/12/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSyncRepoHelper.h"
#import "NXCacheManager.h"
#import "NXRMCDef.h"
#import "NXRMCStruct.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXRemoveRepositoryAPI.h"
#import "NXGetRepositoryDetailsAPI.h"
#import "NXCenterTokenManager.h"
#import "NXLProfile.h"

typedef NS_ENUM(NSInteger, NXOneDriveBoundCase)
{
    NXONEDRIVEBOUNDED_UNSET = 1,
    NXONEDRIVEBOUNDED,
};

@interface NXSyncRepoHelper()

@end

@implementation NXSyncRepoHelper

+(instancetype) sharedInstance
{
    static NXSyncRepoHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


-(instancetype) init
{
    self = [super init];
    return self;
}




-(void) deletePreviousFailedAddRepoRESTRequest:(NSString *) cachedFileFlag
{
    if (cachedFileFlag) {
        NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
        NSString *fileName = [[cachedFileFlag componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
        
        NSURL *cachedURL = [NXCacheManager getRESTCacheURL];
        cachedURL = [cachedURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileName, NXREST_CACHE_EXTENSION]];;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:cachedURL error:nil];
    }
}


-(void) downloadServiceRepoInfoWithComplection:(DownloadLocalRepoInfoComplection) complectionBlcok
{
}

- (void) syncRepoInfoWithLocalRepoInfo:(NSArray *)localReposArray userProfile:(NXLProfile *)userProfile withCompletion:(SyncRepoInfoComplection) syncCompletion
{
    __weak typeof(self) weakSelf = self;
    NXGetRepositoryDetailsAPIRequest *getRepoAPI = [[NXGetRepositoryDetailsAPIRequest alloc] init];
    [getRepoAPI requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            
            syncCompletion(nil, nil, nil, error);
            
        }else
        {
            // 1. check local repo info and remote info, do add or delete
            NXGetRepositoryDetailsAPIResponse *getRepoResponse = (NXGetRepositoryDetailsAPIResponse *)response;
            if (getRepoResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NSMutableArray *addReposList = nil;
                NSMutableArray *delReposList = nil;
                NSMutableArray *updateReposList = nil;
                
                NSMutableArray *rmsRepoModelArray = [[NSMutableArray alloc] init];
                for (NXRMSRepoItem *rmsRepoItem in getRepoResponse.rmsRepoList) {
                    NXRepositoryModel *repoModel = [[NXRepositoryModel alloc] initWithRMSRepoItem:rmsRepoItem userProfile:userProfile];
                    [rmsRepoModelArray addObject:repoModel];
                }
                [self intergateRMSRepoInfoWithRMSRepoDetail:rmsRepoModelArray addRepoList:&addReposList delRepoList:&delReposList updateRepoList:&updateReposList withLocalRepoInfo:localReposArray];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // update local data
                    [weakSelf syncLocalServiceInfoWithAddedServices:addReposList deletedServices:delReposList updatedServices:updateReposList];
                    syncCompletion(addReposList, delReposList, updateReposList, nil);
                });
                
            }else{ // RMS server return error
                NSError *nxError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                syncCompletion(nil, nil, nil, nxError);
            }
        }
    }];

}

-(void) intergateRMSRepoInfoWithRMSRepoDetail:(NSMutableArray * )rmsRepoArray addRepoList:(NSMutableArray **) addReposList delRepoList:(NSMutableArray **) delReposList updateRepoList:(NSMutableArray **) updateReposList withLocalRepoInfo:(NSArray *)localReposArray
{
    *addReposList = [NSMutableArray arrayWithArray:rmsRepoArray];
    *delReposList = [NSMutableArray arrayWithArray:localReposArray];
    *updateReposList = [[NSMutableArray alloc] init];
    
    for (NXRepositoryModel *rmsRepoItem in rmsRepoArray) {
        for (NXRepositoryModel *localRepo in localReposArray) {
            if ([rmsRepoItem.service_id isEqualToString:localRepo.service_id]) {  // repo service id is same
                [*addReposList removeObject:rmsRepoItem];
                [*delReposList removeObject:localRepo];
                // if only dispaly name is different, make local repoId the same as RMS
                if (![localRepo.service_alias isEqualToString:rmsRepoItem.service_alias]) {
                    NSString *serviceAlias = localRepo.service_alias;
                    [localRepo setValue:rmsRepoItem.service_alias forKey:@"service_alias"];
                    // There need notify others service alias changed
                    NSDictionary *userInfo = @{serviceAlias:localRepo.service_alias};
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_ALIAS_UPDATED object:nil userInfo:userInfo];
                    });
                    [*updateReposList addObject:localRepo];
                }
                
            } // if repo service Id same
        } // for every [NXLoginUser sharedInstance].boundServices
    } // for every getRepoResponse.rmsRepoList
    
}

#pragma mark - private method
- (void)syncLocalServiceInfoWithAddedServices:(NSArray *)addedRepos deletedServices:(NSArray *)deletedRepos updatedServices:(NSArray *)updatedRepos {
    if (deletedRepos.count > 0)
    {
        for(NXRepositoryModel *repoModel in deletedRepos)
        {
            NSString *nxRepoUUID = NXREST_UUID(repoModel);
            [self deletePreviousFailedAddRepoRESTRequest:nxRepoUUID];
        }
    }
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
 
    if(service)
    {
        return NXONEDRIVEBOUNDED;
    }
    
    return NXONEDRIVEBOUNDED_UNSET;
}
@end
