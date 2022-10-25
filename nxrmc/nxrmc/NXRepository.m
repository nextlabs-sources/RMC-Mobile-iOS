//
//  NXRepository.m
//  nxrmc
//
//  Created by EShi on 12/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRepository.h"
#import "NXGetRepoFileInFolderOperation.h"
#import "NXRepoFileSysTree.h"
#import "NXGetRepoFileInFolderOperation.h"
#import "NXDeleteRepoFileItemOperation.h"
#import "NXCreateFolderInRepoOperation.h"
#import "NXUploadFileToFolderInRepoOperation.h"
#import "NXDownloadRepoFileOperation.h"
#import "NXGetRepositoryInfoOperation.h"
#import "NXCommonUtils.h"
#import "AppDelegate.h"
#import "NXCacheManager.h"
#import "NXQueryFileMetaDataOperation.h"
#import "GTMAppAuth.h"
#import "NXLProfile.h"
@interface NXRepository()
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, strong) NXRepoFileSysTree *repoFileSysTree;
@end

@implementation NXRepository
- (void) updateRepoInfo:(NXRepositoryModel *)repoModel
{
    // 1. update property info
    self.service_account = [repoModel.service_account copy];
    self.service_account_id = [repoModel.service_account_id copy];
    self.service_account_token = [repoModel.service_account_token copy];
    self.service_alias = [repoModel.service_alias copy];
    self.service_id = [repoModel.service_id copy];
    self.service_selected = [repoModel.service_selected copy];
    self.service_type = [repoModel.service_type copy];
    self.user_id = [repoModel.user_id copy];
    self.service_isAuthed = [repoModel.service_isAuthed copy];
    self.service_providerClass = [repoModel.service_providerClass copy];
    

    
    // 3. update core data
    [NXRepositoryStorage updateBoundRepoInCoreData:[self getModel]];
    
    // 4. update boundService
    self.boundService = [NXRepositoryStorage getBoundServiceByRepoModel:[self getModel]];
    
    // 2. update repoFileSys tree
    self.repoFileSysTree.repo = [self getModel];
    
}

-(instancetype) initWithBoundService:(NXBoundService *)boundService userProfile:(NXLProfile *)profile
{
    self = [super init];
    if (self) {
        _service_account = [boundService.service_account copy];
        _service_account_id = [boundService.service_account_id copy];
        _service_account_token = [boundService.service_account_token copy];
        _service_alias = [boundService.service_alias copy];
        _service_id = [boundService.service_id copy];
        _service_selected = [boundService.service_selected copy];
        _service_type = [boundService.service_type copy];
        _user_id = [boundService.user_id copy];
        _service_isAuthed = [boundService.service_isAuthed copy];
        _service_providerClass = [boundService.service_providerClass copy];
        _userProfile = profile;
    }
    return self;
}

-(instancetype) initWithRepoModel:(NXRepositoryModel *)repoModel userProfile:(NXLProfile *)profile
{
    self = [super init];
    if (self) {
        _service_account = [repoModel.service_account copy];
        _service_account_id = [repoModel.service_account_id copy];
        _service_account_token = [repoModel.service_account_token copy];
        _service_alias = [repoModel.service_alias copy];
        _service_id = [repoModel.service_id copy];
        _service_selected = [repoModel.service_selected copy];
        _service_type = [repoModel.service_type copy];
        _user_id = [repoModel.user_id copy];
        _service_isAuthed = [repoModel.service_isAuthed copy];
        _service_providerClass = [repoModel.service_providerClass copy];
        
        _userProfile = profile;
    }
    return self;
}

-(NXRepoFileSysTree *)repoFileSysTree
{
    @synchronized (self) {
        if (_repoFileSysTree == nil) {
            _repoFileSysTree = [[NXRepoFileSysTree alloc] initWithRepoModel:[self getModel]];
        }
        return _repoFileSysTree;
        
    }
}


-(NXRepositoryModel *)getModel
{
    NXRepositoryModel *model = [[NXRepositoryModel alloc] initWithRepository:self];
    return model;
}

#pragma mark - File operation
- (void)addFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder
{
    [self.repoFileSysTree addFileItems:fileItems underFolder:parentFolder];
}

- (NSArray *)updateFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder
{
    [self.repoFileSysTree updateFileItems:fileItems underFolder:parentFolder];
    // return local file sys tree, this will include fav/offline info
    return [self.repoFileSysTree getFileItemsCopyUnderFolder:parentFolder];
}

- (void)destory
{
    // 1. destory file tree
    [self.repoFileSysTree destroy];
    // 2. clean up local repository data
    [self cleanUpLocalRepostioryData:[self getModel]];
}

- (NXFileBase *)getRepoRootFolder
{
    return [self.repoFileSysTree getRootFolderCopy];
}

- (NSOperation *)getFileItemsCopyUnderFolder:(NXFileBase *)parentFolder onlyReadCache:(BOOL)onlyReadCache shouldReadCache:(BOOL) shouldReadCache withCompletion:(repoGetFilesUnderFolderCompletion) completion
{
    //step1. first get from cache
    NSArray *fileItemArray = nil;
    if(onlyReadCache || shouldReadCache){
        fileItemArray = [self.repoFileSysTree getFileItemsCopyUnderFolder:parentFolder];
    }
    if (fileItemArray.count > 0) {
        completion(fileItemArray, parentFolder, nil);
        if (onlyReadCache) {
            return nil;
        }
    }
     __weak typeof(self) weakSelf = self;
     // step2. second get from net work
     NXGetRepoFileInFolderOperation *getFileOpt = [[NXGetRepoFileInFolderOperation alloc] initWithParentFolder:(NXFolder *)parentFolder repository: [self getModel]];
    getFileOpt.getFileCompletion = ^(NSArray *fileList, NXFileBase *folder, NXRepositoryModel* repo, NSError *error){
        if (!error) {
            [weakSelf.repoFileSysTree updateFileItems:fileList underFolder:folder];
              
        }
        NSArray *newFileList = [weakSelf.repoFileSysTree getFileItemsCopyUnderFolder:folder];
        completion(newFileList, folder, error);
    };
    return getFileOpt;
}

-(NSOperation *)deleteFile:(NXFileBase *)fileItem withCompletion:(repoDeleteFileUnderFolderCompletion) completion
{
    // step1. first delete it from cloud repository
    __weak typeof(self) weakSelf = self;
    NXDeleteRepoFileItemOperation *delOpt = [[NXDeleteRepoFileItemOperation alloc] initWithDeleteFileItem:fileItem repository:[self getModel]];
    delOpt.delFileCompletion = ^(NXFileBase *fileItem, NXRepositoryModel* repo, NSError *error){
        if (!error) {
            [weakSelf.repoFileSysTree deleteFileItem:fileItem];
        }
        completion(fileItem, error);
    };
    return delOpt;

}

-(NSOperation *)createFolder:(NSString *)folderName underParentFolder:(NXFileBase *)parentFolder withCompletion:(repoCreateFolderUnderFolderCompletion) completion
{
    // step1. first delete it from cloud repository
    __weak typeof(self) weakSelf = self;
    NXCreateFolderInRepoOperation *createFolderOpt = [[NXCreateFolderInRepoOperation alloc] initWithFolderName:folderName underFolder:parentFolder repository:[self getModel]];
    createFolderOpt.createFolderComp = ^(NXFileBase *fileItem, NXRepositoryModel* repo, NSError *error){
        if (!error && fileItem) {
            [weakSelf.repoFileSysTree addFileItem:fileItem underFolder:parentFolder];
        }
        completion(fileItem, parentFolder, error);
    };
    return createFolderOpt;
}

-(NSOperation *)uploadFile:(NSString*)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXRepositoryUploadType)type overWriteFile:(NXFileBase *)overWriteFile progress:(NSProgress *)uploadProgress completion:(repoUploadFilesCompletion)comp
{
    BOOL isOverwrite = NO;
    if (type == NXRepositoryUploadTypeOverWrite) {
        isOverwrite = YES;
    }
    __weak typeof(self) weakSelf = self;
    NXUploadFileToFolderInRepoOperation *uploadOpt = [[NXUploadFileToFolderInRepoOperation alloc] initWithUploadFile:filename andIsOverwrite:isOverwrite fromPath:srcPath parentFolder:folder repository:[self getModel]];
    uploadOpt.uploadFileCompletion = ^(NXFileBase *fileItem, NXFileBase *parentFolder, NXRepositoryModel* repo, NSError *error){
        if (!error && fileItem) {
            [weakSelf.repoFileSysTree addFileItem:fileItem underFolder:parentFolder];
        }
        comp(fileItem, parentFolder, error);
    };
    uploadOpt.uploadProgress = uploadProgress;
    return uploadOpt;
    
}

- (NSOperation *)downloadFile:(NXFileBase *)file progress:(NSProgress *)downloadProgress withCompletion:(repoDownloadFileCompletion)complete
{
    NXDownloadRepoFileOperation *downloadOpt = [[NXDownloadRepoFileOperation alloc] initWithDestFile:file repository:[self getModel]];
    downloadOpt.downloadProgress = downloadProgress;
    downloadOpt.downloadFileComp = ^(NXFileBase *file, NSError *error){
        complete(file, error);
    };
    return downloadOpt;
}

- (NSOperation *)getRepositoryInfowithCompletion:(repoGetInfoCompletion)complete
{
    NXGetRepositoryInfoOperation *getRepoInfoOpt = [[NXGetRepositoryInfoOperation alloc] initWithRepository:[self getModel]];
    getRepoInfoOpt.getRepoInfoCompletion = ^(NXRepositoryModel *repo, NSString *userName, NSString *userEmail, NSNumber *totalQuota, NSNumber *usedQuota, NSError *error){
        complete(repo, userName, userEmail, totalQuota, usedQuota, error);
    };
    return getRepoInfoOpt;
}

- (NSOperation *)queryFileMetaData:(NXFileBase *)file withCompletion:(repoGetFileMetaDataCompletion)complete
{
    NXQueryFileMetaDataOperation *queryFileMetaDataOpt = [[NXQueryFileMetaDataOperation alloc] initWithFile:file repository:[self getModel]];
    queryFileMetaDataOpt.completion = ^(NXFileBase *metaData, NSError *error){
        if (complete) {
            complete(metaData, error);
        }
    };
    return queryFileMetaDataOpt;
}

#pragma mark - Favorite/Offline
- (void)markFavFileItem:(NXFileBase *)fileItem
{
    fileItem.isFavorite = YES;
    // update local cache file tree
    [self.repoFileSysTree markFavFileItem:fileItem];
}

- (void)unmarkFavFileItem:(NXFileBase *)fileItem
{
    fileItem.isFavorite = NO;
    [self.repoFileSysTree unmarkFavFileItem:fileItem];
}

- (void)markOfflineFileItem:(NXFileBase *)fileItem
{
    fileItem.isOffline = YES;
    [self.repoFileSysTree markOfflineFileItem:fileItem];
}

- (void)unmarkOfflineFileItem:(NXFileBase *)fileItem
{
    fileItem.isOffline = NO;
    [self.repoFileSysTree unmarkOfflineFileItem:fileItem];
}

- (void)updateFavFileItemList:(NSMutableSet *)favFileItems
{
    [self.repoFileSysTree updateFavFileItemList:favFileItems];
}

- (void)updateOfflineFileItemList:(NSMutableSet *)offlineItems
{
    [self.repoFileSysTree updateOfflineFileItemList:offlineItems];
}

- (NSArray *)allFavoriteFileItems
{
    return [self.repoFileSysTree allFavoriteFileItems];
}

- (NSArray *)allOfflineFileItems
{
    return [self.repoFileSysTree allOfflineFileItems];
}

#pragma mark - query file parent/child
- (NXFileBase *)getParentOfFileItem:(NXFileBase *)fileItem
{
    return [self.repoFileSysTree getParentOfFileItem:fileItem];
}
- (NSArray *)getChildOfFileItem:(NXFileBase *)fileItem
{
    return [self.repoFileSysTree getFileItemsCopyUnderFolder:fileItem];
}

#pragma mark - private method
- (BOOL)cleanUpLocalRepostioryData:(NXRepositoryModel *)repoModel
{
    //delete directory cache.
    [NXCacheManager deleteCachedRepositoryFileSystemTree:repoModel];
    // delete cache record in db
    [NXCacheFileStorage deleteCacheFilesFromCoreDataForRepo:repoModel];
    
    // delete cache files.
    NSURL* url = [NXCacheManager getLocalUrlForServiceCache:[self getModel]];
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    
    // do repo special clear DO NOT need clean SDK now, for we just use Web center token
    //[self destoryEnviromentForRepoSDK:repoModel];
    
    // clearn up core data
    [NXRepositoryStorage deleteRepoFromCoreData:repoModel];
    return YES;
}

- (void)destoryEnviromentForRepoSDK:(NXRepositoryModel *)repoItem {
    if (repoItem.service_type.integerValue == kServiceGoogleDrive) {
        
        [self clearUpSDK:(ServiceType)repoItem.service_type.integerValue appendData:repoItem.service_account_token];
        
    }else
    {
        [self clearUpSDK:(ServiceType)repoItem.service_type.integerValue appendData:nil];
    }
    
}

-(void) clearUpSDK:(ServiceType) serviceType appendData:(id) appendData
{
    switch (serviceType) {
        case kServiceDropbox:
            break;
        case kServiceSharepoint:
            break;
        case kServiceSharepointOnline:
            break;
        case kServiceOneDrive:
        {
//            AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//          //  [app.liveClient logout];
        }
            break;
        case kServiceGoogleDrive:
        {
            if (appendData) {
                NSString *keychainItemName = (NSString *)appendData;
                [GTMAppAuthFetcherAuthorization
                 removeAuthorizationFromKeychainForName:keychainItemName];
            }
        }
            break;
        default:
            break;
    }
}
@end
