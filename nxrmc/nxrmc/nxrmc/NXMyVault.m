//
//  NXMyVault.m
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVault.h"
#import "NXRMCDef.h"
#import "NXGetFileListInMyVaultFolderOperation.h"
#import "NXUploadFileToMyVaultFolderOperation.h"
#import "NXDownloadFileFromMyVaultFolderOperation.h"
#import "NXDeleteFileFromMyVaultFolderOperation.h"
#import "NXMetadataMyVaultFileOperation.h"
#import "NXCacheManager.h"
#import "NXMyVaultFileSync.h"
#import "NXMyVaultFileStorage.h"
#import "NXLProfile.h"

#define MY_VAULT_GETFILE_LIST_OPT_PREFIX    @"MY_VAULT_GETFILELIST_"
#define MY_VAULT_UPLOAD_FILE_OPT_PREFIX     @"MY_VAULT_UPLOADFILE_"
#define MY_VAULT_DOWNLOAD_FILE_OPT_PREFIX   @"MY_VAULT_DOWNFILE_"
#define MY_VAULT_DELETE_FILE_OPT_PREFIX     @"MY_VAULT_DELETE"
#define MY_VAULT_METADATA_FILE_OPT_PREFIX   @"MY_VAULT_METADATA"

@interface NXMyVault()
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, strong) NSMutableDictionary *operationDict;
@property(nonatomic, strong) NSMutableDictionary *compDict;
@property(nonatomic, assign) NSTimeInterval lastFileListUpdateTime;
@property(nonatomic, weak) id<NXFileChooseFlowDataSorceDelegate> fileChooseDataSorceDelegate;
//@property(nonatomic, strong) NXMyVaultFileSync *myVaultFileSync;
@end

@implementation NXMyVault
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile
{
    self = [super init];
    if (self) {
        _myVaultFileSystem = [[NXMyVaultFileSystemTree alloc] initWithUserProfile:userProfile];
        _userProfile = userProfile;
       // _myVaultFileSync = [[NXMyVaultFileSync alloc] init];
    }
    return self;
}
- (NXMyVaultFileSystemTree *)myVaultFileSystem
{
    @synchronized (self) {
        return _myVaultFileSystem;
    }
}

- (NSMutableDictionary *)operationDict
{
    @synchronized (self) {
        if (_operationDict == nil) {
            _operationDict = [[NSMutableDictionary alloc] init];
        }
        return _operationDict;
    }
}

- (NSMutableDictionary *)compDict
{
    @synchronized (self) {
        if (_compDict == nil) {
            _compDict = [[NSMutableDictionary alloc] init];
        }
        return _compDict;

    }
}

- (NSString *)getMyVaultFileListUnderRootFolderWithFilterModel:(NXMyVaultListParModel *)filterModel shouldReadCache:(BOOL)readCache withCompletion:(getMyVaultFileListComplete)complete
{
    NXFolder *rootFolder = [[NXFolder alloc] init];
    rootFolder.fullServicePath = @"/";
    rootFolder.isRoot = YES;
    rootFolder.fullPath = @"/";
    return [self getMyVaultFileListUnderParentFolder:rootFolder filterModel:filterModel shouldReadCache:readCache withCompletion:complete];
}
- (NXFileBase *)getmyVaultRootFolder {
    NXFolder *rootFolder = [[NXFolder alloc] init];
    rootFolder.sorceType = NXFileBaseSorceTypeMyVaultFile;
    rootFolder.fullServicePath = @"/";
    rootFolder.isRoot = YES;
    rootFolder.fullPath = @"/";
    return rootFolder;
    
}
- (NSArray *)getAllMyVaultFileInCoreData
{
    return [NXMyVaultFileStorage getAllMyVaultFiles];
}

- (NSString *)getMyVaultFileListUnderParentFolder:(NXFileBase *)parentFolder filterModel:(NXMyVaultListParModel *)filterModel shouldReadCache:(BOOL)readCache withCompletion:(getMyVaultFileListComplete)complete
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationId = [NSString stringWithFormat:@"%@%@", MY_VAULT_GETFILE_LIST_OPT_PREFIX, uuid];
    __block NSArray *fileListArray = nil;
    
    NXMyVaultListParModel *originParModel = filterModel;
    NXMyVaultListParModel *temParModel = [[NXMyVaultListParModel alloc] init];
    temParModel.page = filterModel.page;
    temParModel.size = filterModel.size;
    temParModel.filterType = filterModel.filterType;
    temParModel.sortOptions = filterModel.sortOptions;
    temParModel.searchString = filterModel.searchString;
    
    if(readCache)
    {
        fileListArray = [self.myVaultFileSystem getFileItemsCopyUnderFolder:(NXMyVaultFile *)parentFolder filterModel:filterModel];
        // need get cache form coredata first
        if (fileListArray && fileListArray.count > 0 ) {
            complete(fileListArray, parentFolder, filterModel, nil);  // BUG!!!!!!!!! From cached file, filter model is not work.
        }
        return operationId;
    }
    
    dispatch_queue_t readQueue = dispatch_queue_create("com.skydrm.www", DISPATCH_QUEUE_CONCURRENT);
    
    if(readCache == NO)
    {
        if ([[NSDate date] timeIntervalSince1970] - self.lastFileListUpdateTime  < 5) { // don't allow user refresh in 5 seconds
            dispatch_async(readQueue, ^{
                NSArray  * retFileList = [self.myVaultFileSystem getFileItemsCopyUnderFolder:(NXMyVaultFile *)parentFolder filterModel:filterModel];
                complete(retFileList, parentFolder, filterModel, nil);  // BUG!!!!!!!!! From cached file, filter model is not work.
                // Attention please!!!!!!!!!!!!!!!!!!!   this is not a bug , because we get file from network according filter type, every time will update coredata,so when get cache will remain last filter type################
            });
            
             return operationId;
    }
            self.lastFileListUpdateTime = [[NSDate date] timeIntervalSince1970];
            // get from net work to update cache every time when call get my vault file list API
            NXGetFileListInMyVaultFolderOperation *getFileListOpt = [[NXGetFileListInMyVaultFolderOperation alloc] initWithParentFolder:parentFolder filterModel:temParModel];
            [self.compDict setObject:complete forKey:operationId];
            [self.operationDict setObject:getFileListOpt forKey:operationId];
           WeakObj(self);
            getFileListOpt.completion = ^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error){
                StrongObj(self);
            dispatch_async(readQueue, ^{
                //  update local myvaultFileItems in coredata
                if (!error && filterModel.filterType == NXMyvaultListFilterTypeAllFiles) {
                    [self.myVaultFileSystem updateFileItems:fileList underFolder:(NXMyVaultFile *)parentFolder];
                }
                NSArray  * retFileList = [self.myVaultFileSystem getFileItemsCopyUnderFolder:(NXMyVaultFile *)parentFolder filterModel:filterModel];
                complete(retFileList, parentFolder, originParModel, error);
            });
                    
                [self.compDict removeObjectForKey:operationId];
                [self.operationDict removeObjectForKey:operationId];
            };
            
            [getFileListOpt start];
    }
   
    return operationId;
}

- (NSString *)uploadFile:(NSString *)fileName fileData:(NSData *)fileData fileItem:(NXFileBase *)fileItem toMyVaultFolder:(NXFileBase *)folder progress:(NSProgress *)uploadProgress  withCompletion:(uploadFileToMyVaultFolderComplete)complete
{
    if (folder == nil) {
        folder = [[NXFolder alloc] init];
        folder.isRoot = YES;
        folder.fullServicePath = @"/";
    }
    
    if (fileItem.sorceType == NXFileBaseSorceTypeLocal || fileItem.sorceType == NXFileBaseSorceType3rdOpenIn) {
        fileItem.fullPath = [NSString stringWithFormat:@"/%@",fileItem.name];
        fileItem.fullServicePath = @"local";
        fileItem.repoId = @"local";
        fileItem.serviceAlias = @"local";
    }else if(fileItem.sorceType == NXFileBaseSorceTypeLocalFiles){
        fileItem.fullPath = [NSString stringWithFormat:@"/%@",fileItem.name];
        fileItem.fullServicePath = @"Files";
        fileItem.repoId = @"Files";
        fileItem.serviceAlias = @"Files";
    }
    if(fileData.length > RMS_MAX_UPLOAD_SIZE) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_UPLOAD_TO_MAX userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPLOAD_TO_MAX", nil)}];
        complete(nil, nil, error);
        return nil;
    }
      NXUploadFileToMyVaultFolderOperation *uploadOpt = [[NXUploadFileToMyVaultFolderOperation alloc] initWithParentFolder:folder fileName:fileName fileItem:fileItem fileData:fileData];
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", MY_VAULT_UPLOAD_FILE_OPT_PREFIX, uuid];
    [self.compDict setObject:complete forKey:operationIdentify];
    [self.operationDict setObject:uploadOpt forKey:operationIdentify];
    
    WeakObj(self);
    uploadOpt.completion = ^(NXMyVaultFile *uploadedFile, NXFileBase *parentFolder, NSError *error){
        StrongObj(self);
        if (!error) {
            [self.myVaultFileSystem addFileItem:uploadedFile underFolder:(NXMyVaultFile *)parentFolder];
        }
        
        uploadFileToMyVaultFolderComplete comp = self.compDict[operationIdentify];
        comp(uploadedFile, parentFolder, error);
        
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    
    uploadOpt.progress = uploadProgress;
    
    [uploadOpt start];
    return operationIdentify;
}

- (NSString *)deleteFile:(NXMyVaultFile *)file withCompletion:(deleteFileFromMyVaultComplete)complete {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", MY_VAULT_DELETE_FILE_OPT_PREFIX, uuid];
    NXDeleteFileFromMyVaultFolderOperation *deleteOpt = [[NXDeleteFileFromMyVaultFolderOperation alloc] initWithFile:file];
    [self.compDict setObject:complete forKey:operationIdentify];
    [self.operationDict setObject:deleteOpt forKey:operationIdentify];
    
    WeakObj(self);
    deleteOpt.completion = ^(NXMyVaultFile *file, NSError *error){
        StrongObj(self);
        deleteFileFromMyVaultComplete comp = self.compDict[operationIdentify];
        if (error == nil) {
            [self.myVaultFileSystem deleteFileItem:file];
        }
        comp(file, error);
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    
    [deleteOpt start];
    return operationIdentify;
}

- (NSString *)metaData:(NXMyVaultFile *)file withCompletetino:(metadataFromMyVaultComplete)complete {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", MY_VAULT_METADATA_FILE_OPT_PREFIX, uuid];
    NXMetadataMyVaultFileOperation *metadataOpt = [[NXMetadataMyVaultFileOperation alloc] initWithFile:file];
    [self.compDict setObject:complete forKey:operationIdentify];
    [self.operationDict setObject:metadataOpt forKey:operationIdentify];
    
    WeakObj(self);
    metadataOpt.completion = ^(NXMyVaultFile *file, NSError *error){
        StrongObj(self);
        metadataFromMyVaultComplete comp = self.compDict[operationIdentify];
        if (error == nil) {
            // need update myVaultFile in coredata
            [self.myVaultFileSystem updateMyVaultFileItemMetadataInStorage:file];
            comp(file, nil);
        } else {
            comp(nil, error);
        }
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    
    [metadataOpt start];
    return operationIdentify;
}

#pragma mark - sync file list
- (void)startSyncMyVaultFileListUnderFolder:(NXFileBase *)parentFolder
{
   // [self.myVaultFileSync stopSync];
  //  self.myVaultFileSync.delegate = self
}
- (void)stopSyncMyVaultFileList
{
    
}

- (void)markFavoriteFile:(NXFileBase *)fileItem
{
    
}

- (void)unmarkFavoriteFile:(NXFileBase *)fileItem
{
    
}

- (void)updateMyVaultFileSharedStatus:(NXMyVaultFile *)myVaultFile
{
     [NXMyVaultFileStorage updateMyVaultFileSharedStatus:myVaultFile];
}
- (void)updateMyVaultFileRevokedStatus:(NXMyVaultFile *)myVaultFile
{
     [NXMyVaultFileStorage updateMyVaultFileRevokedStatus:myVaultFile];
}

- (void)cancelOperation:(NSString *)operationIdentify
{
    if (operationIdentify == nil) {
        return;
    }
    
    NSOperation *opt = self.operationDict[operationIdentify];
    if (opt) {
        [opt cancel];
    }
    
    // return canel error
    id comp = self.compDict[operationIdentify];
    if (comp) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_MY_VAULT_DOMAIN code:NXRMC_ERROR_CODE_MY_VAULT_OPT_CANCELED userInfo:nil];
        if ([operationIdentify containsString:MY_VAULT_DELETE_FILE_OPT_PREFIX]) {
            deleteFileFromMyVaultComplete deleteComp = (downloadFileFromMyVaultComplete)comp;
            deleteComp(nil, error);
        }
        if ([operationIdentify containsString:MY_VAULT_DOWNLOAD_FILE_OPT_PREFIX]) {
            downloadFileFromMyVaultComplete downloadComp = (downloadFileFromMyVaultComplete)comp;
            downloadComp(nil, error);
        }
        
        if ([operationIdentify containsString:MY_VAULT_UPLOAD_FILE_OPT_PREFIX]) {
            uploadFileToMyVaultFolderComplete uploadComp = (uploadFileToMyVaultFolderComplete)comp;
            uploadComp(nil, nil, error);
        }
        
        if ([operationIdentify containsString:MY_VAULT_GETFILE_LIST_OPT_PREFIX]) {
            getFileListInMyVaultFolderOperationCompletion getFileListComp = (getFileListInMyVaultFolderOperationCompletion)comp;
            getFileListComp(nil, nil, nil, error);
        }
    }
    
    [self.operationDict removeObjectForKey:operationIdentify];
    [self.compDict removeObjectForKey:operationIdentify];
}
#pragma mark - NXFileChooseFlowDataSorceDelegate
- (void)fileListUnderFolder:(NXFolder *)parentFolder withCallBackDelegate:(id<NXFileChooseFlowDataSorceDelegate>)delegate
{
    self.fileChooseDataSorceDelegate = delegate;
    WeakObj(self);
    NXMyVaultListParModel *myVaultModel = [[NXMyVaultListParModel alloc] init];
    [self getMyVaultFileListUnderRootFolderWithFilterModel:myVaultModel shouldReadCache:NO withCompletion:^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
        StrongObj(self);
        NSMutableArray *validArray = [NSMutableArray array];
        for (NXMyVaultFile *fileItem in fileList) {
            if (fileItem.isDeleted == NO) {
                [validArray addObject:fileItem];
            }
        }
        if (self && self.fileChooseDataSorceDelegate) {
            if(DELEGATE_HAS_METHOD(self.fileChooseDataSorceDelegate, @selector(fileChooseFlowDidGetFileList:underParentFolder:error:))){
                [self.fileChooseDataSorceDelegate fileChooseFlowDidGetFileList:validArray underParentFolder:(NXFolder *)parentFolder error:error];
                self.fileChooseDataSorceDelegate = nil;

            }
        }
            
    }];

}
@end
