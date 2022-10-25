//
//  NXGoogleDrive.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 27/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGoogleDrive.h"
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"
#import "AppDelegate.h"
#import "NXFolder.h"
#import "NXFile.h"
#import "NXFileBase.h"
#import "GTLRDrive.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXRepoFileStorage.h"
#import "NXGoogleDriveFileListAPI.h"
#import "NXGoogleDriveGetUserInfoAPI.h"
#import "NXGoogleDriveDownloadAPI.h"
#import "NXGoogleDriveFileBase.h"
#import "NXGoogleDriveFileListQuery.h"
#import "NXGoogleDriveGetFileMetaDataAPI.h"
#import "NXGoogleDriveUploadAPI.h"

#define GoogleDrive_ACCESSTOKEN_KEYWORD @"Authorization"

static NSString *const kKeyGoogleDriveRoot          = @"root";
static NSString *const kGoogleDriveFolderMimetype   = @"application/vnd.google-apps.folder";

@interface NXGoogleDrive()
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NXFileBase *curFile;

@property(nonatomic, strong) NSMutableDictionary *getUserInfoRequestDic;
@property(nonatomic, strong) NSMutableDictionary *getFilesRequestDic;
@property(nonatomic, strong) NSMutableDictionary *downloadFileRequestDic;
@property(nonatomic, strong) NSMutableDictionary *uploadFileRequestDic;

@property(nonatomic, strong) NSProgress *downloadProgross;
@property(nonatomic, strong) NXFileBase *currentDownloadFile;
@property(nonatomic, strong) NXGoogleDriveUploadAPIRequest *uploadFileReq;

@end

@implementation NXGoogleDrive
- (id) initWithUserId: (NSString *)userId repoModel:(NXRepositoryModel *)repoModel {
    if (self = [super init]) {
        _userId = userId;
        _repoModel = [repoModel copy];
        _getUserInfoRequestDic = [[NSMutableDictionary alloc] init];
        _getFilesRequestDic = [[NSMutableDictionary alloc] init];
        _downloadFileRequestDic = [[NSMutableDictionary alloc] init];
        _uploadFileRequestDic = [[NSMutableDictionary alloc] init];
        
       _downloadProgross = [[NSProgress alloc] init];
       [_downloadProgross addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (NSString *)getServiceAlias
{
    return self.repoModel.service_alias;
}

- (NSString *)alias
{
    return [self getServiceAlias];
}

- (void) setDelegate:(id<NXServiceOperationDelegate>)delegate {
    _delegate = delegate;
}

#pragma mark - NXServiceOperation
- (BOOL)getFiles:(NXFileBase *)folder {
    if (!folder) {
        return NO;
    }
    
    if([folder isRoot]) {
        folder.fullPath = @"/";
        folder.fullServicePath = kKeyGoogleDriveRoot;
    }
    
    self.curFile = folder;
    if (self.getFilesRequestDic.allValues.count >0) {
        for (NXGoogleDriveFileListAPIRequest *req in self.getFilesRequestDic.allValues) {
            [req cancelRequest];
        }
        [self.getFilesRequestDic removeAllObjects];
    }
 
    NXGoogleDriveFileListAPIRequest *req = [[NXGoogleDriveFileListAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:GoogleDrive_ACCESSTOKEN_KEYWORD];
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    [self.getFilesRequestDic setObject:req forKey:optIdentify];
    
      WeakObj(self);
    [req requestWithObject:folder.fullServicePath Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        
        if (self) {
            NXGoogleDriveFileListAPIResponse *rsp = (NXGoogleDriveFileListAPIResponse *)response;
            NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
            for (NXGoogleDriveFileBase *googleDrvieFileItem in rsp.files) {
                NXFileBase* nxFileItem = [self fetchFileinfo:googleDrvieFileItem];
                if (nxFileItem) {
                    [fileListArray addObject:nxFileItem];
                }
            }
            
            NSError *nxError = nil;
            if (error) {
                nxError = [self convertErrorIntoNXError:error];
            }
            [self.delegate getFilesFinished:fileListArray error:nxError];
            return;
        }
    }];
    return YES;
}

-(BOOL)deleteFileItem:(NXFileBase*)file
{
    return NO;
}

- (BOOL)addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder
{
    return NO;
}

- (BOOL)cancelGetFiles:(NXFileBase *)folder
{
    if (self.getFilesRequestDic.count > 0) {
        for (NXSuperRESTAPIRequest *request in _getFilesRequestDic.allValues) {
            [request cancelRequest];}
        [self.getFilesRequestDic removeAllObjects];
    }
    
    NSError *error = [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_CODE_CANCEL userInfo:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(getFilesFinished:error:)]) {
        [_delegate getFilesFinished:nil error:error];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(serviceOpt:getFilesFinished:error:)]) {
        [_delegate serviceOpt:self getFilesFinished:nil error:error];
    }
    return YES;
}

- (BOOL)downloadFile:(NXFileBase *)file size:(NSUInteger)size {
    if (self.downloadFileRequestDic.allValues.count >0) {
        for (NXGoogleDriveDownloadAPIRequest *req in self.downloadFileRequestDic.allValues) {
            [req cancelRequest];
        }
        [self.downloadFileRequestDic removeAllObjects];
    }
  
    if (file && [file isKindOfClass:[NXFile class]]) {
        _currentDownloadFile = file;
        NXGoogleDriveGetFileMetaDataAPIRequest *request = [[NXGoogleDriveGetFileMetaDataAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:GoogleDrive_ACCESSTOKEN_KEYWORD];
        [request requestWithObject:file.fullServicePath Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            if (!error) {
                NXGoogleDriveGetFileMetaDataAPIResponse *rsp = (NXGoogleDriveGetFileMetaDataAPIResponse *)response;
                if ([GOOGLEDRIVEDOCUMENTTYPEARRAY containsObject:rsp.mimeType]) {
                    NXGoogleDriveDownloadAPIRequest *req = [[NXGoogleDriveDownloadAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:GoogleDrive_ACCESSTOKEN_KEYWORD];
                    req.isGoogleDoc = YES;
                    NSString *convertedType = [self convertGoogleTypeToMSTypeWith:rsp.mimeType file:file];
                    req.mimeType = convertedType;
                    
                    NSString *optIdentify = [[NSUUID UUID] UUIDString];
                    [self.downloadFileRequestDic setObject:req forKey:optIdentify];
                    
                    [req requestWithObject:file.fullServicePath withUploadProgress:nil downloadProgress:_downloadProgross Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                        NXGoogleDriveDownloadAPIResponse *rspp = (NXGoogleDriveDownloadAPIResponse *)response;
                        if (!error) {
                            NSLog(@"Downloaded %lu bytes", (unsigned long)rspp.fileData.length);
                            file.size = rspp.fileData.length;
                            [NXRepoFileStorage updateFileItemSize:file];
                            
                            [self.delegate downloadFileFinished:file fileData:rspp.fileData error:nil];
                        }
                        else{
                            [self.delegate downloadFileFinished:file fileData:nil error:error];
                        }
                    }];
                }
                else{
                    
                    NXGoogleDriveDownloadAPIRequest *req = [[NXGoogleDriveDownloadAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:GoogleDrive_ACCESSTOKEN_KEYWORD];
                    req.isGoogleDoc = NO;
                    
                    NSString *optIdentify = [[NSUUID UUID] UUIDString];
                    [self.downloadFileRequestDic setObject:req forKey:optIdentify];
                    
                    [req requestWithObject:file.fullServicePath withUploadProgress:nil downloadProgress:_downloadProgross Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                         NXGoogleDriveDownloadAPIResponse *rspp = (NXGoogleDriveDownloadAPIResponse *)response;
                        if (!error) {
                            [self.delegate downloadFileFinished:file fileData:rspp.fileData error:nil];
                        }
                        else{
                            [self.delegate downloadFileFinished:file fileData:nil error:error];
                        }
                    }];
                }
            }else{
                [self.delegate downloadFileFinished:file fileData:nil error:error];
            }
        }];
        return YES;
    }
    return NO;
}

- (BOOL)cancelDownloadFile:(NXFileBase *)file {
    if (![file isKindOfClass:[NXFile class]]) {
        return NO;
    }
    
    if (self.downloadFileRequestDic.count > 0) {
        for (NXSuperRESTAPIRequest *request in _downloadFileRequestDic.allValues) {
            [request cancelRequest];}
        [self.downloadFileRequestDic removeAllObjects];
        return YES;
    }
    return NO;
}

// TO DO upload file
- (BOOL)uploadFile:(NSString *)filename toPath:(NXFileBase *)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile{
    NSURL *fileToUploadURL = [NSURL fileURLWithPath:srcPath];
    NSError *fileError;
    if (![fileToUploadURL checkPromisedItemIsReachableAndReturnError:&fileError]) {
        NSLog(@"Can't read file from path %@", fileToUploadURL);
        return NO;
    }
    
    // Queries that support file uploads take an uploadParameters object.
    // The uploadParameters include the MIME type of the file being uploaded,
    // and either an NSData with the file contents, or a URL for
    // the file path.
    self.curFile = folder;
    if(!filename || !srcPath || !folder.fullPath){
          return NO;
     }
    NSData *fileData = [[NSData alloc]initWithContentsOfFile:srcPath];
       if (folder.isRoot || [folder.fullPath isEqualToString:@""]) {
           folder.fullPath = @"/";
     }
    
    NXGoogleDriveUploadAPIRequest *uploadRequest = [[NXGoogleDriveUploadAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:GoogleDrive_ACCESSTOKEN_KEYWORD];
    NSDictionary *parameters ;
    if (folder.fullServicePath.length > 0) {
       parameters  = @{@"name":filename,@"fileData":fileData,@"parentPath":folder.fullServicePath};
    }else{
         parameters = @{@"name":filename,@"fileData":fileData};
    }
    self.uploadFileReq = uploadRequest;
    [uploadRequest requestWithObject:parameters withUploadProgress:nil downloadProgress:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXFile *file = [[NXFile alloc] init];
        file.name = filename;
           if (!error) {
               if (DELEGATE_HAS_METHOD(_delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                              [self.delegate uploadFileFinished:file fromLocalPath:srcPath error:nil];
                    }
           }
           else{
               if (DELEGATE_HAS_METHOD(_delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                                             [self.delegate uploadFileFinished:file fromLocalPath:srcPath error:error];
                    }
           }
        
    }];
    return YES;
}

-(BOOL)cancelUploadFile:(NSString*)filename toPath:(NXFileBase*)folder
{
    [self.uploadFileReq cancelRequest];
    return YES;
}

- (BOOL)getMetaData:(NXFileBase *)file
{
    return NO;
}

- (BOOL)cancelGetMetaData:(NXFileBase *)file
{
    return NO;
}

- (BOOL)getUserInfo
{
    if (self.getUserInfoRequestDic.allValues.count >0) {
        for (NXGoogleDriveGetUserInfoAPIRequest *req in self.getUserInfoRequestDic.allValues) {
            [req cancelRequest];
        }
        [self.getUserInfoRequestDic removeAllObjects];
    }
  
    WeakObj(self);
    NXGoogleDriveGetUserInfoAPIRequest *req = [[NXGoogleDriveGetUserInfoAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:GoogleDrive_ACCESSTOKEN_KEYWORD];
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    [self.getUserInfoRequestDic setObject:req forKey:optIdentify];
    [req requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        NXGoogleDriveGetUserInfoAPIResponse *resp = (NXGoogleDriveGetUserInfoAPIResponse *)response;
        NSError *aerror = [self convertErrorIntoNXError:error];
        NSString *name = resp.displayName;
        NSString *email = resp.emailAddress;
        NSNumber *totalQuota = resp.limit;
        NSNumber *usedQuota = resp.usage;
        
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
            [self.delegate getUserInfoFinished:name userEmail:email totalQuota:totalQuota usedQuota:usedQuota error:aerror];
        }
    }];
    return YES;
}

- (BOOL)cancelGetUserInfo
{
    if (self.getUserInfoRequestDic.count > 0) {
        for (NXSuperRESTAPIRequest *request in _getUserInfoRequestDic.allValues) {
            [request cancelRequest];}
        [self.getUserInfoRequestDic removeAllObjects];
    }
    return YES;
}

-(BOOL) isProgressSupported
{
    return YES;
}

- (NSString *)convertGoogleTypeToMSTypeWith:(NSString *)mimeType file:(NXFileBase *)file
{
    if ([mimeType isEqualToString:@"application/vnd.google-apps.document"]) {
        file.name = [file.name stringByAppendingString:@".docx"];
        return @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    }else if ([mimeType isEqualToString:@"application/vnd.google-apps.spreadsheet"]){
        file.name = [file.name stringByAppendingString:@".xlsx"];
        return @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    }else if ([mimeType isEqualToString:@"application/vnd.google-apps.drawing"]){
        file.name = [file.name stringByAppendingString:@".png"];
        return @"image/png";
    }else if ([mimeType isEqualToString:@"application/vnd.google-apps.presentation"]){
        file.name = [file.name stringByAppendingString:@".pptx"];
        return @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
    }
    return nil;
}

- (void)dealloc
{
      [_downloadProgross removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}


#pragma mark - tool method
- (NSError *) convertErrorIntoNXError:(NSError *) error
{
    if (error == nil) {
        return nil;
    }
    
    if (error.code == 400) {
        if ([error.userInfo[@"json"][@"error"] isEqualToString:@"invalid_grant"]) {
            error = [NXCommonUtils getNXErrorFromErrorCode:NXRMC_ERROR_SERVICE_ACCESS_UNAUTHORIZED error:error];
        }
    }else if(error.code == 401 || error.code == 403)
    {
        NSData *errorData = error.userInfo[@"data"];
        error = [NXCommonUtils getNXErrorFromErrorCode:NXRMC_ERROR_SERVICE_ACCESS_UNAUTHORIZED error:error];
        
        if(errorData){
            NSDictionary *errorDic = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableContainers error:nil];
            if (errorDic) {
                NSString *message = errorDic[@"error"][@"message"];
                if ([message isEqualToString:@"The user's Drive storage quota has been exceeded."]) {
                    error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_STORAGE_DOMAIN code:NXRMC_ERROR_CODE_REPO_STORAGE_MANAGER_EXCEEDED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DRIVE_STORAGE_EXCEEDED", NULL)}];
                }
            }
        }
    }else if(error.code < 0 && error.code != NSURLErrorCancelled)
    {
        error = [NXCommonUtils getNXErrorFromErrorCode:NXRMC_ERROR_CODE_TRANS_BYTES_FAILED error:error];
        
    }
    
    return error;
}

- (NXFileBase *)fetchFileinfo:(NXGoogleDriveFileBase *)file
{
    if (file) {
        NXFileBase *fileItem = nil;
        if ([file.mimeType isEqualToString:kGoogleDriveFolderMimetype]) {
            fileItem = [[NXFolder alloc] init];
        }else{
            fileItem = [[NXFile alloc] init];
        }
        
        fileItem.name = file.name;
        fileItem.lastModifiedDate = file.lastModifiedTime;
        NSString *dateString = [NSDateFormatter localizedStringFromDate:file.lastModifiedTime
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        fileItem.lastModifiedTime = dateString;
        fileItem.size = [file.size longLongValue];
        fileItem.fullServicePath = file.fileId;
        fileItem.serviceType = [NSNumber numberWithInteger:kServiceGoogleDrive];
        fileItem.isRoot = NO;
        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
        if (self.curFile) {
            if (self.curFile.isRoot) {
                fileItem.fullPath = [NSString stringWithFormat:@"/%@", fileItem.name];
            }else{
                fileItem.fullPath = [NSString stringWithFormat:@"%@/%@", self.curFile.fullPath, fileItem.name];
            }
        }
        return fileItem;
    }
    return nil;
}

#pragma -mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))] && [object isEqual:self.downloadProgross]) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileProgress:forFile:))) {
                [self.delegate downloadFileProgress:self.downloadProgross.fractionCompleted forFile:_currentDownloadFile.name];
                NSLog(@"++++++downloadprogress is : %f",self.downloadProgross.fractionCompleted);
            }
        }
    });
}
@end

