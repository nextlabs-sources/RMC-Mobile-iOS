//
//  NXSkyDrmBox.m
//  nxrmc
//
//  Created by nextlabs on 10/25/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSkyDrmBox.h"

#import "SDClient.h"
#import "SDMetadata.h"

#import "NXFileBase.h"
#import "NXFile.h"
#import "NXFolder.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXCacheManager.h"

static NSString *const kKeySkyDrmBoxRev = @"NXSkyDrmBoxRev";

@interface NXSkyDrmBox()<SDClientDelegate>

@property(nonatomic, weak) id<NXServiceOperationDelegate> delegate;

@property(nonatomic, strong) SDClient *client;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *alias;
@property(nonatomic, strong) NXRepositoryModel *boundService;

@property(nonatomic, strong) NXFileBase *curFolder;
@property(nonatomic, strong) NXFileBase *curDownloadFile;
@end


@implementation NXSkyDrmBox

- (instancetype)initWithUserId:(NSString *)userID repoModel:(NXRepositoryModel *)repoModel{
    if (self = [super init]) {
        self.userId = userID;
        self.client = [[SDClient alloc]initWithUser:[NXLoginUser sharedInstance]];
        self.client.delegate = self;
    }
    
    return self;
}

- (instancetype)initWithUserId:(NSString *)userID
{
    if (self = [super init]) {
        self.userId = userID;
        self.client = [[SDClient alloc]initWithUser:[NXLoginUser sharedInstance]];
        self.client.delegate = self;
    }
    return self;
}

#pragma mark -

- (BOOL)getFiles:(NXFileBase *)folder {
    [self.client loadMemadata:folder.fullServicePath recursive:NO];
    _curFolder = folder;
    return YES;
}

- (BOOL)getAllFilesInFolder:(NXFileBase *)folder {
    _curFolder = folder;
    [self.client loadMemadata:folder.fullServicePath recursive:YES];
    return YES;
}

- (BOOL)cancelGetFiles:(NXFileBase *)folder {
    return [self.client cancelLoadMetadata:folder.fullServicePath];
}

- (BOOL)downloadFile:(NXFileBase *)file size:(NSUInteger)size {
    self.curDownloadFile = file;
    if (size > 0) {
        [self.client downloadFile:file.fullServicePath length:size intoPath:nil];
    } else {
        [self.client downloadFile:file.fullServicePath intoPath:nil];
    }
    return YES;
}

- (BOOL)cancelDownloadFile:(NXFileBase *)file {
    self.curDownloadFile = nil;
    return [self.client cancelFileLoad:file.fullServicePath];
}

- (BOOL)uploadFile:(NSString *)filename toPath:(NXFileBase *)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile {
    _curFolder = folder;
    if (type == NXUploadTypeOverWrite) {
        _overWriteFile = overWriteFile;
        if ([overWriteFile isKindOfClass:[NXFile class]]) {
                  _overWriteFile = overWriteFile;
        }
        [self.client uploadfile:filename fromPath:srcPath toPath:folder.fullServicePath overWriteFile:overWriteFile.fullServicePath];
    } else {
        _overWriteFile = nil;
        [self.client uploadfile:filename fromPath:srcPath toPath:folder.fullServicePath overWriteFile:nil];
    }

//    [self.client uploadfile:filename fromPath:srcPath toPath:folder.fullServicePath overWriteFile:overWriteFile.fullServicePath];
    return YES;
}

- (BOOL)cancelUploadFile:(NSString *)filename toPath:(NXFileBase *)folder {
    NSString *fullpath = [NSString stringWithFormat:@"%@/%@", folder.fullServicePath, filename];
    [self.client cancelFileUpload:fullpath];
    return YES;
}
-(BOOL) deleteFileItem:(NXFileBase*)file{
     [self.client deletePath:file.fullServicePath];
    return YES;
}

- (BOOL)addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder {
    if(parentFolder.fullServicePath==nil){
        parentFolder.fullServicePath=@"/";
    }
    [self.client createFolder:folderName underParent:parentFolder];
    return YES;
}

- (BOOL)getMetaData:(NXFileBase *)file {
    //TBD
    return NO;
}

- (BOOL)cancelGetMetaData:(NXFileBase *)file {
    //TBD
    return NO;
}

- (void)setDelegate:(id<NXServiceOperationDelegate>)delegate {
    _delegate = delegate;
}

- (BOOL)isProgressSupported {
    return NO;
}

- (void)setAlias:(NSString *)alias {
    _alias = alias;
}

- (NSString *)getServiceAlias {
    return self.alias;
}

- (BOOL)getUserInfo {
    [self.client getRepositoryInfo];
    return YES;
}

- (BOOL)cancelGetUserInfo {
    return NO;
}

- (void) fetchFileInfo:(NXFileBase *)file MetaData:(SDMetadata *) metaData {
    file.fullPath = metaData.path;
    file.fullServicePath = metaData.fileID;
    NSString *dateString = [NSDateFormatter localizedStringFromDate:metaData.lastmodifiedDate
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    
    file.lastModifiedDate = metaData.lastmodifiedDate;
    file.lastModifiedTime = dateString;
    file.size = metaData.fileSize;
    file.name = metaData.filename;
    file.isRoot = NO;
    file.serviceAccountId = self.userId;
    file.serviceType = [NSNumber numberWithInteger:kServiceSkyDrmBox];
    file.serviceAlias = [self getServiceAlias];
    file.sorceType = NXFileBaseSorceTypeRepoFile;
}

#pragma mark - SDClientDelegate

- (void)client:(SDClient *)client loadedMetaData:(SDMetadata *)metaData error:(NSError *)error {
    NSMutableArray *filelist = [NSMutableArray array];
    
    NSDate* now = [NSDate date];
    for (SDMetadata *file in metaData.contents){
        NXFileBase *f = nil;
        if (file.isDirectory) {
            f = [[NXFolder alloc] init];
        }
        else {  // is file
            f = [[NXFile alloc] init];
            f.refreshDate = now;
        }
        [self fetchFileInfo:f MetaData:file];
        f.parent = _curFolder;
        [filelist addObject:f];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(getFilesFinished:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate getFilesFinished:filelist error:error];
        });
        
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(serviceOpt:getFilesFinished:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [_delegate serviceOpt:self getFilesFinished:filelist error:nil];
        });
    }
}

- (void)client:(SDClient *)client downloadedFile:(NSString *)destPath metadata:(SDMetadata *)metadata error:(NSError *)error {
    //TODO
}

- (void)client:(SDClient *)client downloadedContent:(NSData *)content metadata:(SDMetadata *)metadata error:(NSError *)error {
    if ([error.localizedDescription isEqualToString:@"The network connection was lost."]) {
        error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_DOWNLOAD_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)}];
    }
    
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloadFileFinished:self.curDownloadFile fileData:content error:error];
        });
    }
}

- (void)client:(SDClient *)client loadProgress:(float)progress forFile:(NSString *)path {
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFileProgress:forFile:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.delegate downloadFileProgress:progress forFile:path];
        });
       
    }
}

-(void)client:(SDClient *)client uploadProgress:(float)progress forFile:(NSString *)destpath fromPath:(NSString *)srcpath
{
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileProgress:forFile:fromPath:))) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate uploadFileProgress:progress forFile:destpath fromPath:srcpath];
        });
    }
}
- (BOOL)cacheNewUploadFile:(NXFileBase *) uploadFile sourcePath:(NSString *)srcpath {
    return YES;
//    NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:uploadFile];
//
//    NSURL *url = [NXCacheManager getLocalUrlForServiceCache:repoModel];
//    
//    NSString *localPath = [[[url path] stringByAppendingPathComponent:CACHEROOTDIR] stringByAppendingPathComponent:uploadFile.fullPath];
//    
//    NSFileManager *manager = [NSFileManager defaultManager];
//    NSError *error;
//    if ([manager fileExistsAtPath:localPath]) {
//        [manager removeItemAtPath:localPath error:&error];
//    }
//    
//    BOOL ret = [manager moveItemAtPath:srcpath toPath:localPath error:&error];
//    if (ret) {
//        [NXCommonUtils storeCacheFileIntoCoreData:uploadFile cachePath:localPath];
//        [NXCommonUtils setLocalFileLastModifiedDate:localPath date:uploadFile.lastModifiedDate];
//    } else {
//        NSLog(@"SkyDrmbox service cache file %@ failed", localPath);
//    }
//    
//    return YES;
}

- (void)client:(SDClient *)client uploadFile:(NSString *)destpath fromPath:(NSString *)srcPath metadata:(SDMetadata *)metadata error:(NSError *)error {
    //TBD
    NXFile* uploadedfile = [[NXFile alloc] init];
    if (error == nil) {
        if (_overWriteFile) {
            [self fetchFileInfo:_overWriteFile MetaData:metadata];
            [self cacheNewUploadFile:_overWriteFile sourcePath:srcPath];
            if (DELEGATE_HAS_METHOD(_delegate, @selector(uploadFileFinished:fromPath:error:))) {
                [_delegate uploadFileFinished: _overWriteFile.fullServicePath fromPath:srcPath error:nil];
            }
            
            if (DELEGATE_HAS_METHOD(_delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                [_delegate uploadFileFinished:_overWriteFile fromLocalPath:srcPath error:nil];
            }
        } else {
            [self fetchFileInfo:uploadedfile MetaData:metadata];
            [self cacheNewUploadFile:uploadedfile sourcePath:srcPath];
            //add new uploaded file into FileSys cache.
            uploadedfile.parent = _curFolder;
            [_curFolder addChild:uploadedfile];
            if (DELEGATE_HAS_METHOD(_delegate, @selector(uploadFileFinished:fromPath:error:))) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate uploadFileFinished: uploadedfile.fullServicePath fromPath:srcPath error:nil];
                });
            }
            
            if (DELEGATE_HAS_METHOD(_delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate uploadFileFinished:uploadedfile fromLocalPath:srcPath error:nil];
                });
            }
        }
    }else{
        if (error.code == 5000) {
            error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_DOWNLOAD_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPLOAD_FAILED", nil)}];
        }
            if (self.delegate && [self.delegate respondsToSelector:@selector(uploadFileFinished:fromPath:error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate uploadFileFinished:nil fromPath:srcPath error:error];
            });
        }
        
        if (DELEGATE_HAS_METHOD(_delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate uploadFileFinished:nil fromLocalPath:srcPath error:error];
            });
        }
    }
    
}
- (void)client:(SDClient *)client deletedPath:(NSString *)path
{
    if(DELEGATE_HAS_METHOD(_delegate, @selector(deleteItemFinished:)))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
             [_delegate deleteItemFinished:nil];
        });
       
    }
}

- (void)client:(SDClient*)client deletePathFailedWithError:(NSError*)error
{
    if (DELEGATE_HAS_METHOD(_delegate, @selector(deleteItemFinished:))) {
        dispatch_async(dispatch_get_main_queue(), ^{
              [_delegate deleteItemFinished:error];
        });
      
    }
}

- (void)client:(SDClient*)client createdFolder:(SDMetadata*)folder {
    if (DELEGATE_HAS_METHOD(_delegate, @selector(addFolderFinished:error:))) {
        NXFolder *newfolder = [[NXFolder alloc] init];
        [self fetchFileInfo:newfolder MetaData:folder];
//        NXFileBase *newFileBase=[[NXFileBase alloc]init];
        newfolder.fullPath=folder.path;
        newfolder.fullServicePath=folder.fileID;
        newfolder.name=folder.filename;
        
        dispatch_async(dispatch_get_main_queue(), ^{
//             [_delegate addFloderFinished:nil];
            [_delegate addFolderFinished:newfolder error:nil];
        });
       
    }
}
- (void)client:(SDClient*)client createFolderFailedWithError:(NSError*)error {
    if (DELEGATE_HAS_METHOD(_delegate, @selector(addFolderFinished:error:))) {
        dispatch_async(dispatch_get_main_queue(), ^{
//             [_delegate addFloderFinished:error];
            [_delegate addFolderFinished:nil error:error];
        });
       
    }
}


- (void)client:(SDClient *)client getRepositoryInfo:(NSString *)userName userEmail:(NSString *)userEmail totalQuota:(NSNumber *)totalQuota usedQuota:(NSNumber *)usedQuota error:(NSError *)error
{
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
        [self.delegate getUserInfoFinished:userName userEmail:userEmail totalQuota:totalQuota usedQuota:usedQuota error:error];
    }
}

@end

