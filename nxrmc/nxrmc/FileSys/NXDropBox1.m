//
//  NXDropBox.m
//  DropbBoxV2Test
//
//  Created by Eren (Teng) Shi on 5/18/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXDropBox1.h"
#import "ObjectiveDropboxOfficial.h"
#import "NXFile.h"
#import "NXFolder.h"
#import "NXRMCDef.h"
#import "NXCacheManager.h"

@interface NXDropBox1()
@property(nonatomic, strong) DBUserClient *dbClient;
@property(nonatomic, strong) NXFolder *curFolder;
@property(nonatomic, strong) NSMutableArray<DBFILESMetadata *> *fileListResult;
@property(nonatomic, strong) DBTask *currentTask;
@property(nonatomic, strong) NSString *repoAlias;
@property(nonatomic, strong) NSString *userId;
@end
@implementation NXDropBox1
- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel{
    if (self = [super init]) {
        _dbClient = [[DBUserClient alloc] initWithAccessToken:repoModel.service_account_token];
        _fileListResult = [[NSMutableArray alloc] init];
        _userId = userId;
    }
    return self;
}

-(NSString *) getServiceAlias
{
    return _repoAlias;
}

-(void) setAlias:(NSString *) alias
{
    _repoAlias = alias;
}
    
- (BOOL)getFiles:(NXFileBase *)folder
    {
        if (!folder) {
            return NO;
        }
        if (self.dbClient.isAuthorized) {
            if (folder.isRoot) {
                folder.fullPath = @"";
                folder.fullServicePath = @"";
            }
        _curFolder = (NXFolder *)folder;
        WeakObj(self);
        self.currentTask = [[self.dbClient.filesRoutes listFolder:folder.fullPath] setResponseBlock:^(DBFILESListFolderResult * _Nullable result, DBFILESListFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
            StrongObj(self);
            if (self) {
                if (result) {
                    NSArray<DBFILESMetadata *> *entries = result.entries;
                    NSString *cursor = result.cursor;
                    BOOL hasMore = [result.hasMore boolValue];
                    
                    [self.fileListResult addObjectsFromArray:entries];
                    
                    if (hasMore) {
                        [self listFolderContinueWithClient:self.dbClient cursor:cursor];
                    } else {
                        [self listFolder:folder completeWithError:nil];
                    }
                } else {
                    if (networkError) {
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR userInfo:@{NSLocalizedDescriptionKey:[networkError.nsError localizedDescription]?:NSLocalizedString(@"MSG_GET_FILE_LIST_ERROR", nil)}];
                        [self listFolder:folder completeWithError:error];
                        return ;
                    }
                    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_FILE_LIST_ERROR", nil)}];
                    [self listFolder:folder completeWithError:error];
                }
            }
            }];
        }
        else
        {
            return NO;
        }
        
        return YES;
}

- (void)listFolderContinueWithClient:(DBUserClient *)client cursor:(NSString *)cursor {
    WeakObj(self);
    self.currentTask = [[client.filesRoutes listFolderContinue:cursor]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderContinueError *routeError,
                        DBRequestError *networkError) {
         StrongObj(self);
         if (self) {
             if (response) {
                 NSArray<DBFILESMetadata *> *entries = response.entries;
                 NSString *cursor = response.cursor;
                 BOOL hasMore = [response.hasMore boolValue];
                 
                 [self.fileListResult addObjectsFromArray:entries];
                 
                 if (hasMore) {
                     [self listFolderContinueWithClient:client cursor:cursor];
                 } else {
                     [self listFolder:self.curFolder completeWithError:nil];
                 }
             } else {
                 if (networkError) {
                     NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR userInfo:@{NSLocalizedDescriptionKey:networkError.nsError.localizedDescription}];
                     [self listFolder:self.curFolder completeWithError:error];
                     return ;
                 }
                 NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_FILE_LIST_ERROR", nil)}];
                 [self listFolder:self.curFolder completeWithError:error];
             }
         }
     }];
}
    
-(BOOL) deleteFileItem:(NXFileBase*)file
    {
        if (file && self.dbClient.isAuthorized) {
            WeakObj(self);
            [[self.dbClient.filesRoutes delete_:file.fullPath] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESDeleteError * _Nullable routeError, DBRequestError * _Nullable networkError) {
                StrongObj(self);
                if (self) {
                    NSError *error = nil;
                    if (networkError || routeError) {
                        error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_DELETE_FILE_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DELETE_FILE_ERROR", nil)}];
                    }
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(deleteItemFinished:))) {
                        [self.delegate deleteItemFinished:error];
                    }
                }
            }];
            return YES;
        }
        return NO;
    }
    
- (BOOL) addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder {
    if (self.dbClient.isAuthorized) {
        WeakObj(self);
        folderName = [@"/" stringByAppendingPathComponent:folderName];
        [[self.dbClient.filesRoutes createFolder:[parentFolder.fullPath stringByAppendingPathComponent:folderName]] setResponseBlock:^(DBFILESFolderMetadata * _Nullable result, DBFILESCreateFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
            StrongObj(self);
            if (self) {
                NSError *error = nil;
                if (routeError || networkError) {
                    error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_ADD_FOLDER_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_ADD_FOLDER_ERROR", nil)}];
                }
                NXFileBase *newFolder = [self fetchFileInfo:result];
                
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(addFolderFinished:error:))) {
                    [self.delegate addFolderFinished:newFolder error:error];
                }
            }
        }];
        return YES;
    }
    return NO;
}
    
-(BOOL) cancelGetFiles:(NXFileBase*)folder
{
    if (self.dbClient.isAuthorized){
        [self.currentTask cancel];
        NSError *error = [NSError errorWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_CANCEL userInfo:nil];
        if (DELEGATE_HAS_METHOD(_delegate, @selector(getFilesFinished:error:))) {
            [_delegate getFilesFinished:nil error:error];
        }
        
        if (DELEGATE_HAS_METHOD(_delegate, @selector(serviceOpt:getFilesFinished:error:))) {
            [_delegate serviceOpt:self getFilesFinished:nil error:error];
        }
        return YES;
    }
    return NO;
}


- (BOOL)downloadFile:(NXFileBase *)file size:(NSUInteger)size {
    if (!self.dbClient.isAuthorized) {
        return NO;
    }
    
    WeakObj(self);
    DBDownloadDataResponseBlock responseBlock = ^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSData * _Nullable fileData) {
        StrongObj(self);
        if (self) {
            NSError *error = nil;
            if (routeError || networkError) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_DOWNLOAD_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DOWNLOAD_FILE_ERROR", nil)}];
            }
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
                [self.delegate downloadFileFinished:file fileData:fileData error:error];
            }
        }
    };
    DBProgressBlock progressBlock = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        StrongObj(self);
        if (self) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileProgress:forFile:))) {
                CGFloat totalBytesWrittenF = totalBytesWritten;
                CGFloat totalBytesExpectedToWriteF = totalBytesExpectedToWrite;
                CGFloat progress = totalBytesWrittenF/totalBytesExpectedToWriteF;
                [self.delegate downloadFileProgress:progress forFile:file.name];
            }
        }
    };
    
    if (size > 0) {
        [[[self.dbClient.filesRoutes downloadData:file.fullServicePath byteOffsetStart:@(0) byteOffsetEnd:@(size)] setResponseBlock:responseBlock] setProgressBlock:progressBlock];
    } else {
        [[[self.dbClient.filesRoutes downloadData:file.fullServicePath] setResponseBlock:responseBlock] setProgressBlock:progressBlock];
    }
    return YES;
}

- (BOOL)cancelDownloadFile:(NXFileBase *)file {
    [self.currentTask cancel];
    return YES;
}
    
-(BOOL)getMetaData:(NXFileBase *)file
    {
        if (self.dbClient.isAuthorized) {
            WeakObj(self);
            self.currentTask = [[self.dbClient.filesRoutes getMetadata:file.fullServicePath] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESGetMetadataError * _Nullable routeError, DBRequestError * _Nullable networkError) {
                StrongObj(self);
                if (self) {
                    NSError *error = nil;
                    if (routeError || networkError) {
                        error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_META_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_FILE_META_ERROR", nil)}];
                    }
                    NXFileBase *fileMetaData = [self fetchFileInfo:result];
                    if(DELEGATE_HAS_METHOD(self.delegate, @selector(getMetaDataFinished:error:))){
                        [self.delegate getMetaDataFinished:fileMetaData error:error];
                    }
                }
            }];
        } else {
            return NO;
        }
        return YES;
    }
    
- (BOOL)cancelGetMetaData:(NXFileBase *)file {
    [self.currentTask cancel];
    if ( DELEGATE_HAS_METHOD(_delegate,@selector(getMetaData:))) {
        NSError *error = [NSError errorWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_CANCEL userInfo:nil];
        [_delegate getMetaDataFinished:file error:error];
    }
    return YES;
}
    
- (BOOL) isProgressSupported {
    return YES;
}
    
- (BOOL) uploadFile:(NSString *)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile {
    
    if (self.dbClient.isAuthorized) {
        _curFolder = (NXFolder*)folder;
        DBFILESWriteMode *mode = nil;
        NSData *data = [NSData dataWithContentsOfFile:srcPath];
        if (type == NXUploadTypeOverWrite) {
            mode = [[DBFILESWriteMode alloc] initWithOverwrite];
        } else {
            mode = [[DBFILESWriteMode alloc] initWithAdd];
        }
        WeakObj(self);
        filename = [@"/" stringByAppendingPathComponent:filename];
       self.currentTask = [[[self.dbClient.filesRoutes uploadData:[folder.fullPath stringByAppendingPathComponent:filename] mode:mode autorename:@(YES) clientModified:nil mute:@(NO) inputData:data] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
           StrongObj(self);
           if (self) {
               NSError *error = nil;
               if (routeError || networkError) {
                   error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_UPLOAD_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPLOAD_FILE_ERROR", nil)}];
                   if ([networkError.nsError localizedDescription]) {
                       error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR userInfo:@{NSLocalizedDescriptionKey:[[networkError nsError]localizedDescription]?:@"Failed"}];
                   }
                   if ([networkError.statusCode longLongValue] == 409) {
                       error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_STORAGE_DOMAIN code:NXRMC_ERROR_CODE_REPO_STORAGE_MANAGER_EXCEEDED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DRIVE_STORAGE_EXCEEDED", NULL)}];
                   }
               }
               if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromPath:error:))) {
                   [self.delegate uploadFileFinished:filename fromPath:srcPath error:error];
               }
               if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                   NXFileBase *newFile = [self fetchFileInfo:result];
                   [self.delegate uploadFileFinished:newFile fromLocalPath:srcPath error:error];
               }
           }
          
        }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            StrongObj(self);
            if (self) {
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileProgress:forFile:fromPath:))) {
                    CGFloat totalBytesWrittenF = totalBytesWritten;
                    CGFloat totalBytesExpectedToWriteF = totalBytesExpectedToWrite;
                    CGFloat uploadProgress = totalBytesWrittenF/totalBytesExpectedToWriteF;
                    [self.delegate uploadFileProgress:uploadProgress forFile:filename fromPath:srcPath];
                }
            }
        }];
    }
    else
    {
        return NO;
    }
    return YES;
}
    
-(BOOL) cancelUploadFile:(NSString *)filename toPath:(NXFileBase *)folder
{
    [self.currentTask cancel];
    return YES;
}
    
-(BOOL) getUserInfo
{
    if(self.dbClient.isAuthorized)
    {
        WeakObj(self);
       self.currentTask = [[self.dbClient.usersRoutes getCurrentAccount] setResponseBlock:^(DBUSERSFullAccount * _Nullable result, DBNilObject * _Nullable routeError, DBRequestError * _Nullable networkError) {
           StrongObj(self);
           if (self) {
               if (result) {
                   NSString *userEmail = result.email;
                   NSString *userName = result.name.displayName;
                   [[self.dbClient.usersRoutes getSpaceUsage] setResponseBlock:^(DBUSERSSpaceUsage * _Nullable result, DBNilObject * _Nullable routeError, DBRequestError * _Nullable networkError) {
                       if (self) {
                           NSError *error = nil;
                           if (routeError || networkError) {
                               error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_USER_INFO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_USER_INFO_ERROR", nil)}];
                           }
                           if (result) {
                               if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                                   [self.delegate getUserInfoFinished:userName userEmail:userEmail totalQuota:result.allocation.isIndividual? result.allocation.individual.allocated:result.allocation.team.allocated usedQuota:result.used error:error];
                               }
                           }else{
                               if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                                   [self.delegate getUserInfoFinished:userName userEmail:userEmail totalQuota:nil usedQuota:nil error:error];
                               }
                           }
                       }
                   }];
               }else{
                   if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                       NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_USER_INFO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_USER_INFO_ERROR", nil)}];
                       [self.delegate getUserInfoFinished:nil userEmail:nil totalQuota:nil usedQuota:nil error:error];
                   }
               }
           }
        }];
    }else
    {
        return NO;
    }
    return YES;
}
    
-(BOOL) cancelGetUserInfo
{
    [self.currentTask cancel];
    return YES;
}

#pragma mark - Private method
- (void)listFolder:(NXFileBase *)parentFolder completeWithError:(NSError *)error
{
    NSMutableArray *resultFileList = [[NSMutableArray alloc] init];
    for (DBFILESMetadata *item in self.fileListResult) {
        NXFileBase *fileItem = [self fetchFileInfo:item];
        [resultFileList addObject:fileItem];
    }
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(getFilesFinished:error:))) {
        [self.delegate getFilesFinished:resultFileList error:error];
    }
}

- (NXFileBase *)fetchFileInfo:(DBFILESMetadata *) metaData
{
    NXFileBase *fileItem = nil;
    if ([metaData isKindOfClass:[DBFILESFileMetadata class]]) {
        fileItem = [[NXFile alloc] init];
        fileItem.fullServicePath = ((DBFILESFileMetadata *)metaData).id_;
        fileItem.fullPath = ((DBFILESFileMetadata *)metaData).pathDisplay;
        fileItem.size = ((DBFILESFileMetadata *)metaData).size.longLongValue;
        fileItem.name = ((DBFILESFileMetadata *)metaData).name;
        fileItem.lastModifiedDate = ((DBFILESFileMetadata *)metaData).clientModified;
        NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:fileItem.lastModifiedDate
                                                                        dateStyle:NSDateFormatterShortStyle
                                                                        timeStyle:NSDateFormatterFullStyle];
        fileItem.lastModifiedTime = lastModifydateString;
        fileItem.serviceAlias = [self getServiceAlias];
        fileItem.serviceType = [NSNumber numberWithInteger:kServiceDropbox];
        
    }else if([metaData isKindOfClass:[DBFILESFolderMetadata class]]){
        fileItem = [[NXFolder alloc] init];
        fileItem.name = ((DBFILESFolderMetadata*)metaData).name;
        fileItem.fullPath = ((DBFILESFolderMetadata*)metaData).pathDisplay;
        fileItem.fullServicePath = ((DBFILESFolderMetadata*)metaData).id_;
        fileItem.serviceAlias = [self getServiceAlias];
        fileItem.serviceType = [NSNumber numberWithInteger:kServiceDropbox];
    }
    fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
    return fileItem;
}


@end
