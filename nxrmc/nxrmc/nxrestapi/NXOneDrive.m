//
//  NXOneDrive.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOneDrive.h"
#import "NXFolder.h"
#import "NXFile.h"
#import "NXCacheManager.h"
#import "NXOneDriveFileListAPI.h"
#import "NXOneDriveDownloadFileAPI.h"
#import "NXOneDriveGetUserInfoAPI.h"
#import "NXGetAccessTokenAPI.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXOneDriveFileItem.h"
#import "NXOneDriveSmallFileUploadAPI.h"
#import "NXOneDriveBigFileUploadCreateSessionAPI.h"
#import "NXOneDriveBigFileUploadAPI.h"

#define ONEDRIVE_ACCESSTOKEN_KEYWORD @"Authorization"
@interface NXOneDrive () <NXServiceOperationDelegate>{
NSString* _userID;

NXFileBase* _curFileBase;

NSString* _uploadFileName;
NSString* _uploadSrcFilePath;
NXFileBase *_overWriteFile; ////this used to store file which will be replace when upload file for type :NXUploadTypeOverWrite, if other type , this parameter is nil.
}
@property (nonatomic, weak) id<NXServiceOperationDelegate> delegate;
@property (atomic, strong) NSMutableArray *enumFolderStack;
@property (atomic, strong) NSMutableArray *recursiveFileList;
@property (nonatomic, strong) NXOneDriveDownloadFileAPIRequest *downloadReq;
@property (nonatomic, strong) NXOneDriveFileListAPIRequest *fileListReq;
@property (nonatomic, strong) NXOneDriveGetUserInfoAPIRequest *usedInfoReq;
@property (nonatomic, strong) NXSuperRESTAPIRequest *uploadFileReq;
@property (nonatomic, strong) NXOneDriveBigFileUploadRequest *bigFileUploadReq;
@property (nonatomic, strong) NXOneDriveBigFileUploadCreateSessionRequest *bigFileUploadSessionReq;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSNumber *totalQuota;
@property (nonatomic, strong) NSNumber *usedQuota;
@end
@implementation NXOneDrive
- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
    
}
-(void) setDelegate: (id<NXServiceOperationDelegate>) delegate
{
    _delegate = delegate;
}
- (id)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel {
    self = [super init];
    if (self) {
        _userID = userId;
        _boundService = repoModel;
    }
    return self;
}
-(BOOL) getFiles:(NXFileBase*)folder {
    if (!folder) {
        return NO;
    }
    _curFileBase = folder;
    if(folder.isRoot)
    {
        folder.fullPath = @"/";
        folder.fullServicePath = @"root";
    }
    NSDictionary *dict = @{@"fileId":folder.fullServicePath};
    NXOneDriveFileListAPIRequest *requestq = [[NXOneDriveFileListAPIRequest alloc] initWithRepo:self.boundService accessTokenKeyword:ONEDRIVE_ACCESSTOKEN_KEYWORD];
    self.fileListReq = requestq;
    WeakObj(self);
    [requestq requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            if ([_delegate respondsToSelector:@selector(getFilesFinished:error:)]) {
                [_delegate getFilesFinished:nil error:error];
            }
        }else{
            StrongObj(self);
            if (self) {
                [self getFilesFinished:((NXOneDriveFileListAPIResponse *)response).fileList];
            }
        }
    }];
    
    return YES;
}
- (BOOL)cancelGetFiles:(NXFileBase *)folder {
    if (self.fileListReq) {
        [self.fileListReq cancelRequest];
        return YES;
    }
    return NO;
}
- (BOOL)downloadFile:(NXFileBase *)file size:(NSUInteger)size {
    if(!file || ![file isKindOfClass:NXFile.class])
    {
        return NO;
    }
    _curFileBase = file;
    NSDictionary *dict = @{@"fileId":file.fullServicePath};
    NXOneDriveDownloadFileAPIRequest *downloadRequest = [[NXOneDriveDownloadFileAPIRequest alloc]initWithRepo:self.boundService accessTokenKeyword:ONEDRIVE_ACCESSTOKEN_KEYWORD];
    self.downloadReq = downloadRequest;
    WeakObj(self);
    [downloadRequest requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (self) {
            if (!error) {
                NSData *fileData = ((NXOneDriveDownloadFileAPIResponse*)response).fileData;
                [self downloadFileFinished:fileData];
            } else {
                [self downloadFileFailed:error];
            }
        }
    }];
    return YES;
}

- (BOOL)cancelDownloadFile:(NXFileBase *)file {
    if (self.downloadReq) {
        [self.downloadReq cancelRequest];
    }
    return NO;
}

- (BOOL)uploadFile:(NSString *)filename toPath:(NXFileBase *)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile {
//    NSDictionary *modelDict = @{ONE_DRIVE_SMALL_UPLOAD_PARENT_FOLDER_KEY:folder,
//                                ONE_DRIVE_SMALL_UPLOAD_FILE_NAME_KEY:filename,
//                                ONE_DRIVE_SMALL_UPLOAD_FILE_LOCAL_PATH_KEY:srcPath};
//    NXOneDriveSmallFileUploadRequest *req = [[NXOneDriveSmallFileUploadRequest alloc] initWithRepo:self.boundService accessTokenKeyword:ONEDRIVE_ACCESSTOKEN_KEYWORD];
//    WeakObj(self);
//    [req requestWithObject:modelDict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
//        StrongObj(self);
//        NXOneDriveSmaillFileUploadResponse *uploadResponse = (NXOneDriveSmaillFileUploadResponse *)response;
//        NXFile *uploadedFile = [NXFile new];
//        [self fetchFileInfo:uploadedFile andFileData:uploadResponse.uploadedFile];
//        [self uploadFileFinished:uploadedFile fromLocalPath:srcPath error:error];
//
//    }];
//    self.uploadFileReq = req;
    _curFileBase = folder;
    NXOneDriveBigFileUploadCreateSessionRequest *createSessionReq = [[NXOneDriveBigFileUploadCreateSessionRequest alloc] initWithRepo:self.boundService accessTokenKeyword:ONEDRIVE_ACCESSTOKEN_KEYWORD];
    NSDictionary *sessionModelDict = @{ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_FILE_NAME_KEY:filename,
                                       ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_CONFLICT_BEHAVIOR_KEY:@"replace",
                                       ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_TARGET_FOLDER_KEY:folder
    };
    self.bigFileUploadSessionReq = createSessionReq;
    WeakObj(self);
    [createSessionReq requestWithObject:sessionModelDict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXOneDriveBigFileUploadCreateSessionResponse *createSessionResponse = (NXOneDriveBigFileUploadCreateSessionResponse *)response;
        if (createSessionResponse && createSessionResponse.uploadSessionURL) {
            StrongObj(self);
            NXOneDriveBigFileUploadRequest *uploadBigFileReq = [[NXOneDriveBigFileUploadRequest alloc] initWithRepo:self.boundService accessTokenKeyword:ONEDRIVE_ACCESSTOKEN_KEYWORD];
            NSDictionary *modelDict = @{
                ONE_DRIVE_BIG_FILE_UPLOAD_FILE_KEY:srcPath,
                ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_URL_KEY:((NXOneDriveBigFileUploadCreateSessionResponse *)response).uploadSessionURL,
            };
            WeakObj(self);
            self.bigFileUploadReq = uploadBigFileReq;
            [uploadBigFileReq requestWithObject:modelDict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                StrongObj(self);
                NXOneDriveBigFileUploadResponse *uploadResponse = (NXOneDriveBigFileUploadResponse *)response;
                NXFile *uploadFile = nil;
                if (uploadResponse && uploadResponse.uploadedFile) {
                    uploadFile = [[NXFile alloc] init];
                    [self fetchFileInfo:uploadFile andFileData:uploadResponse.uploadedFile];
                }
                [self uploadFileFinished:uploadFile fromLocalPath:srcPath error:error];
            }];
        }else {
            [self uploadFileFinished:nil fromLocalPath:srcPath error:error];
        }
    }];
    
    return YES;
}

- (BOOL)cancelUploadFile:(NSString *)filename toPath:(NXFileBase *)folder {
    if (self.bigFileUploadSessionReq) {
        [self.bigFileUploadSessionReq cancelRequest];
    }
    
    if (self.bigFileUploadReq) {
        [self.bigFileUploadReq cancelRequest];
    }
    return YES;
}

- (BOOL)getMetaData:(NXFileBase *)file {
    return NO;
}

- (BOOL)cancelGetMetaData:(NXFileBase *)file {
    return NO;
}

- (BOOL)addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder {
    return NO;
}

- (BOOL)deleteFileItem:(NXFileBase *)file {
    return NO;
}

- (BOOL)isProgressSupported {
    return NO;
}

- (BOOL)getUserInfo {
    if (_boundService.service_id) {
        self.userName = nil;
        self.userEmail = nil;
        self.totalQuota = nil;
        self.usedQuota = nil;
        NXOneDriveGetUserInfoAPIRequest *requestq = [[NXOneDriveGetUserInfoAPIRequest alloc]initWithRepo:self.boundService accessTokenKeyword:ONEDRIVE_ACCESSTOKEN_KEYWORD];
        self.usedInfoReq = requestq;
        WeakObj(self);
        [requestq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            StrongObj(self);
            if (self) {
                if (!error) {
                    NSDictionary *infoDic = ((NXOneDriveGetUserInfoAPIResponse *)response).userInfo;
                    self.userName = infoDic[@"owner"][@"user"][@"displayName"];
                    NSString *total = infoDic[@"quota"][@"total"];
                    NSString *used = infoDic[@"quota"][@"used"];
                    self.totalQuota = [NSNumber numberWithInteger:[total integerValue]];
                    self.usedQuota = [NSNumber numberWithInteger:[used integerValue]];
                    if ([_delegate respondsToSelector:@selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:)]) {
                        [_delegate getUserInfoFinished:self.userName     userEmail:self.userEmail totalQuota:self.totalQuota usedQuota:self.usedQuota error:error];
                    }
                }else{
                    if ([_delegate respondsToSelector:@selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:)])
                    {
                        [_delegate getUserInfoFinished:nil userEmail:nil totalQuota:nil usedQuota:nil error:error];
                    }
                }
            }
        }];
        return YES;
    }
    return NO;
}

- (BOOL)cancelGetUserInfo {
    if (self.usedInfoReq) {
        [self.usedInfoReq cancelRequest];
    }
    return YES;
}

- (NSString *)getServiceAlias {
    return self.alias;
}

- (void)setAlias:(NSString *)alias {
    _alias = alias;
}

-(void)fetchFileInfo:(NXFileBase*)file andFileData:(NXOneDriveFileItem*)fileItem
{
    file.name = fileItem.name;
    file.fullPath = [_curFileBase.fullPath stringByAppendingPathComponent:fileItem.name];
    file.fullServicePath = fileItem.fileId;
    file.size = fileItem.size;
    
    NSString *updateTime = fileItem.lastModifiedDateTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate* lastModifydate = [dateFormatter dateFromString:updateTime];
    NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:lastModifydate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
    
    file.lastModifiedDate = lastModifydate;
    file.lastModifiedTime = lastModifydateString;
    file.serviceAccountId = _userID;
    file.serviceType = [NSNumber numberWithInteger:kServiceOneDrive];
    file.parent = _curFileBase;
    file.serviceAlias = [self getServiceAlias];
    file.sorceType = NXFileBaseSorceTypeRepoFile;
}

-(void)getFilesFinished:(NSArray<NXOneDriveFileItem*>*)data
{
    if (self.enumFolderStack.count) {
        NXFolder *parentFolder = self.enumFolderStack.lastObject;
        [self.enumFolderStack removeLastObject];
        
        for( NXOneDriveFileItem *fileItem in data)
        {
            NXFileBase *file = nil;
            if(fileItem.folderYes)
            {
                file = [[NXFolder alloc]init];
            }
            else
            {
                file = [[NXFile alloc]init];
            }
            [self fetchFileInfo:file andFileData:fileItem];
            file.strongRefParent = [parentFolder copy];
            file.parent = file.strongRefParent;
            
            if ([file isKindOfClass:[NXFile class]]) {
                [self.recursiveFileList addObject:file];
            }else if([file isKindOfClass:[NXFolder class]])
            {
                [self.enumFolderStack addObject:file];
            }
        }
        
        if (self.enumFolderStack.count == 0) {
            if ([self.delegate respondsToSelector:@selector(getAllFiles:fromFolder:error:)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate getAllFiles:self.recursiveFileList fromFolder:_curFileBase error:nil];
                    self.recursiveFileList = nil;
                    self.enumFolderStack = nil;
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NXFolder *folder = [self.enumFolderStack lastObject];
                [self getFiles:folder];
            });
        }
        
        return;
    }
    NSMutableArray *fileList = [NSMutableArray array];
    for(NXOneDriveFileItem* fileData in data)
    {
        NXFileBase *file = nil;
        [self fetchFileInfo:file andFileData:fileData];
        if(fileData.folderYes)
        {
            file = [[NXFolder alloc]init];
        }
        else
        {
            file = [[NXFile alloc]init];
        }
        [self fetchFileInfo:file andFileData:fileData];
        [fileList addObject:file];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(getFilesFinished:error:)]) {
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [_delegate getFilesFinished:fileList error:nil];
        });
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(serviceOpt:getFilesFinished:error:)]) {
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [_delegate serviceOpt:self getFilesFinished:fileList error:nil];
            
        });
    }
}

-(void)downloadFileFinished:(NSData*)data {
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
        dispatch_main_sync_safe(^{
            [_delegate downloadFileFinished:_curFileBase fileData:data error:nil];
        });
    }
}
- (void)downloadFileFailed:(NSError *)error {
    if(error.code != NXRMC_ERROR_CODE_CANCEL)
    {
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
            [self.delegate downloadFileFinished:_curFileBase fileData:nil error:error];
        }
    }
}

- (void)uploadFileFinished:(NXFileBase *)fileItem fromLocalPath:(NSString *)localCachePath error:(NSError *)error {
    if (error.code != NXRMC_ERROR_CODE_CANCEL) {
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
            [self.delegate uploadFileFinished:fileItem fromLocalPath:localCachePath error:error];
        }
    }
}
@end
