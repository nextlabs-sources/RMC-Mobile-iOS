//
//  NXGoogleDriveNew.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 4/24/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGoogleDrive1.h"
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


static NSString *const kKeyGoogleDriveRoot          = @"root";
static NSString *const kGoogleDriveFolderMimetype   = @"application/vnd.google-apps.folder";

@interface NXGoogleDrive1()
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) GTLRDriveService *googleDriveService;
@property (nonatomic, weak)id<NXServiceOperationDelegate> delegate;
@property(nonatomic, strong) NXFileBase *curFile;

@property(nonatomic, strong) GTLRServiceTicket *fileListTicket;
@property(nonatomic, strong) GTLRServiceTicket *fileMetaDataTicket;
@property(nonatomic, strong) GTLRServiceTicket *editFileListTicket;
@property(nonatomic, strong) GTLRServiceTicket *uploadFileTicket;
@property(nonatomic, strong) GTMSessionFetcher *downloadFetcher;
@property(nonatomic, strong) GTLRServiceTicket *userInfoTicket;
@property(nonatomic, strong) GTMSessionFetcher *rangeDownloadTicket;
@end

@implementation NXGoogleDrive1
- (id) initWithUserId: (NSString *)userId repoModel:(NXRepositoryModel *)repoModel {
    if (self = [super init]) {
        _userId = userId;
        _repoModel = [repoModel copy];
        _googleDriveService = [[GTLRDriveService alloc] init];
        _googleDriveService.shouldFetchNextPages = YES;
        _googleDriveService.retryEnabled = YES;
        _googleDriveService.callbackQueue = dispatch_queue_create("com.skydrm.rmcent.NXGoogleDrive", DISPATCH_QUEUE_SERIAL);
        _googleDriveService.authorizer = [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:_repoModel.service_account_token];
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

#pragma mark - NXServiceOperation
- (BOOL)getFiles:(NXFileBase *)folder {
    if (self.googleDriveService.authorizer) {
        if (!folder) {
            return NO;
        }
        
        if([folder isRoot]) {
            folder.fullPath = @"/";
            folder.fullServicePath = kKeyGoogleDriveRoot;
        }
        
        self.curFile = folder;
        GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
        query.q = [NSString stringWithFormat:@"trashed = false and '%@' IN parents", folder.fullServicePath];
        query.fields = @"files(mimeType,id,kind,name,modifiedTime,size)";
        WeakObj(self);
        self.fileListTicket = [self.googleDriveService executeQuery:query completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                                        GTLRDrive_FileList *fileList,
                                                                        NSError *callbackError) {
            _fileListTicket = nil;
            StrongObj(self);
            if (self) {
                
                NSMutableArray *fileListArray = [NSMutableArray array];
                for (GTLRDrive_File *googleDrvieFileItem in fileList.files) {
                    NXFileBase* nxFileItem = [self fetchFileinfo:googleDrvieFileItem];
                    if (nxFileItem) {
                        [fileListArray addObject:nxFileItem];
                    }
                }
                NSError *nxError = nil;
                if (callbackError) {
                    nxError = [self convertErrorIntoNXError:callbackError];
                }
                [self.delegate getFilesFinished:fileListArray error:nxError];
            }
        }];
        return YES;
    }
    return NO;
}

-(BOOL)deleteFileItem:(NXFileBase*)file
{
    if (file && self.googleDriveService.authorizer) {
        GTLRDriveQuery_FilesDelete *query = [GTLRDriveQuery_FilesDelete queryWithFileId:file.fullServicePath];
        query.supportsTeamDrives = YES;
        WeakObj(self);
        _editFileListTicket = [self.googleDriveService executeQuery:query
                                  completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                      id nilObject,
                                                      NSError *callbackError) {
                                      StrongObj(self);
                                      if (self) {
                                          // Callback
                                          _editFileListTicket = nil;
                                          NSError *error = [self convertErrorIntoNXError:callbackError];
                                          [self.delegate deleteItemFinished:error];

                                      }
                                      
                                  }];
        return YES;
    }
    return NO;
}

- (BOOL)addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder
{
    if (parentFolder && folderName && self.googleDriveService.authorizer) {
        GTLRDrive_File *folderObj = [GTLRDrive_File object];
        folderObj.name = folderName;
        folderObj.mimeType = @"application/vnd.google-apps.folder";
        folderObj.parents = @[parentFolder.fullServicePath];
        // To create a folder in a specific parent folder, specify the addParents property
        // for the query.
        self.curFile = parentFolder;
        GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:folderObj
                                                                    uploadParameters:nil];
        WeakObj(self);
        _editFileListTicket = [self.googleDriveService executeQuery:query
                                  completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                      GTLRDrive_File *folderItem,
                                                      NSError *callbackError) {
                                      StrongObj(self);
                                      if (self) {
                                          self.editFileListTicket = nil;
                                          NXFileBase *nxFile = [self fetchFileinfo:folderItem];
                                          NSError *error = [self convertErrorIntoNXError:callbackError];
                                          [self.delegate addFolderFinished:nxFile error:error];
                                      }
                                  }];
        return YES;
    }
    
    return NO;
}

- (BOOL)cancelGetFiles:(NXFileBase *)folder
{
    [self.editFileListTicket cancelTicket];
    self.editFileListTicket = nil;
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
    if (file && [file isKindOfClass:[NXFile class]]) {
        
        if (self.googleDriveService.authorizer) {
            
            GTLRDriveQuery_FilesGet *query = [GTLRDriveQuery_FilesGet queryWithFileId:file.fullServicePath];
           // query.fields = @"files(mimeType,id,kind,name,modifiedTime,size)";
            
            WeakObj(self);
            self.fileMetaDataTicket = [self.googleDriveService executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
                StrongObj(self);
                if (self) {
                    self.fileMetaDataTicket = nil;
                    if([object isKindOfClass:[GTLRDrive_File class]]){
                        GTLRDrive_File *googleFile = (GTLRDrive_File *)object;
                        // judge is google doc type
                        if ([GOOGLEDRIVEDOCUMENTTYPEARRAY containsObject:googleFile.mimeType]) {
                            NSString *fileId = file.fullServicePath;
                            NSString *convertedType = [self convertGoogleTypeToMSTypeWith:googleFile.mimeType file:file];
                            
                            GTLRDriveQuery_FilesExport *query = [GTLRDriveQuery_FilesExport queryForMediaWithFileId:fileId
                                                                                                           mimeType:convertedType];
                            [self.googleDriveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                                                 GTLRDataObject *fileItem,
                                                                                 NSError *error) {
                                if (error == nil) {
                                    NSLog(@"Downloaded %lu bytes", (unsigned long)fileItem.data.length);
                                    file.size = fileItem.data.length;
                                    [NXRepoFileStorage updateFileItemSize:file];
                            
                                } else {
                                    NSLog(@"An error occurred: %@", error);
                                }
                                
                                StrongObj(self);
                                if (self) {

                                    [self.delegate downloadFileFinished:file fileData:fileItem.data error:error];
                                }
                            }];
                        }
                        else
                        {
                            GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:file.fullServicePath];
                            NSURLRequest *downloadRequest = [self.googleDriveService requestForQuery:query];
                            self.downloadFetcher = [self.googleDriveService.fetcherService fetcherWithRequest:downloadRequest];
                            
                            //size > 0 means download partial download
                            if (size > 0) {
                                NSString *rangeValue = [NSString stringWithFormat:@"bytes=%lu-%lu",(long)0, (long)(size - 1)];
                                [self.downloadFetcher setRequestValue:rangeValue forHTTPHeaderField:@"Range"];
                            }
                            WeakObj(self);
                            self.downloadFetcher.receivedProgressBlock = ^(int64_t bytesWritten,
                                                                           int64_t totalBytesWritten) {
                                StrongObj(self);
                                if (self) {
                                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileProgress:forFile:))) {
                                        CGFloat fTotalWriten = totalBytesWritten;
                                        CGFloat fFileSize = file.size;
                                        CGFloat progress = fTotalWriten/fFileSize;
                                        [self.delegate downloadFileProgress:progress forFile:file.name];
                                    }
                                }
                            };
                            self.curFile = file;
                            [self.downloadFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *fetchError) {
                                StrongObj(self);
                                if (self) {
                                    self.downloadFetcher = nil;
                                    NSError *error = [self convertErrorIntoNXError:fetchError];
                                    [self.delegate downloadFileFinished:file fileData:data error:error];
                                }
                            }];
                        }
                    }
                }
            }];
            return YES;
        }
        return YES;
    }
    return NO;
}

- (BOOL)cancelDownloadFile:(NXFileBase *)file {
    if (![file isKindOfClass:[NXFile class]]) {
        return NO;
    }
    if (!self.downloadFetcher) {
        return NO;
    }
    [self.downloadFetcher stopFetching];
    self.downloadFetcher = nil;
    return YES;
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
    NSString *mimeType = [NXCommonUtils getMiMeType:srcPath];
    GTLRUploadParameters *uploadParameters =
    [GTLRUploadParameters uploadParametersWithFileURL:fileToUploadURL
                                             MIMEType:mimeType];
    GTLRDrive_File *newFile = [GTLRDrive_File object];
    newFile.name = filename;
    newFile.parents = @[folder.fullServicePath];
    GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:newFile
                                                                   uploadParameters:uploadParameters];
    NSString *destFilePath = folder.fullServicePath;
    query.executionParameters.uploadProgressBlock = ^(GTLRServiceTicket *callbackTicket,
                                                      unsigned long long numberOfBytesRead,
                                                      unsigned long long dataLength) {
        if (_delegate && [_delegate respondsToSelector:@selector(uploadFileProgress:forFile:fromPath:)]) {
            CGFloat progress = numberOfBytesRead/dataLength;
            [_delegate uploadFileProgress:progress forFile:destFilePath fromPath:srcPath];
        }
    };
    WeakObj(self);
    _uploadFileTicket = [self.googleDriveService executeQuery:query
                            completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                GTLRDrive_File *uploadedFile,
                                                NSError *callbackError) {
                                StrongObj(self);
                                if (self) {
                                    // Callback
                                    self.uploadFileTicket = nil;
                                    NSError *error = [self convertErrorIntoNXError:callbackError];
                                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                                        NXFileBase *newFile = [self fetchFileinfo:uploadedFile];
                                        NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:srcPath error:nil];
                                        if (attr) {
                                            newFile.size = ((NSNumber *)attr[NSFileSize]).longLongValue;
                                        }
                                        [_delegate uploadFileFinished:newFile fromLocalPath:srcPath error:error];
                                    }
                                }
                            }];
    return YES;
}

-(BOOL)cancelUploadFile:(NSString*)filename toPath:(NXFileBase*)folder
{
    if(self.uploadFileTicket){
        [self.uploadFileTicket cancelTicket];
    }
    self.uploadFileTicket = nil;
    return YES;
}

- (BOOL)getMetaData:(NXFileBase *)file
{
    GTLRDriveQuery_FilesGet *query = [GTLRDriveQuery_FilesGet queryWithFileId:file.fullServicePath];
    query.fields = @"files(mimeType,id,kind,name,modifiedTime,size)";
    
    if (self.googleDriveService.authorizer) {
        WeakObj(self);
        self.fileMetaDataTicket = [self.googleDriveService executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
            StrongObj(self);
            if (self) {
                self.fileMetaDataTicket = nil;
                NXFileBase *fileMetaData = nil;
                 self.curFile = file;
                if([object isKindOfClass:[GTLRDrive_File class]]){
                    fileMetaData = [self fetchFileinfo:(GTLRDrive_File*)object];
                }
                NSError *error = [self convertErrorIntoNXError:callbackError];
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(getMetaDataFinished:error:))) {
                    [self.delegate getMetaDataFinished:fileMetaData error:error];
                }
            }
            
        }];
        return YES;
    }
    return NO;
}

- (BOOL)cancelGetMetaData:(NXFileBase *)file
{
    if (self.fileMetaDataTicket) {
        [self.fileMetaDataTicket cancelTicket];
        self.fileMetaDataTicket = nil;
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)getUserInfo
{
    GTLRDriveQuery_AboutGet *aboutQuery = [GTLRDriveQuery_AboutGet query];
    aboutQuery.fields = @"user(displayName,emailAddress),storageQuota(limit,usage)";
    WeakObj(self);
    self.userInfoTicket = [self.googleDriveService executeQuery:aboutQuery completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, GTLRDrive_About *info, NSError * _Nullable callbackError) {
        StrongObj(self);
        self.userInfoTicket = nil;
        if (self) {
            NSError *error = [self convertErrorIntoNXError:callbackError];
            NSString *name = info.user.displayName;
            NSString *email = info.user.emailAddress;
            NSNumber *totalQuota = info.storageQuota.limit;
            NSNumber *usedQuota = info.storageQuota.usage;
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                [self.delegate getUserInfoFinished:name userEmail:email totalQuota:totalQuota usedQuota:usedQuota error:error];
            }
        }
    }];
    return YES;
}

- (BOOL)cancelGetUserInfo
{
    if (self.userInfoTicket) {
        [self.userInfoTicket cancelTicket];
        self.userInfoTicket = nil;
    }
    return YES;
}

- (void) setDelegate:(id<NXServiceOperationDelegate>)delegate {
    _delegate = delegate;
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

- (NXFileBase *)fetchFileinfo:(GTLRDrive_File *)file
{
    if (file) {
        NXFileBase *fileItem = nil;
        if ([file.mimeType isEqualToString:kGoogleDriveFolderMimetype]) {
            fileItem = [[NXFolder alloc] init];
        }else{
            fileItem = [[NXFile alloc] init];
        }
        
        fileItem.name = file.name;
        fileItem.lastModifiedDate = file.modifiedTime.date;
        NSString *dateString = [NSDateFormatter localizedStringFromDate:file.modifiedTime.date
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        fileItem.lastModifiedTime = dateString;
        fileItem.size = [file.size longLongValue];
        fileItem.fullServicePath = file.identifier;
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
@end
