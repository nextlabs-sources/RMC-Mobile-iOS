//
//  NXRepositoryFileSysManager.m
//  nxrmc
//
//  Created by EShi on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRepositorySysManager.h"
#import "NXRepository.h"
#import "NXRepoFileSync.h"
#import "NXGetRepoFileInFolderOperation.h"
#import "NXCommonUtils.h"
#import "NXRepositoryHelper.h"
#import "NXSyncRepoHelper.h"
#import "NXRepoFileFavOfflineSync.h"
#import "NXWebFileManager.h"
#import "NXNetworkHelper.h"
#import "NXUpdateRepositoryAPI.h"
#import "NXMyDriveFilesListVC.h"
#import "NXKeyChain.h"
#import "NXLProfile.h"
#import "NXRepoFileStorage.h"
#import "NXServiceProviderAPI.h"
@interface NXRepositorySysManager()<NXRepoFileSyncDelegate, NXRepositoryHelperDelegate, NXRepoFileFavOfflineSyncDelegate>
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, strong) NSMutableDictionary *boundRepositoriesDict;  // store all user bounded repositories key:repoId, value: NXRepository
@property(nonatomic, weak) id<NXRepoSystemFileInfoDelegate> getReposFilesDelegate;
@property(nonatomic, weak) id<NXRepoSystemFileInfoDelegate> syncFilsUnderFolderDelegate;
@property(nonatomic, strong) NXRepoFileSync *getReposFilesSyncOnce;
@property(nonatomic, strong) NXRepoFileSync *reposFilesSync;

@property(nonatomic, strong) NSMutableDictionary *completeBlockDict;  // store all kinds of block
@property(nonatomic, strong) NSMutableDictionary *fileOperationDict; // store all kindes of file operations

@property(nonatomic, weak) id<NXRepositorySysManagerBoundRepoDelegate> boundRepoDelegate;
@property(nonatomic, strong) NXRepositoryHelper *repoHelper;
@property(nonatomic, strong) NXRepoFileFavOfflineSync *favOfflineSync;

@property(nonatomic, assign, readwrite) NSTimeInterval lastUpdateRepoListTime;
@property(nonatomic, strong) NSMutableDictionary *tempReposFileDict;
@property(nonatomic, strong) dispatch_queue_t getRootFolderFileListQueue;

@property(nonatomic, weak) id<NXFileChooseFlowDataSorceDelegate> fileChooseDataSorceDelegate;
@property(nonatomic, strong) NSArray *supportedServiceTypes;
@end



@implementation NXRepositorySysManager
@synthesize boundRepositoriesDict = _boundRepositoriesDict;
@synthesize tempReposFileDict = _tempReposFileDict;
#pragma mark - Init/Getter/Setter/dealloc
- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        _tempReposFileDict = [[NSMutableDictionary alloc] init];
        _getRootFolderFileListQueue = dispatch_queue_create("com.skydrm.rmcent.NXRepositorySysManager.getRootFolderFileListQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setTempReposFileDict:(NSMutableDictionary *)tempReposFileDict
{
    @synchronized (self) {
        _tempReposFileDict = tempReposFileDict;
    }
}

- (NSMutableDictionary *)tempReposFileDict
{
    @synchronized (self) {
        return _tempReposFileDict;
    }
}
- (void)setLastUpdateRepoListTime:(NSTimeInterval)lastUpdateRepoListTime
{
    _lastUpdateRepoListTime = lastUpdateRepoListTime;
    dispatch_main_async_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_UPDATED object:nil];
    });
}
- (void)dealloc
{
    
}

-(void)bootupWithUserProfile:(NXLProfile *)profile
{
    // init user's repository
    _userProfile = profile;
    [self loadAllBoundServices];
    self.lastUpdateRepoListTime = [[NSDate date] timeIntervalSince1970];
    
    // start sync offline/fav
    NSMutableDictionary *currentFavOfflineDict = [[NSMutableDictionary alloc] init];
    
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull repoId, NXRepository*  _Nonnull repo, BOOL * _Nonnull stop) {
        NSMutableArray *favFilesFullServicePaths = [[NSMutableArray alloc] init];
        
        for (NXFileBase *fileBase in [repo allFavoriteFileItems]) {
            [favFilesFullServicePaths addObject:fileBase];
        }
        
        NSMutableSet *favSet = [[NSMutableSet alloc] initWithArray:favFilesFullServicePaths];
        NSDictionary *dict = @{FAV_FILES_KEY:favSet};
        [currentFavOfflineDict setObject:dict forKey:repoId];
    }];
//    self.favOfflineSync = [[NXRepoFileFavOfflineSync alloc] initWithCurrentLocalFavOfflineFileItems:currentFavOfflineDict userProfile:_userProfile];
//    self.favOfflineSync.delegate = self;
//    [self.favOfflineSync startSyncFavOfflineFromRMS];
    [self allSupportedServiceTypes];
    
}

- (void)getReposFilesOpt:(NXRepoFileSync *)repoFileSync
{
    [_getReposFilesSyncOnce stopSync];
    _getReposFilesSyncOnce = repoFileSync;
}

- (void)syncReposFilesOpt:(NXRepoFileSync *)repoFileSync
{
    [_reposFilesSync stopSync];
    _reposFilesSync = repoFileSync;
}

- (NSMutableDictionary *)boundRepositoriesDict
{
    @synchronized (self) {
        if (_boundRepositoriesDict == nil) {
            _boundRepositoriesDict = [[NSMutableDictionary alloc] init];
        }
        return _boundRepositoriesDict;
    }
}

- (void)setBoundRepositoriesDict:(NSMutableDictionary *)boundRepositoriesDict
{
    @synchronized (self) {
        if (_boundRepositoriesDict != boundRepositoriesDict) {
            _boundRepositoriesDict = boundRepositoriesDict;
        }
    }
}

- (NSMutableDictionary *)completeBlockDict
{
    @synchronized (self) {
        if (_completeBlockDict == nil) {
            _completeBlockDict = [[NSMutableDictionary alloc] init];
        }
        return _completeBlockDict;
    }
}

- (NSMutableDictionary *)fileOperationDict
{
    @synchronized (self) {
        if (_fileOperationDict == nil) {
            _fileOperationDict = [[NSMutableDictionary alloc] init];
        }
        return _fileOperationDict;
    }
}

- (void)loadAllBoundServices {
    
    NSArray* objects = [NXRepositoryStorage loadAllBoundServices];
    
    for (NXBoundService *service in objects) {
        NXRepository *repo = nil;
        repo = [[NXRepository alloc] initWithBoundService:service userProfile:self.userProfile];
        [self.boundRepositoriesDict setObject:repo forKey:repo.service_id];
    }
    self.lastUpdateRepoListTime = [[NSDate date] timeIntervalSince1970];
}

-(void)shutdown
{
    [self.favOfflineSync stopSyncFavOfflineFromRMS];
    [self.reposFilesSync stopSync];
    [self.boundRepositoriesDict removeAllObjects];
}
#pragma mark - Repository Operation
-(void)updateRepository:(NXRepositoryModel *)repoModel completion:(updateRepoCompletion)comp
{
    NXRepository *repo = self.boundRepositoriesDict[repoModel.service_id];
    if (repo == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(nil, error);
    }
    if (repo) {
        if(![repo.service_alias isEqualToString:repoModel.service_alias]){
            NXUpdateRepositoryRequest *updateRepoRequesdt = [[NXUpdateRepositoryRequest alloc] init];
            
            NXRMCRepoItem *repoItem = [[NXRMCRepoItem alloc] init];
            repoItem.service_id = repoModel.service_id;
            repoItem.service_alias = repoModel.service_alias;
            repoItem.service_type = repoModel.service_type;
            repoItem.service_account = repoModel.service_account;
            repoItem.service_account_id = repoModel.service_account_id;
            repoItem.service_account_token = repoModel.service_account_token;
            [updateRepoRequesdt requestWithObject:repoItem Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                if(error){
                    comp(nil, error);
                }else{
                    if ([response isKindOfClass:[NXUpdateRepositoryResponse class]]) {
                        if(((NXUpdateRepositoryResponse *)response).rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
                        {
                            [repo updateRepoInfo:repoModel];
                            dispatch_main_async_safe(^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_UPDATED object:nil];
                            });
                            // here we do not support async update, so directly return completion
                            comp([repo getModel], nil);
                        }else{
                            NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_UPDATE_REPO_INFO_ERROR", nil)}];
                            comp(nil, restError);
                        }
                    }
                }
            }];
        }else{
            [repo updateRepoInfo:repoModel];
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_UPDATED object:nil];
            });
            // here we do not support async update, so directly return completion
            comp([repo getModel], nil);
        }
    }
}

- (void)updateRepositoryArrayToSelectState:(NSArray *)repoModelArray;
{
    if (repoModelArray.count == 0) {
        return;
    }
    for (NXRepositoryModel *repoModel in repoModelArray) {
        repoModel.service_selected = [NSNumber numberWithBool:YES];
        NXRepository *repo = self.boundRepositoriesDict[repoModel.service_id];
        [repo updateRepoInfo:repoModel];
    }

    dispatch_main_async_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_UPDATED object:nil];
    });
}

- (void)updateRepositoryArrayToDeSelectState:(NSArray *)repoModelArray
{
    if (repoModelArray.count == 0) {
          return;
      }
      for (NXRepositoryModel *repoModel in repoModelArray) {
           repoModel.service_selected = [NSNumber numberWithBool:NO];
          NXRepository *repo = self.boundRepositoriesDict[repoModel.service_id];
          [repo updateRepoInfo:repoModel];
      }

      dispatch_main_async_safe(^{
          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_UPDATED object:nil];
      });
}

-(void)deleteRepository:(NXRepositoryModel *)repo completion:(deleteRepoCompletion)comp
{
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)}];
        comp(nil, error);
        return;
    }
    NXRepository *repository = self.boundRepositoriesDict[repo.service_id];
    if (repository == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(repo, error);
        return;
    }
    self.repoHelper = [[NXRepositoryHelper alloc] initWithUserProfile:self.userProfile];
    WeakObj(self);
    [self.repoHelper deleteRepository:repo withCompletion:^(NXRepositoryModel *repo, NSError *error) {
        StrongObj(self);
        if (error) {
            comp(repo, error);
            return;
        }else{
            NXRepository *repository = self.boundRepositoriesDict[repo.service_id];
            [repository destory];
            [[NXWebFileManager sharedInstance] cleanAllDownloadFileForRepository:repo];
            if (repository.service_type.integerValue == kServiceSharepoint) {
                NSString *sharepointPasswordKey = [NSString stringWithFormat:@"%@^%@", repository.service_account, repository.service_account_id];
                [NXKeyChain delete:sharepointPasswordKey];
                [NXKeyChain delete:repository.service_account_id];
            }
         
            [self.boundRepositoriesDict removeObjectForKey:repo.service_id];
            self.lastUpdateRepoListTime = [[NSDate date] timeIntervalSince1970];
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_UPDATED object:nil];
            });
            comp(repo, nil);
        }
    }];
}

- (NSString *)getRepositoryInfo:(NXRepositoryModel *)repoModel completion:(getRepoInfoCompletion)comp
{
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)}];
        comp(repoModel, nil, nil, nil, nil, error);
        return nil;
    }
    
    NXRepository *repo = self.boundRepositoriesDict[repoModel.service_id];
    if (repo == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(repoModel, nil, nil, nil, nil, error);
        return nil;
    }
    
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.completeBlockDict setObject:comp forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
    NSOperation *getRepoInfoOperation = [repo  getRepositoryInfowithCompletion:^(NXRepositoryModel *repo, NSString *userName, NSString *userEmail, NSNumber *totalQuota, NSNumber *usedQuota, NSError *error) {
        comp(repo, userName, userEmail, totalQuota, usedQuota, error);
        [weakSelf.completeBlockDict removeObjectForKey:operationIdentify];
        [weakSelf.fileOperationDict removeObjectForKey:operationIdentify];
    }];
    if (getRepoInfoOperation) {
        [self.fileOperationDict setObject:getRepoInfoOperation forKey:operationIdentify];
        [getRepoInfoOperation start];
    }
    return operationIdentify;
}

-(void)syncRepositoryWithCompletion:(syncRepositoryCompletion)comp
{
    __weak typeof(self) weakSelf = self;
    [[NXSyncRepoHelper sharedInstance] syncRepoInfoWithLocalRepoInfo:[self allReposiories] userProfile:self.userProfile withCompletion:^(NSArray *addRMCReposList, NSArray *delReposList, NSArray *updateReposList, NSError *error) {
        BOOL anyChanged = NO;
        
        // update all here
        ///////////////// FOR ADDED REPOSITORY  ////////////////
        for (NXRepositoryModel *repoModel in addRMCReposList) {
            // step1. build SDK enviroment
            [NXCommonUtils buildEnviromentForRepoSDK:repoModel];
            // step2. store to coredata
            [NXRepositoryStorage stroreRepoIntoCoreData:repoModel];
            // step3. add repo in repositorySysManager
            NXRepository *repo = [[NXRepository alloc] initWithRepoModel:repoModel userProfile:weakSelf.userProfile];
            [weakSelf.boundRepositoriesDict setObject:repo forKey:repo.service_id];
            anyChanged = YES;
        }
        
        ///////////////// FOR UPDATED REPOSITORY  ////////////////
        for (NXRepositoryModel *repoModel in updateReposList) {
            NXRepository *repo = [weakSelf.boundRepositoriesDict objectForKey:repoModel.service_id];
            if (repo) {
                [repo updateRepoInfo:repoModel];
                anyChanged = YES;
            }
        }
        
        ///////////////// FOR DELETED REPOSITORY  ////////////////
        for (NXRepositoryModel *repoModel in delReposList) {
            NXRepository *repo = [weakSelf.boundRepositoriesDict objectForKey:repoModel.service_id];
            if (repo) {
                
                // should delete sharepoint repo password in KeyChain
                if (repo.service_type.integerValue == kServiceSharepoint) {
                    NSString *sharepointPasswordKey = [NSString stringWithFormat:@"%@^%@", repo.service_account, repo.service_account_id];
                    [NXKeyChain delete:sharepointPasswordKey];
                    [NXKeyChain delete:repo.service_account_id];
                }
                
                [repo destory];
                [weakSelf.boundRepositoriesDict removeObjectForKey:repoModel.service_id];
            }
            anyChanged = YES;
        }
        
        // send notification
        if (anyChanged) {
            weakSelf.lastUpdateRepoListTime = [NSDate date].timeIntervalSince1970;
        }
        // call back
        comp([weakSelf allReposiories], weakSelf.lastUpdateRepoListTime, error);
    }];
}

-(void)boundRepositoryInViewController:(UIViewController *)vc repoType:(ServiceType) repoType withDelegate:(id<NXRepositorySysManagerBoundRepoDelegate>) boundRepoDelegate
{
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)}];
        [boundRepoDelegate nxRepositorySysManager:self didFailedBoundRepo:nil withError:error];
        return;
    }
    
    self.repoHelper = [[NXRepositoryHelper alloc] initWithUserProfile:self.userProfile];
    self.boundRepoDelegate = boundRepoDelegate;
    [self.repoHelper boundRepositoryInViewController:vc repoType:repoType withDelegate:self];
}

-(void)authRepositoyInViewController:(UIViewController *)vc forRepo:(NXRepositoryModel *)repo completion:(authRepoCompletion)comp
{
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)}];
        comp(nil, error);
        return;
    }
    
    NXRepository *repository = self.boundRepositoriesDict[repo.service_id];
    if (repository == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(repo, error);
        return;
    }
    
    self.repoHelper = [[NXRepositoryHelper alloc] initWithUserProfile:self.userProfile];
    WeakObj(self);
    [self.repoHelper authRepositoryInViewController:vc forRepository:repo withCompletion:^(NXRepositoryModel *repoModel, NSError *error) {
        if (!error) {
            StrongObj(self);
            NXRepository *repository = self.boundRepositoriesDict[repo.service_id];
            repository.service_isAuthed = repoModel.service_isAuthed;
            if (repository) {
                [repository updateRepoInfo:repoModel];
                [self.boundRepositoriesDict setObject:repository forKey:repo.service_id];
                self.lastUpdateRepoListTime = [[NSDate date] timeIntervalSince1970];
            }
        }else if(error.code == NXRMC_ERROR_CODE_REPOSITORY_NOT_EXIST){
            NXRepository *repo = [self.boundRepositoriesDict objectForKey:repoModel.service_id];
            if (repo) {
                [repo destory];
                [self.boundRepositoriesDict removeObjectForKey:repoModel.service_id];
                self.lastUpdateRepoListTime = [NSDate date].timeIntervalSince1970;
            }
        }
        self.repoHelper = nil;
        comp(repo, error);
    }];
}



-(NSArray *)allReposiories
{
    NSMutableArray *repoArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NXRepository *repo = (NXRepository *)obj;
        NXRepositoryModel *repoModel = [repo getModel];
        [repoArray addObject:repoModel];
    }];
    return repoArray;
}


- (NSArray *)allAuthReposiories
{
    NSMutableArray *repoArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NXRepository *repo = (NXRepository *)obj;
        NXRepositoryModel *repoModel = [repo getModel];
        if (repoModel.service_isAuthed.boolValue) {
            [repoArray addObject:repoModel];
        }
    }];
    return repoArray;
}
- (NSArray *)allApplicationRepositories {
    NSMutableArray *repoArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NXRepository *repo = (NXRepository *)obj;
        NXRepositoryModel *repoModel = [repo getModel];
        if (repoModel.service_isAuthed.boolValue && [repoModel.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", NULL)]) {
            [repoArray addObject:repoModel];
        }
    }];
    return repoArray;
    
}
- (NSArray *)allAuthReposioriesExceptApplicationRepos{
    NSMutableArray *repoArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NXRepository *repo = (NXRepository *)obj;
        NXRepositoryModel *repoModel = [repo getModel];
        if (repoModel.service_isAuthed.boolValue && ![repoModel.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", NULL)] && !(repoModel.service_type.integerValue == kServiceSkyDrmBox)) {
            [repoArray addObject:repoModel];
        }
    }];
    return repoArray;
    
}
- (NSArray *)allAuthApplicationRepos {
    NSMutableArray *repoArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NXRepository *repo = (NXRepository *)obj;
        NXRepositoryModel *repoModel = [repo getModel];
        if (repoModel.service_isAuthed.boolValue && [repoModel.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", NULL)]) {
            [repoArray addObject:repoModel];
        }
    }];
    return repoArray;
    
}
- (NSArray *)allAuthReposioriesExceptMyDrive {
    NSMutableArray *repoArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NXRepository *repo = (NXRepository *)obj;
        NXRepositoryModel *repoModel = [repo getModel];
        if (repoModel.service_isAuthed.boolValue && !(repoModel.service_type.integerValue == kServiceSkyDrmBox)) {
            [repoArray addObject:repoModel];
        }
    }];
    return repoArray;
    
}

- (NSArray *)allSupportedServiceTypes {
    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
        if (self.supportedServiceTypes == nil) {
            self.supportedServiceTypes = @[];
        }
        NXServiceProviderRequest *req = [[NXServiceProviderRequest alloc] init];
        WeakObj(self);
        [req requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            if (error == nil) {
                NXServiceProviderResponse *serviceTypeResponse = (NXServiceProviderResponse *)response;
                StrongObj(self);
                self.supportedServiceTypes = serviceTypeResponse.supportedServiceTypes;
            }
        }];
        
    }else {
        self.supportedServiceTypes = @[[NSNumber numberWithInteger:kServiceOneDrive],
                                              [NSNumber numberWithInteger:kServiceDropbox],
                                              [NSNumber numberWithInteger:kServiceGoogleDrive],
                                              [NSNumber numberWithInteger:kServiceBOX],
//                                              [NSNumber numberWithInteger:kServiceSharepoint],
//                                              [NSNumber numberWithInteger:kServiceSharepointOnline]
        ];
    }
    
    NSArray *sortedArray = [self.supportedServiceTypes sortedArrayUsingFunction:serviceTypeCompareFunction context:nil];
    return sortedArray;
}

NSComparisonResult serviceTypeCompareFunction(NSNumber * obj1, NSNumber * obj2, void *context) {
    if (obj1.integerValue == obj2.integerValue) {
        return NSOrderedSame;
    }else if(obj1.integerValue < obj2.integerValue) {
        return NSOrderedAscending;
    }else {
        return NSOrderedDescending;
    }
}


- (NXRepositoryModel *)getNextLabsRepository
{
    __block NXRepositoryModel *retModel = nil;
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NXRepository *repo = (NXRepository *)obj;
        NXRepositoryModel *repoModel = [repo getModel];
        if (repoModel.service_type.integerValue == kServiceSkyDrmBox) {
            retModel = repoModel;
        }
    }];
    
    return retModel;
}

- (NXRepositoryModel *)getRepositoryModelByFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo) {
        return [repo getModel];
    }else
    {
        return nil;
    }
}

- (NXRepositoryModel *)getRepositoryModelByRepoId:(NSString *)repoId
{
    NXRepository *repo = self.boundRepositoriesDict[repoId];
    if (repo) {
        return [repo getModel];
    }else
    {
        return nil;
    }
}

- (NXFileBase *)rootFolderForRepo:(NXRepositoryModel *)repoModel
{
    NXRepository *repo = self.boundRepositoriesDict[repoModel.service_id];
    if (repo) {
        return [repo getRepoRootFolder];
    }else
    {
        return nil;
    }
}

#pragma mark - File Operation
- (NXRepositoryModel *)getRepositoryOfFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo) {
        return [repo getModel];
    }else
    {
        NSAssert(NO, @"Codes should not reache here!");
        return nil;
    }
}
- (void)getFilesInRepositoriesFoldersDict:(NSDictionary *)reposFoldersDict readCache:(BOOL) readCache delegate:(id<NXRepoSystemFileInfoDelegate>)delegate
{
    NSMutableDictionary *getReposFolderDict = [[NSMutableDictionary alloc] initWithDictionary:reposFoldersDict];
    NSMutableArray *haveCacheRepo = [[NSMutableArray alloc] init];
    
    if (readCache) {
        // 1. first get from cache
        [getReposFolderDict enumerateKeysAndObjectsUsingBlock:^(NXRepositoryModel *  _Nonnull key, NXFileBase *  _Nonnull folder, BOOL * _Nonnull stop) {
            NXRepository *repo = self.boundRepositoriesDict[key.service_id];
            if (repo) {
                [repo getFileItemsCopyUnderFolder:folder onlyReadCache:YES shouldReadCache:YES withCompletion:^(NSArray *fileItems, NXFileBase *parentFolder, NSError *error) {
                    if (fileItems.count > 0) {
                        [self.tempReposFileDict setObject:@{folder:fileItems} forKey:key];
                        [haveCacheRepo addObject:key];
                    }
                }];
            }
        }];
    }
    
    if (haveCacheRepo.count > 0) {
        for (NXRepositoryModel *repoModel in haveCacheRepo) {
            [getReposFolderDict removeObjectForKey:repoModel];
        }
    }
    
    if (getReposFolderDict.allKeys.count > 0) {
        self.getReposFilesDelegate = delegate;
        [self.getReposFilesSyncOnce stopSync];
        self.getReposFilesSyncOnce = [[NXRepoFileSync alloc] init];
        self.getReposFilesSyncOnce.delegate = self;
        [self.getReposFilesSyncOnce startSyncFromRepoFolders:getReposFolderDict isOnceOperation:YES];
    }else{
        if (DELEGATE_HAS_METHOD(delegate, @selector(didGetFileListUnderParentFolder:fileList:error:))) {
            NXFolder *fileBase = [[NXFolder alloc] init];
            fileBase.isRoot = YES;
            fileBase.sorceType = NXFileBaseSorceTypeRepoFile;
            NSMutableArray *multiReposfileList = [[NSMutableArray alloc] init];
            WeakObj(self);
            [self.tempReposFileDict enumerateKeysAndObjectsUsingBlock:^(NXRepositoryModel *  _Nonnull key, NSDictionary *  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj allValues]) {
                    for (NSArray *fileItem in [obj allValues]) {
                        StrongObj(self);
                        NXRepositoryModel *repo = [self getRepositoryModelByRepoId:key.service_id];
                        if (repo.service_selected.boolValue) {
                            [multiReposfileList addObjectsFromArray:fileItem];

                        }
                    }
                }
            }];
            
            [delegate didGetFileListUnderParentFolder:fileBase fileList:multiReposfileList error:nil];
            [self.tempReposFileDict removeAllObjects];
        }
    }
}

- (void)getSelectedRepositoryRootFolderChildrenWithDelegate:(id<NXRepoSystemFileInfoDelegate>) delegate readCache:(BOOL) readCache
{
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] init];
    NSArray *repoModeArray = nil;
//    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
//        NXRepositoryModel *myDrive = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
//        repoModeArray = [NSArray arrayWithObject:myDrive];
//
//    }else{
        repoModeArray = [self allReposiories];
   // }

   
    for (NXRepositoryModel *repoMode in repoModeArray) {
        if (repoMode.service_selected.boolValue && repoMode.service_isAuthed.boolValue) {
            [queryDict setObject:[self rootFolderForRepo:repoMode] forKey:repoMode];
        }
    }
    
    [self getFilesInRepositoriesFoldersDict:queryDict readCache:readCache delegate:delegate];
}

- (void)syncFilesInRepositoriesFoldersDict:(NSDictionary *)reposFoldersDict delegate:(id<NXRepoSystemFileInfoDelegate>)delegate
{
    if (!self.syncFilsUnderFolderDelegate) {  // strage codes here.  For we use get file, sync file with one interface, so need check is get or sync file here
        self.getReposFilesDelegate = delegate;
    }
    [self.reposFilesSync stopSync];
    self.reposFilesSync = [[NXRepoFileSync alloc] init];
    self.reposFilesSync.delegate = self;
    [self.reposFilesSync startSyncFromRepoFolders:reposFoldersDict isOnceOperation:NO];
}

- (void)syncFilesInContentFolder:(NXFileBase *)contentFolder delegate:(id<NXRepoSystemFileInfoDelegate>)delegate
{
    self.syncFilsUnderFolderDelegate = delegate;
    
    if (contentFolder.isRoot && !contentFolder.repoId) { // this means get all selected repo's root folder
        NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] init];
       // hide other third repo
        NSArray *repoModeArray = nil;
//           if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
//               NXRepositoryModel *myDrive = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
//               repoModeArray = [NSArray arrayWithObject:myDrive];
//
//           }else{
               repoModeArray = [self allReposiories];
          // }

        for (NXRepositoryModel *repoMode in repoModeArray) {
            if (repoMode.service_selected.boolValue && repoMode.service_isAuthed.boolValue) {
                [queryDict setObject:[self rootFolderForRepo:repoMode] forKey:repoMode];
            }
        }
        
        [self syncFilesInRepositoriesFoldersDict:queryDict delegate:delegate];
        
    }else{
        NXRepositoryModel *repoModel = [self getRepositoryOfFileItem:contentFolder];
        if (repoModel) {
            NSDictionary *fileListQueryModel = @{repoModel:contentFolder};
            [self syncFilesInRepositoriesFoldersDict:fileListQueryModel delegate:delegate];
        }
    }
}

- (void)stopSyncFilesInRepositoriesFoldersDict:(NSDictionary *)reposFoldersDict
{
    [self.reposFilesSync stopSync];
    self.getReposFilesDelegate = nil;
    self.syncFilsUnderFolderDelegate = nil;
    self.reposFilesSync = nil;
}

- (void)stopSyncFilesInContentFolder:(NXFileBase *)contentFolder
{
    [self.reposFilesSync stopSync];
    self.getReposFilesDelegate = nil;
    self.reposFilesSync = nil;
    self.syncFilsUnderFolderDelegate = nil;
}

- (void)markFavFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo) {
        // sync fav property
        self.favOfflineSync.localFavOfflineLastOptTime = [[NSDate date] timeIntervalSince1970];
        NXFileBase *parent = [repo getParentOfFileItem:fileItem];
        [self.favOfflineSync markFavFile:fileItem withParent:parent];
        [repo markFavFileItem:fileItem];
        
    }
}

- (void)unmarkFavFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo) {
        self.favOfflineSync.localFavOfflineLastOptTime = [[NSDate date] timeIntervalSince1970];
        [self.favOfflineSync unmarkFavFile:fileItem];
        [repo unmarkFavFileItem:fileItem];
    }
    
}
- (void)markOfflineFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo) {
        [repo markOfflineFileItem:fileItem];
    }
}
- (void)unmarkOfflineFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo) {
        [repo unmarkOfflineFileItem:fileItem];
    }
}

- (NSArray *)allOfflineFileItems
{
    NSMutableArray *offlineFileArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, NXRepository* obj, BOOL * _Nonnull stop) {
        if(obj.service_selected.boolValue){
            [offlineFileArray addObjectsFromArray:[obj allOfflineFileItems]];
        }
    }];
    return offlineFileArray;
}
- (NSArray *)allFavoriteFileItems
{
    NSMutableArray *favoriteFileArray = [[NSMutableArray alloc] init];
    [self.boundRepositoriesDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, NXRepository* obj, BOOL * _Nonnull stop) {
        if (obj.service_selected.boolValue) {
            [favoriteFileArray addObjectsFromArray:[obj allFavoriteFileItems]];
        }
    }];
    return favoriteFileArray;
}

- (NSArray *)offlineFilesForRepository:(NXRepositoryModel *)repo
{
    NXRepository *repository = self.boundRepositoriesDict[repo.service_id];
    if (repository) {
        return [repository allOfflineFileItems];
    }
    return @[];
}
- (NSArray *)favFilesForRepository:(NXRepositoryModel *)repo
{
    NXRepository *repository = self.boundRepositoriesDict[repo.service_id];
    if (repository) {
        return [repository allFavoriteFileItems];
    }
    return @[];
}

- (NSUInteger)allRepoFiles
{
    return [NXRepoFileStorage allRepoFilesCount];
}

- (NSUInteger)allMyDriveFilesCount
{
     return [NXRepoFileStorage allMyDriveFilesCount];
}

- (void)fileListForParentFolder:(NXFileBase *)parentFolder readCache:(BOOL)readCache delegate:(id<NXRepoSystemFileInfoDelegate>)delegate
{
    self.getReposFilesDelegate = delegate;
    if (parentFolder.isRoot && parentFolder.repoId == nil) {
        WeakObj(self);
        dispatch_async(self.getRootFolderFileListQueue, ^{
            StrongObj(self);
            [self getSelectedRepositoryRootFolderChildrenWithDelegate:delegate readCache:readCache];
        });
    }else{
        WeakObj(self);
        [self getFileListUnderParentFolder:parentFolder readCache:readCache completion:^(NSArray *fileList, NXFileBase *parentFolder, NSError *error) {
            StrongObj(self);
            if (DELEGATE_HAS_METHOD(self.getReposFilesDelegate, @selector(didGetFileListUnderParentFolder:fileList:error:))) {
                [self.getReposFilesDelegate didGetFileListUnderParentFolder:parentFolder fileList:fileList error:error];
            }
        }];
    }
}

- (void)fileListForRepository:(NXRepositoryModel *)repo readCache:(BOOL)readCache delegate:(id<NXRepoSystemFileInfoDelegate>)delegate
{
    self.getReposFilesDelegate = delegate;
    NXFileBase *repoRootFolder = [self rootFolderForRepo:repo];
    WeakObj(self);
    [self getFileListUnderParentFolder:repoRootFolder readCache:readCache completion:^(NSArray *fileList, NXFileBase *parentFolder, NSError *error) {
        StrongObj(self);
        if (DELEGATE_HAS_METHOD(self.getReposFilesDelegate, @selector(didGetFileListUnderParentFolder:fileList:error:))) {
            [self.getReposFilesDelegate didGetFileListUnderParentFolder:parentFolder fileList:fileList error:error];
        }
    }];
}

- (NSString *)getFileListUnderParentFolder:(NXFileBase *)parentFolder readCache:(BOOL) readCache completion:(getFileListUnderParentFolderCompletion)comp
{
    NXRepository *repo = self.boundRepositoriesDict[parentFolder.repoId];
    if (repo == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(nil, parentFolder, error);
        return nil;
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.completeBlockDict setObject:comp forKey:operationIdentify];
    
    __weak typeof(self) weakSelf = self;
    NSOperation *getFileOperation = [repo getFileItemsCopyUnderFolder:parentFolder onlyReadCache:NO shouldReadCache:readCache withCompletion:^(NSArray *fileItems, NXFileBase *parentFolder, NSError *error) {
        getFileListUnderParentFolderCompletion getFileComp = weakSelf.completeBlockDict[operationIdentify];
        if (getFileComp) {
            getFileComp(fileItems, parentFolder, error);
        }
        [weakSelf.completeBlockDict removeObjectForKey:operationIdentify];
        [weakSelf.fileOperationDict removeObjectForKey:operationIdentify];
    }];
    
    if (getFileOperation) {
        [self.fileOperationDict setObject:getFileOperation forKey:operationIdentify];
        [getFileOperation start];
    }
    
    return operationIdentify;
}


- (NSString *)deleteFileItem:(NXFileBase *)fileItem completion:(deleteFileCompletion)comp
{
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)}];
        comp(nil, error);
        return nil;
    }
    
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(nil, error);
        return nil;
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    __weak typeof(self) weakSelf = self;
    NSOperation *deleteOperation = [repo deleteFile:fileItem withCompletion:^(NXFileBase *fileItem, NSError *error) {
        deleteFileCompletion delFileComp = weakSelf.completeBlockDict[operationIdentify];
        delFileComp(fileItem, error);
        if(!error){
            [[NXWebFileManager sharedInstance] unmarkFileAsOffine:fileItem];
        }
        [weakSelf.completeBlockDict removeObjectForKey:operationIdentify];
        [weakSelf.fileOperationDict removeObjectForKey:operationIdentify];
    }];
    
    if (deleteOperation) {
        [self.fileOperationDict setObject:deleteOperation forKey:operationIdentify];
        [self.completeBlockDict setObject:comp forKey:operationIdentify];
        [deleteOperation start];
    }
    
    return operationIdentify;
}

- (NSString *)createFolder:(NSString *)folderName inParent:(NXFileBase *)parentFolder completion:(createFolderCompletion)comp
{
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)}];
        comp(nil, nil, error);
        return nil;
    }
    
    NXRepository *repo = self.boundRepositoriesDict[parentFolder.repoId];
    if (repo == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(nil, nil, error);
        return nil;
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    __weak typeof(self) weakSelf = self;
    
    NSOperation *createOperation = [repo createFolder:folderName underParentFolder:parentFolder withCompletion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
        createFolderCompletion comp = weakSelf.completeBlockDict[operationIdentify];
        comp(fileItem, parentFolder, error);
        [weakSelf.completeBlockDict removeObjectForKey:operationIdentify];
        [weakSelf.fileOperationDict removeObjectForKey:operationIdentify];
    }];
    
    if (createOperation) {
        [self.fileOperationDict setObject:createOperation forKey:operationIdentify];
        [self.completeBlockDict setObject:comp forKey:operationIdentify];
        [createOperation start];
    }
    return operationIdentify;
}

- (NSString *)uploadFile:(NSString*)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXRepositorySysManagerUploadType) type overWriteFile:(NXFileBase *)overWriteFile progress:(NSProgress *)uploadProgress completion:(uploadFilesCompletion)comp;
{
    
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)}];
        comp(nil, nil, error);
        return nil;
    }
    
    NSFileManager *fileMgr  = [NSFileManager defaultManager];
    NSDictionary *dict = [fileMgr attributesOfItemAtPath:srcPath error:nil];
    unsigned long long size = [dict fileSize];
    if (size > RMS_MAX_UPLOAD_SIZE) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_UPLOAD_TO_MAX userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPLOAD_TO_MAX", nil)}];
        comp(nil, nil, error);
        return nil;
    }
    
    NXRepository *repo = self.boundRepositoriesDict[folder.repoId];
    if (repo == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(nil, nil, error);
        return nil;
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    
    __weak typeof(self) weakSelf = self;
    
    NXRepositoryUploadType uploadType;
    if (type == NXRepositorySysManagerUploadTypeNormal) {
        uploadType = NXRepositoryUploadTypeNormal;
    }else
    {
        uploadType = NXRepositoryUploadTypeOverWrite;
    }
    
    NSOperation *uploadOperation = [repo uploadFile:filename toPath:folder fromPath:srcPath uploadType:uploadType overWriteFile:overWriteFile progress:uploadProgress completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
        uploadFilesCompletion comp = weakSelf.completeBlockDict[operationIdentify];
        comp(fileItem, parentFolder, error);
        [weakSelf.completeBlockDict removeObjectForKey:operationIdentify];
        [weakSelf.fileOperationDict removeObjectForKey:operationIdentify];
    }];
    
    if (uploadOperation) {
        [self.fileOperationDict setObject:uploadOperation forKey:operationIdentify];
        [self.completeBlockDict setObject:comp forKey:operationIdentify];
        [uploadOperation start];
    }
    
    return operationIdentify;
}

- (void)cancelOperation:(NSString *)operationIdentify
{
    if (operationIdentify == nil) {
        return;
    }
    NSOperation *opt = self.fileOperationDict[operationIdentify];
    if (opt) {
        [opt cancel];
    }
}

-(NXFileBase *)parentForFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo == nil) {
        return nil;
    }else{
        return [repo getParentOfFileItem:fileItem];
    }
}

-(NSArray *)childForFileItem:(NXFileBase *)fileItem
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo == nil) {
        return nil;
    }else{
        return [repo getChildOfFileItem:fileItem];
    }
}

- (NSString *)queryFileMetaData:(NXFileBase *)fileItem completion:(queryFileMetaDataCompletion)comp
{
    NXRepository *repo = self.boundRepositoriesDict[fileItem.repoId];
    if (repo == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_NO_SUCH_REPO userInfo:nil];
        comp(nil, error);
        return nil;
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.completeBlockDict setObject:comp forKey:operationIdentify];
    
    WeakObj(self);
    NSOperation *queryFileMetaDataOperation = [repo queryFileMetaData:fileItem withCompletion:^(NXFileBase *metaData, NSError *error) {
        StrongObj(self);
        queryFileMetaDataCompletion comp = self.completeBlockDict[operationIdentify];
        comp(metaData, error);
        [self.completeBlockDict removeObjectForKey:operationIdentify];
        [self.fileOperationDict removeObjectForKey:operationIdentify];
    }];
    
    if (queryFileMetaDataOperation) {
        [self.fileOperationDict setObject:queryFileMetaDataOperation forKey:operationIdentify];
        [self.completeBlockDict setObject:comp forKey:operationIdentify];
    }
    
    [queryFileMetaDataOperation start];
    return operationIdentify;
}

#pragma mark - NXRepoFileSyncDelegate
- (void)updateFiles:(NSMutableDictionary *)repoFolderDict errors:(NSDictionary *) errors fromRepoFileSync:(NXRepoFileSync *)repoSync
{
    // step1. the new file list get from net should be merged to local info, then return. (Such as offline/fav info, repoId)
    NSArray *repoModelList = [repoFolderDict allKeys];
    for (NXRepositoryModel *repoModel in repoModelList) {
        NSError *repoUpdateFileError = errors[repoModel];
        if (repoUpdateFileError == nil) {
            NXRepository *repo = self.boundRepositoriesDict[repoModel.service_id];
            NSDictionary *getFileResult = repoFolderDict[repoModel];
            NSMutableDictionary *newGetFileResult = [[NSMutableDictionary alloc] init];
            
            NSArray *allKeys = [getFileResult allKeys];
            NXFolder *parentFolder = allKeys.firstObject;
            NSArray *file = getFileResult[parentFolder];
            // there update the off/fav info
            file = [repo updateFileItems:file underFolder:parentFolder];
            
            newGetFileResult[parentFolder] = file;
            
            [repoFolderDict setObject:newGetFileResult forKey:repoModel];
        }
    }
    // step2. transfer data into easy under way
    NSMutableArray *multiReposfileList = [[NSMutableArray alloc] init];
    [repoFolderDict enumerateKeysAndObjectsUsingBlock:^(NXRepositoryModel *  _Nonnull key, NSDictionary *  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj allValues]) {
            for (NSArray *fileItem in [obj allValues]) {
                NXRepositoryModel *repo = [self getRepositoryModelByRepoId:key.service_id];
                if (![self.syncFilsUnderFolderDelegate isKindOfClass:[NXMyDriveFilesListVC class]]) { // 大污！！！！！！！！ 这里是为了使MyDriveTab选中而MyDrive未选中问题!!!!!
                    if (repo.service_selected.boolValue) {
                        [multiReposfileList addObjectsFromArray:fileItem];
                    }
                }else{
                    [multiReposfileList addObjectsFromArray:fileItem];
                }
            }
            
        }
    }];
    NXFileBase *syncFolder = [repoSync syncFolders].firstObject;
    NSString *repoId = syncFolder.repoId;
    if (syncFolder.isRoot) {
        syncFolder = [[NXFolder alloc] init];
        syncFolder.isRoot = YES;
        syncFolder.sorceType = NXFileBaseSorceTypeRepoFile;
        if([self.syncFilsUnderFolderDelegate isKindOfClass:[NXMyDriveFilesListVC class]]){  // 大污！！！！！！！！ 这里是为了区分MyDriveViewControllert同步返回的问题!!!!!
            syncFolder.repoId = repoId;
        }
    }
    
    NSError *retError = nil;
    // display error content
    if ([errors allKeys].count > 0) {
        NSString *errorMsg = NSLocalizedString(@"MSG_COM_GETFILE_FAIL", nil);
        NSError *qqError = errors.allValues.firstObject;
        if (qqError.localizedDescription) {
            errorMsg = qqError.localizedDescription;
        }
        NSArray *repoArrays = [errors allKeys];
        for (NXRepositoryModel *repo in repoArrays) {
            if (repo == repoArrays.firstObject) {
                errorMsg = [errorMsg stringByAppendingFormat:@" from %@", repo.service_alias];
            }else
            {
                errorMsg = [errorMsg stringByAppendingFormat:@", %@", repo.service_alias];
            }
        }
        errorMsg = [errorMsg stringByAppendingString:@"."];
        
        retError = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_ROOT_FOLDERS_CHILDREN_FAILED userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
    }
    
    // step3. notifiy delegate
    if (DELEGATE_HAS_METHOD(self.getReposFilesDelegate, @selector(updateFileListFromParentFolder:resultFileList:error:))) {
        
        [self.getReposFilesDelegate updateFileListFromParentFolder:syncFolder resultFileList:multiReposfileList error:retError];
    }
    
    if (DELEGATE_HAS_METHOD(self.syncFilsUnderFolderDelegate, @selector(updateFileListFromParentFolder:resultFileList:error:))) {
        
        [self.syncFilsUnderFolderDelegate updateFileListFromParentFolder:syncFolder resultFileList:multiReposfileList error:retError];
    }
    
}
- (void)getFiles:(NSMutableDictionary *)repoFolderDict errors:(NSDictionary *) errors fromRepoFileSync:(NXRepoFileSync *)repoSync
{
    WeakObj(self);
    dispatch_async(self.getRootFolderFileListQueue, ^{
        StrongObj(self);
        // step1. update file list in file system tree
        NSArray *repoModelList = [repoFolderDict allKeys];
        for (NXRepositoryModel *repoModel in repoModelList) {
            NSError *repoUpdateFileError = errors[repoModel];
            if (repoUpdateFileError == nil) {
                NXRepository *repo = self.boundRepositoriesDict[repoModel.service_id];
                NSDictionary *getFileResult = repoFolderDict[repoModel];
                NSMutableDictionary *newGetFileResult = [[NSMutableDictionary alloc] init];
                
                NSArray *allKeys = [getFileResult allKeys];
                NXFolder *parentFolder = allKeys.firstObject;
                NSArray *file = getFileResult[parentFolder];
                // there update the off/fav info
                file = [repo updateFileItems:file underFolder:parentFolder];
                
                newGetFileResult[parentFolder] = file;
                
                [repoFolderDict setObject:newGetFileResult forKey:repoModel];
            }
        }
        
        // step2. notifiy delegate
        NSMutableDictionary *retDict = [[NSMutableDictionary alloc] initWithDictionary:repoFolderDict];
        [self.tempReposFileDict enumerateKeysAndObjectsUsingBlock:^(NXRepositoryModel *  _Nonnull key, NSDictionary *  _Nonnull obj, BOOL * _Nonnull stop) {
            [retDict setObject:obj forKey:key];
        }];
        
        [self.tempReposFileDict removeAllObjects];
        NXFolder *fileBase = [[NXFolder alloc] init];
        fileBase.isRoot = YES;
        fileBase.sorceType = NXFileBaseSorceTypeRepoFile;
        NSMutableArray *multiReposfileList = [[NSMutableArray alloc] init];
        [retDict enumerateKeysAndObjectsUsingBlock:^(NXRepositoryModel *  _Nonnull key, NSDictionary *  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj allValues]) {
                for (NSArray *fileItem in [obj allValues]) {
                    NXRepositoryModel *repo = [self getRepositoryModelByRepoId:key.service_id];
                    if (repo.service_selected.boolValue) {
                        [multiReposfileList addObjectsFromArray:fileItem];
                        
                    }
                }
            }
        }];
        
        NSError *error = nil;
        // display error content
        if ([errors allKeys].count > 0) {
            NSString *errorMsg = NSLocalizedString(@"MSG_COM_GETFILE_FAIL", nil);
            NSError *qqError = errors.allValues.firstObject;
            if (qqError.localizedDescription) {
               errorMsg = qqError.localizedDescription;
            }
            NSArray *repoArrays = [errors allKeys];
            for (NXRepositoryModel *repo in repoArrays) {
                if (repo == repoArrays.firstObject) {
                    errorMsg = [errorMsg stringByAppendingFormat:@" from %@", repo.service_alias];
                }else
                {
                    errorMsg = [errorMsg stringByAppendingFormat:@", %@", repo.service_alias];
                }
            }
            errorMsg = [errorMsg stringByAppendingString:@"."];
            
            error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_ROOT_FOLDERS_CHILDREN_FAILED userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
        }
        
        if (DELEGATE_HAS_METHOD(self.getReposFilesDelegate, @selector(didGetFileListUnderParentFolder:fileList:error:))) {
            [self.getReposFilesDelegate didGetFileListUnderParentFolder:fileBase fileList:multiReposfileList error:error];
        }
        
        if (DELEGATE_HAS_METHOD(self.syncFilsUnderFolderDelegate, @selector(updateFileListFromParentFolder:resultFileList:error:))) {
            [self.syncFilsUnderFolderDelegate updateFileListFromParentFolder:fileBase resultFileList:multiReposfileList error:error];
        }
    });
}

#pragma mark - NXRepositoryHelperDelegate
- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper repository:(NXRepositoryModel *)repo inputRepositoryAliasHandler:(void(^)(NXRepositorySysManagerBoundRepoInputAliasOption processOpt, NSString *inputAlias)) processHandler
{
    if(DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositorySysManager:boundRepo:inputRepositoryAliasHandler:)))
    {
        [self.boundRepoDelegate nxRepositorySysManager:self boundRepo:repo inputRepositoryAliasHandler:processHandler];
    }
}

- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper didSuccessfullyBoundRepo:(NXRepositoryModel *)repo
{
    // Add new repo into repo list
    NXRepository *newRepo = [[NXRepository alloc] initWithRepoModel:repo userProfile:self.userProfile];
    [self.boundRepositoriesDict setObject:newRepo forKey:newRepo.service_id];
    self.lastUpdateRepoListTime = [[NSDate date] timeIntervalSince1970];
    if (DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositorySysManager:didSuccessfullyBoundRepo:))) {
        [self.boundRepoDelegate nxRepositorySysManager:self didSuccessfullyBoundRepo:repo];
    }
    self.repoHelper = nil;
}

- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper didFailedBoundRepo:(NXRepositoryModel *)repo withError:(NSError *)error
{
    if (DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositorySysManager:didFailedBoundRepo:withError:))) {
        [self.boundRepoDelegate nxRepositorySysManager:self didFailedBoundRepo:repo withError:error];
    }
    self.repoHelper = nil;
}

- (void)nxRepositoryHelper:(NXRepositoryHelper *)repoHelper didCancelBoundRepo:(NXRepositoryModel *)repo
{
    if (DELEGATE_HAS_METHOD(self.boundRepoDelegate, @selector(nxRepositorySysManager:didCancelBoundRepo:))) {
        [self.boundRepoDelegate nxRepositorySysManager:self didCancelBoundRepo:repo];
    }
    
    self.repoHelper = nil;
}

#pragma mark - NXRepoFileFavOfflineSyncDelegate
- (void)offlineFavSync:(NXRepoFileFavOfflineSync *)sync favOfflineFileItemsDict:(NSDictionary *)dict
{
    __weak typeof(self) weakSelf = self;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull repoId, NSDictionary *  _Nonnull repoFavOfflineDict, BOOL * _Nonnull stop) {
        NXRepository *repo = weakSelf.boundRepositoriesDict[repoId];
        if(repo){
            [repo updateFavFileItemList:repoFavOfflineDict[FAV_FILES_KEY]];
        }
    }];
}

#pragma mark - NXFileChooseFlowDataSorceDelegate
- (void)fileListUnderFolder:(NXFolder *)parentFolder withCallBackDelegate:(id<NXFileChooseFlowDataSorceDelegate>)delegate
{
    self.fileChooseDataSorceDelegate = delegate;
    WeakObj(self);
    [self getFileListUnderParentFolder:parentFolder readCache:YES completion:^(NSArray *fileList, NXFileBase *parentFolder, NSError *error) {
        StrongObj(self);
        if (self && self.fileChooseDataSorceDelegate) {
            if(DELEGATE_HAS_METHOD(self.fileChooseDataSorceDelegate, @selector(fileChooseFlowDidGetFileList:underParentFolder:error:))){
                [self.fileChooseDataSorceDelegate fileChooseFlowDidGetFileList:fileList underParentFolder:(NXFolder *)parentFolder error:error];
                self.fileChooseDataSorceDelegate = nil;
                
            }
        }
    }];
}

- (NXFileBase *)queryParentFolderForFolder:(NXFileBase *)folder {
    return [self parentForFileItem:folder];
}
@end
