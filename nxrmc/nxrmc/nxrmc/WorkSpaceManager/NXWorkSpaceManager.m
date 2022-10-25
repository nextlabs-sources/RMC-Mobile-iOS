//
//  NXWorkSpaceManager.m
//  nxrmc
//
//  Created by Eren on 2019/8/29.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceManager.h"
#import "NXLProfile.h"
#import "NXLoginUser.h"
#import "NXRMCDef.h"
#import "NXWorkSpaceFileListOperation.h"
#import "NXWorkSpaceGetFileMetadataOperation.h"
#import "NXWorkSpaceCreateFolderOperation.h"
#import "NXWorkSpaceDeleteFileOperation.h"
#import "NXWorkSpaceUploadFileOperation.h"
#import "NXWorkSpaceDownloadFileOperation.h"
#import "NXWorkSpaceReclassifityFileOperation.h"
#import "NXWorkSpaceFileSync.h"
#import "NXWorkSpaceItem.h"
#import "NXProjectGetClassificationProfileOperation.h"
#import "NXWorkSpaceStorage.h"

#define WORKSPACE_GETFILE_LIST_OPT_PREFIX           @"WORKSPACE_GETFILELIST_"
#define WORKSPACE_GETFILE_LISTNUMBER_OPT_PREFIX     @"WORKSPACE_GETFILELIST_NUMBER"
#define WORKSPACE_UPLOAD_FILE_OPT_PREFIX            @"WORKSPACE_UPLOADFILE_"
#define WORKSPACE_DOWNLOAD_FILE_OPT_PREFIX          @"WORKSPACE_DOWNFILE_"
#define WORKSPACE_DELETE_FILE_OPT_PREFIX            @"WORKSPACE_DELETE"
#define WORKSPACE_METADATA_FILE_OPT_PREFIX          @"WORKSPACE_METADATA"
#define WORKSPACE_RECLASSIFY_FILE_OPT_PREFIX        @"WORKSPACE_RECLASSIFY"
#define WORKSPACE_CREATE_FOLDER_OPT_PREFIX          @"WORKSPACE_CREATE_FOLDER"
#define WORKDPACE_GET_CLASSIFITY_OPT_PREFIX         @"WORKDPACE_GET_CLASSIFITY"
@interface NXWorkSpaceManager ()<NXWorkSpaceFileSyncDelegate>
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, strong) NSMutableDictionary *operationDict;
@property(nonatomic, strong) NSMutableDictionary *compDict;
@property(nonatomic, strong) NXFileBase *rootWorkSpaceFolder;
@property(nonatomic, strong)  NXWorkSpaceFileSync *workSpaceFileSync;
@property(nonatomic, weak) id<NXFileChooseFlowDataSorceDelegate> fileChooseDataSorceDelegate;
@end
@implementation NXWorkSpaceManager

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
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile {
    self = [super init];
    if (self) {
        _userProfile = userProfile;
    }
    return self;
    
}

- (void)bootup{
    // For now, we won't sync file list
//    NXWorkSpaceFileSync *fileSync = [[NXWorkSpaceFileSync alloc]init];
//    self.workSpaceFileSync = fileSync;
//    fileSync.delegate = self;
//    [fileSync startSyncFromWorkSpaceFolder:self.rootWorkSpaceFolder];
}

- (void)shutDown
{
    [self.workSpaceFileSync stopSync];
    self.workSpaceFileSync = nil;
    
    for (NSOperation *opt in self.operationDict.allValues) {
        [opt cancel];
    }
    
    self.operationDict = nil;
    self.compDict = nil;
}
- (NSString *)getWorkSpaceFileNumberAndStorageWithCompletion:(getWorkSpaceTotalFileNumberAndStorageComplete)complete{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKSPACE_GETFILE_LISTNUMBER_OPT_PREFIX, uuid];
    NXWorkSpaceFileListOperation *fileListOpt = [[NXWorkSpaceFileListOperation alloc]initWithWorkSpaceFolder:[[NXWorkSpaceFolder alloc]init]];
    getWorkSpaceTotalFileNumberAndStorageComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:fileListOpt forKey:operationIdentify];
    WeakObj(self);
    fileListOpt.getWorkSPaceFileTotalNumberAndStorageCompletion = ^(NSNumber *fileNumber, NSNumber *storageSize, NSError *error) {
        StrongObj(self);
        getWorkSpaceTotalFileNumberAndStorageComplete comp = self.compDict[operationIdentify];
        comp(fileNumber,storageSize,error);
        [self.operationDict removeObjectForKey:operationIdentify];
        [self.compDict removeObjectForKey:operationIdentify];
        
    };
    [fileListOpt start];
    return operationIdentify;
}
- (NSArray *)getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)parentFolder
{
    return [NXWorkSpaceStorage queryWorkSpaceFilesUnderFolder:parentFolder];
}

- (NSString *)getWorkSpaceFileListUnderFolder:(NXWorkSpaceFolder *)parentFolder shouldReadCache:(BOOL)readCache withCompletion:(getWorkSpaceFileListComplete)complete{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKSPACE_GETFILE_LIST_OPT_PREFIX, uuid];
    if (readCache) {
        NSArray *workSpaceFileItemArray = [NXWorkSpaceStorage queryWorkSpaceFilesUnderFolder:parentFolder];
        if (workSpaceFileItemArray.count > 0) {
            complete(workSpaceFileItemArray, parentFolder, nil);
        }
    }
    
    NXWorkSpaceFileListOperation *fileListOpt = [[NXWorkSpaceFileListOperation alloc]initWithWorkSpaceFolder:parentFolder];
    getWorkSpaceFileListComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:fileListOpt forKey:operationIdentify];
    WeakObj(self);
    fileListOpt.getWorkSPaceFileListCompletion = ^(NSArray *workSpaceFileList, NXWorkSpaceFolder *workSpaceFolder, NSError *error) {
        StrongObj(self);
        if (!error) {
            // delete storage exist but server is not exist.
           NSMutableSet *oldFilesSet = [NSMutableSet setWithArray:[NXWorkSpaceStorage queryWorkSpaceFilesUnderFolder:parentFolder]];
           NSSet *newFilesSet = [NSSet setWithArray:workSpaceFileList];
            [oldFilesSet minusSet:newFilesSet];
            for (NXFileBase *fileItem in oldFilesSet) {
                [NXWorkSpaceStorage deleteWorkSpaceFileItem:fileItem];
            }
            [NXWorkSpaceStorage insertWorkSpaceFiles:workSpaceFileList toFolder:workSpaceFolder];
        }
        // There should return file list data from DB, not workSpaceFileList from network, because some local info, such as
        // offline info, can only added by DB
        NSArray *workSpaceFileItemArray = [NXWorkSpaceStorage queryWorkSpaceFilesUnderFolder:parentFolder];
        getWorkSpaceFileListComplete comp = self.compDict[operationIdentify];
        comp(workSpaceFileItemArray,workSpaceFolder,error);
        [self.operationDict removeObjectForKey:operationIdentify];
        [self.compDict removeObjectForKey:operationIdentify];
    };
    [fileListOpt start];
    return operationIdentify;
}
- (NSString *)getWorkSpaceFileMetadataWithFile:(NXWorkSpaceFile *)spaceFile withCompletion:(getWorkSpaceFileMetadataComplete)complete {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKSPACE_METADATA_FILE_OPT_PREFIX, uuid];
    NXWorkSpaceGetFileMetadataOperation *metadataOpt = [[NXWorkSpaceGetFileMetadataOperation alloc]initWithWorkSpaceFile:spaceFile];
     getWorkSpaceFileMetadataComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:metadataOpt forKey:operationIdentify];
    
    WeakObj(self);
    metadataOpt.getWorkSpaceFileMetadataCompletion = ^(NXWorkSpaceFile *workSpaceFile, NSError *error) {
        StrongObj(self);
        getWorkSpaceFileMetadataComplete comp = self.compDict[operationIdentify];
        if (error == nil) {
            [NXWorkSpaceStorage updateWorkSpaceFileItem:workSpaceFile];
            comp(workSpaceFile,nil);
        }else{
            comp(nil,error);
        }
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    
    [metadataOpt start];
    return operationIdentify;
}

- (NSString *)createWorkSpaceFolder:(NXWorkSpaceCreateFolderModel *)model withCompletion:(createWorkSpaceFolderComplete)complete {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKSPACE_CREATE_FOLDER_OPT_PREFIX, uuid];
    NXWorkSpaceCreateFolderOperation *createFolderOpt = [[NXWorkSpaceCreateFolderOperation alloc] initWithWorkSpaceCreateFolderModel:model];
    createWorkSpaceFolderComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:createFolderOpt forKey:operationIdentify];
    createFolderOpt.createWorkSpaceFolderCompletion = ^(NXFolder * _Nonnull folder, NSError * _Nonnull error) {
        createWorkSpaceFolderComplete comp = self.compDict[operationIdentify];
        // update cache
        if (!error) {
            [NXWorkSpaceStorage insertWorkSpaceFileItem:folder toParentFolder:model.parentFolder];
        }
        comp((NXWorkSpaceFolder*)folder, model, error);
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    [createFolderOpt start];
    return operationIdentify;
}
- (NSString *)deleteWorkSpaceFile:(NXFileBase *)workSpaceFile withCompletion:(delegeWorkSpaceFileComplete)complete {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKSPACE_DELETE_FILE_OPT_PREFIX, uuid];
    NXWorkSpaceDeleteFileOperation *deleteOpt = [[NXWorkSpaceDeleteFileOperation alloc]initWithNXWorkSpaceFile:workSpaceFile];
    delegeWorkSpaceFileComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:deleteOpt forKey:operationIdentify];
    deleteOpt.deleteWorkSpaceFileCompletion = ^(NXFileBase *spaceItem, NSError *error) {
        delegeWorkSpaceFileComplete comp = self.compDict[operationIdentify];
        if (!error) {
            [NXWorkSpaceStorage deleteWorkSpaceFileItem:workSpaceFile];
        }
        comp(spaceItem,error);
        [self.operationDict removeObjectForKey:operationIdentify];
        [self.compDict removeObjectForKey:operationIdentify];
    };
    [deleteOpt start];
    return operationIdentify;
}
- (NSString *)reclassifyWorkSpaceFile:(NXWorkSpaceReclassifyFileModel *)model withCompletion:(reclassifyWorkSpaceFileComplete)complete{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKSPACE_RECLASSIFY_FILE_OPT_PREFIX, uuid];
    
    NXWorkSpaceReclassifityFileOperation *reclassifyOpt = [[NXWorkSpaceReclassifityFileOperation alloc]initWithWorkSpaceReclassifyModel:model];
    reclassifyWorkSpaceFileComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:reclassifyOpt forKey:operationIdentify];
    
    reclassifyOpt.reclassifyWorkSpaceFileCompletion = ^(NXWorkSpaceFile * _Nonnull spaceFile, NXWorkSpaceReclassifyFileModel * _Nonnull model, NSError * _Nonnull error) {
        reclassifyWorkSpaceFileComplete comp = self.compDict[operationIdentify];
        comp(spaceFile,model,error);
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    [reclassifyOpt start];
    return operationIdentify;
}
- (NSString *)uploadWorkSpaceFile:(NXWorkSpaceUploadFileModel *)upLoadWorkSpaceFileModel WithCompletion:(uploadWorkSpaceFileComplete)complete {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSData *fileData = [NSData dataWithContentsOfFile:upLoadWorkSpaceFileModel.file.localPath];
    if(fileData.length> RMS_MAX_UPLOAD_SIZE) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_UPLOAD_TO_MAX userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPLOAD_TO_MAX", nil)}];
        complete(nil, upLoadWorkSpaceFileModel, error);
        return nil;
    }
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKSPACE_UPLOAD_FILE_OPT_PREFIX, uuid];
    NXWorkSpaceUploadFileOperation *uploadOpt = [[NXWorkSpaceUploadFileOperation alloc]initWithWorkSpaceUploadFileModel:upLoadWorkSpaceFileModel];
    uploadWorkSpaceFileComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:uploadOpt forKey:operationIdentify];
    
    uploadOpt.uploadWorkSpaceFileCompletion = ^(NXWorkSpaceFile * _Nonnull workSpaceFile, NXWorkSpaceUploadFileModel * _Nonnull uploadWorkSpcaeModel, NSError * _Nonnull error) {
        uploadWorkSpaceFileComplete comp = self.compDict[operationIdentify];
        
        if (!error) {
            [NXWorkSpaceStorage insertWorkSpaceFileItem:workSpaceFile toParentFolder:uploadWorkSpcaeModel.parentFolder];
        }
        if (comp) {
          comp(workSpaceFile,upLoadWorkSpaceFileModel,error);
        }
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    [uploadOpt start];
    return operationIdentify;
}
- (NSString *)getWorkSpaceDefalutClassificationWithCompletion:(getDefalutClassificationComplete)complete{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", WORKDPACE_GET_CLASSIFITY_OPT_PREFIX, uuid];
    NXProjectGetClassificationProfileOperation *classifiyOpt = [[NXProjectGetClassificationProfileOperation alloc] initWithDeflautTokenGroup:[NXLoginUser sharedInstance].profile.individualMembership.tokenGroupName];
    getDefalutClassificationComplete comp = complete;
    [self.compDict setObject:comp forKey:operationIdentify];
    [self.operationDict setObject:classifiyOpt forKey:operationIdentify];
    
    classifiyOpt.optCompletion = ^(NSArray<NXClassificationCategory *> *classificaitons, NSError *error) {
        getDefalutClassificationComplete comp = self.compDict[operationIdentify];
        comp(classificaitons,error);
        [self.compDict removeObjectForKey:operationIdentify];
        [self.operationDict removeObjectForKey:operationIdentify];
    };
    
    [classifiyOpt start];
    return operationIdentify;
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
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_WORKSPACE_DOMAIN code:NXRMC_ERROR_CODE_WORKSPACE_OPT_CANCELED userInfo:nil];
        if ([operationIdentify containsString:WORKSPACE_DELETE_FILE_OPT_PREFIX]) {
           delegeWorkSpaceFileComplete deleteComp = (delegeWorkSpaceFileComplete)comp;
            deleteComp(nil, error);
        }
        if ([operationIdentify containsString:WORKSPACE_DOWNLOAD_FILE_OPT_PREFIX]) {
            downloadWorkSpaceFileComplete downloadComp = (downloadWorkSpaceFileComplete)comp;
            downloadComp(nil, error);
        }
        
        if ([operationIdentify containsString:WORKSPACE_UPLOAD_FILE_OPT_PREFIX]) {
            uploadWorkSpaceFileComplete uploadComp = (uploadWorkSpaceFileComplete)comp;
            uploadComp(nil,nil,error);
        }
        
        if ([operationIdentify containsString:WORKSPACE_GETFILE_LIST_OPT_PREFIX]) {
            getWorkSpaceFileListComplete getFileListComp = (getWorkSpaceFileListComplete)comp;
            getFileListComp(nil, nil, error);
        }
        if ([operationIdentify containsString:WORKSPACE_METADATA_FILE_OPT_PREFIX]) {
            getWorkSpaceFileMetadataComplete getFileMetadataComp = (getWorkSpaceFileMetadataComplete)comp;
            getFileMetadataComp(nil,error);
        }
        if ([operationIdentify containsString:WORKSPACE_RECLASSIFY_FILE_OPT_PREFIX]) {
            reclassifyWorkSpaceFileComplete reclassifyComp = (reclassifyWorkSpaceFileComplete)comp;
            reclassifyComp(nil,nil,error);
        }
        if ([operationIdentify containsString:WORKSPACE_CREATE_FOLDER_OPT_PREFIX]) {
            createWorkSpaceFolderComplete createFolderComp = (createWorkSpaceFolderComplete)comp;
            createFolderComp(nil,nil,error);
        }
        if ([operationIdentify containsString:WORKDPACE_GET_CLASSIFITY_OPT_PREFIX]) {
            getDefalutClassificationComplete classificationComp = (getDefalutClassificationComplete)comp;
            classificationComp(nil,error);
        }
        if ([operationIdentify containsString:WORKSPACE_GETFILE_LISTNUMBER_OPT_PREFIX]) {
            getWorkSpaceTotalFileNumberAndStorageComplete totalNumberComp = (getWorkSpaceTotalFileNumberAndStorageComplete)comp;
            totalNumberComp(nil,nil,error);
        }
    }
    
    [self.operationDict removeObjectForKey:operationIdentify];
    [self.compDict removeObjectForKey:operationIdentify];
}


- (void)updateFiles:(NSArray *)fileList parentFolder:(NXFileBase *)parentFolder error:(NSError *)error fromWorkSpaceFileSync:(NXWorkSpaceFileSync *)myVaultSync {
    
}

-(NXWorkSpaceFolder *)rootFolderForWorkSpace {
    NXWorkSpaceFolder *rootFolder = [[NXWorkSpaceFolder alloc] init];
    rootFolder.isRoot = YES;
    rootFolder.sorceType = NXFileBaseSorceTypeWorkSpace;
    rootFolder.fullPath = @"/";
    rootFolder.fullServicePath = @"/";
    return rootFolder;
}

#pragma mark - NXFileChooseFlowDataSorceDelegate
- (void)fileListUnderFolder:(NXFolder *)parentFolder withCallBackDelegate:(id<NXFileChooseFlowDataSorceDelegate>)delegate
{
    self.fileChooseDataSorceDelegate = delegate;
    WeakObj(self);
    [self getWorkSpaceFileListUnderFolder:(NXWorkSpaceFolder*)parentFolder shouldReadCache:NO withCompletion:^(NSArray *fileListArray, NXWorkSpaceFolder *parentFoloder, NSError *error) {
        StrongObj(self);
        if (self && self.fileChooseDataSorceDelegate) {
            if (DELEGATE_HAS_METHOD(self.fileChooseDataSorceDelegate, @selector(fileChooseFlowDidGetFileList:underParentFolder:error:))) {
                [self.fileChooseDataSorceDelegate fileChooseFlowDidGetFileList:fileListArray underParentFolder:parentFolder error:error];
            }
            self.fileChooseDataSorceDelegate = nil;
        }
    }];
}

- (NXFileBase *)queryParentFolderForFolder:(NXFileBase *)folder {
    return [NXWorkSpaceStorage parentFolderForFileItem:folder];
}

@end
