//
//  NXDropBox.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

//
//  NXDropBox.m
//  DropbBoxV2Test
//
//  Created by Eren (Teng) Shi on 5/18/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXDropBox.h"
#import "ObjectiveDropboxOfficial.h"
#import "NXFile.h"
#import "NXFolder.h"
#import "NXRMCDef.h"
#import "NXCacheManager.h"
#import "NXDropboxGetSpaceUsageAPI.h"
#import "NXDropboxGetCurrentAccountAPI.h"
#import "NXDropboxFileListAPI.h"
#import "NXDropboxDownloadFileAPI.h"
#import "NXDropboxUploadFileAPI.h"

#define Dropbox_ACCESSTOKEN_KEYWORD @"Authorization"

@interface NXDropBox()

@property(nonatomic, strong) NXFolder *curFolder;
@property(nonatomic, strong) NSMutableArray<NXDropboxFileItem *> *DBFileListResult;
@property(nonatomic, strong) NSString *repoAlias;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSMutableDictionary *getUserInfoRequestDic;
@property(nonatomic, strong) NSMutableDictionary *getFilesRequestDic;
@property(nonatomic, strong) NSMutableDictionary *downloadRequestDic;
@property(nonatomic, strong) NSMutableDictionary *uploadRequestDic;
@property(nonatomic, strong) NSProgress *downloadProgross;
@property(nonatomic, strong) NXFileBase *currentDownloadFile;
@property(nonatomic, strong) NXRepositoryModel *repoModel;
@end
@implementation  NXDropBox
- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel{
    if (self = [super init]) {
        _DBFileListResult = [[NSMutableArray alloc] init];
        _getUserInfoRequestDic = [[NSMutableDictionary alloc] init];
        _getFilesRequestDic = [[NSMutableDictionary alloc] init];
        _downloadRequestDic = [[NSMutableDictionary alloc] init];
        _uploadRequestDic = [[NSMutableDictionary alloc] init];
        _downloadProgross = [[NSProgress alloc] init];
        [_downloadProgross addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];
        _userId = userId;
        _repoModel = repoModel;
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
    _curFolder = (NXFolder *)folder;
    WeakObj(self);
    
    if (self.getFilesRequestDic.allValues.count >0) {
        for (NXDropboxFileListAPIRequest *req in self.getFilesRequestDic.allValues) {
            [req cancelRequest];
        }
        [self.getFilesRequestDic removeAllObjects];
    }
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    NXDropboxFileListAPIRequest *request = [[NXDropboxFileListAPIRequest alloc] initWithRepo:_repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
    
    [self.DBFileListResult removeAllObjects];
    [self.getFilesRequestDic setObject:request forKey:optIdentify];
    [request requestWithObject:_curFolder.fullServicePath Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXDropboxFileListAPIResponse *resp = (NXDropboxFileListAPIResponse *)response;
            
            NSString *cursor = resp.cursor;
            BOOL hasMore = [resp.hasMore boolValue];
            
            [self.DBFileListResult addObjectsFromArray:resp.files.copy];
            if (hasMore) {
                [self listFolderContinueWithCursor:cursor];
            } else {
                [self listFolder:folder completeWithError:nil];
            }
        }
        else
        {
            NSError *aerror = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]?:NSLocalizedString(@"MSG_GET_FILE_LIST_ERROR", nil)}];
            [self listFolder:folder completeWithError:aerror];
            return ;
        }
    }];
    
    return YES;
}

- (void)listFolderContinueWithCursor:(NSString *)cursor {
    WeakObj(self);
    NXDropboxFileListAPIRequest *request = [[NXDropboxFileListAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
    request.cursor = cursor;
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    [self.getFilesRequestDic setObject:request forKey:optIdentify];
    [request requestWithObject:_curFolder.fullServicePath Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXDropboxFileListAPIResponse *resp = (NXDropboxFileListAPIResponse *)response;
            NSString *cursor = resp.cursor;
            BOOL hasMore = [resp.hasMore boolValue];
            [self.DBFileListResult addObjectsFromArray:resp.files.copy];
            if (hasMore) {
                [self listFolderContinueWithCursor:cursor];
            } else {
                [self listFolder:self.curFolder completeWithError:nil];
            }
        }
        else
        {
            NSError *aerror = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_FILE_LIST_ERROR userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription?error.localizedDescription:NSLocalizedString(@"MSG_GET_FILE_LIST_ERROR", nil)}];
            [self listFolder:self.curFolder completeWithError:aerror];
            return ;
        }
    }];
}

-(BOOL) deleteFileItem:(NXFileBase*)file
{
    return NO;
}

- (BOOL) addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder {
    return NO;
}

-(BOOL) cancelGetFiles:(NXFileBase*)folder
{
    if (self.getFilesRequestDic.count > 0) {
        for (NXSuperRESTAPIRequest *request in _getFilesRequestDic.allValues) {
            [request cancelRequest];}
        [self.getFilesRequestDic removeAllObjects];
        
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
    if (self.downloadRequestDic.allValues.count >0) {
        for (NXDropboxDownloadFileAPIRequest *req in self.downloadRequestDic.allValues) {
            [req cancelRequest];
        }
        [self.downloadRequestDic removeAllObjects];
    }
    
    _currentDownloadFile = file;
    NXDropboxDownloadFileAPIRequest *downloadRequest = [[NXDropboxDownloadFileAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    [self.downloadRequestDic setObject:downloadRequest forKey:optIdentify];
    [downloadRequest requestWithObject:file.fullServicePath withUploadProgress:nil downloadProgress:_downloadProgross Completion:^(NXSuperRESTAPIResponse *response, NSError *error){
        NXDropboxDownloadFileAPIResponse *resp = (NXDropboxDownloadFileAPIResponse *)response;
         NSError *aError = nil;
        if (error) {
            aError = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_DOWNLOAD_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DOWNLOAD_FILE_ERROR", nil)}];
        }
        
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
            [self.delegate downloadFileFinished:file fileData:resp.fileData error:aError];
        }
    }];
    return YES;
}

- (BOOL)cancelDownloadFile:(NXFileBase *)file {
    if (self.downloadRequestDic.count > 0) {
        for (NXSuperRESTAPIRequest *request in _downloadRequestDic.allValues) {
            [request cancelRequest];}
        [self.downloadRequestDic removeAllObjects];
        return YES;
    }
    return NO;
}

-(BOOL)getMetaData:(NXFileBase *)file
{
    return YES;
}

- (BOOL)cancelGetMetaData:(NXFileBase *)file {
    return YES;
}

- (BOOL) isProgressSupported {
    return YES;
}

- (BOOL) uploadFile:(NSString *)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile {
    if(!filename || !srcPath || !folder.fullPath)
       {
           return NO;
       }
     NSData *fileData = [[NSData alloc]initWithContentsOfFile:srcPath];
    if (folder.isRoot || [folder.fullPath isEqualToString:@""]) {
        folder.fullPath = @"/";
    }
    NSString *toPath = [folder.fullPath stringByAppendingPathComponent:filename];
    NSMutableDictionary *dict = @{@"path":toPath,@"fileData":fileData}.mutableCopy;
    if (fileData.length < 157286400) {
        // less than 150MB
        NXDropboxUploadFileAPIRequest *request = [[NXDropboxUploadFileAPIRequest alloc] initWithRepo:_repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
        NSString *optIdentify = [[NSUUID UUID] UUIDString];
        [self.uploadRequestDic setValue:request forKey:optIdentify];
              [request requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                  [self.uploadRequestDic removeObjectForKey:optIdentify];
                  if (!error) {
                      NXDropboxUploadFileAPIResponse *apiResponse = (NXDropboxUploadFileAPIResponse *)response;
                      NXDropboxFileItem *fileItem = apiResponse.fileItem;
                      NXFileBase *file = [[NXFileBase alloc] init];
                      file.name = fileItem.name;
                      file.size = [fileItem.size longLongValue];
                      file.fullServicePath = fileItem.pathDisplay;
                      file.fullPath = fileItem.pathDisplay;
                      if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                          [self.delegate uploadFileFinished:file fromLocalPath:srcPath error:nil];
                      }
                
                  }else{
                      if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                                               [self.delegate uploadFileFinished:nil fromLocalPath:srcPath error:error];
                      }
                      
                  }
              }];
        
    }else{
        NXDropboxUploadFileStartAPIRequest *startRequest = [[NXDropboxUploadFileStartAPIRequest alloc] initWithRepo:_repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
        NSString *optIdentify1 = [[NSUUID UUID] UUIDString];
        [self.uploadRequestDic setObject:startRequest forKey:optIdentify1];
        [startRequest requestWithObject:filename Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            [self.uploadRequestDic removeObjectForKey:optIdentify1];
            if (error) {
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                                                              [self.delegate uploadFileFinished:nil fromLocalPath:srcPath error:error];
                }
                
            }else{
                NXDropboxUploadFileStartAPIResponse *startResponse = (NXDropboxUploadFileStartAPIResponse *)response;
                NSString *session_id = startResponse.session_id;
                [dict setValue:session_id forKey:@"session_id"];
                NXDropboxUploadFileAppendAPIRequest *appendRequest = [[NXDropboxUploadFileAppendAPIRequest alloc] initWithRepo:_repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
                 NSString *optIdentify2 = [[NSUUID UUID] UUIDString];
                [self.uploadRequestDic setObject:appendRequest forKey:optIdentify2];
                [appendRequest requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                    [self.uploadRequestDic removeObjectForKey:optIdentify2];
                    NXDropboxUploadFileFinishAPIRequest *finishRequest = [[NXDropboxUploadFileFinishAPIRequest alloc] initWithRepo:_repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
                     NSString *optIdentify3 = [[NSUUID UUID] UUIDString];
                    [self.uploadRequestDic setObject:finishRequest forKey:optIdentify3];
                    [finishRequest requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                        [self.uploadRequestDic removeObjectForKey:optIdentify3];
                        if (!error) {
                              NXDropboxUploadFileAPIResponse *apiResponse = (NXDropboxUploadFileAPIResponse *)response;
                              NXDropboxFileItem *fileItem = apiResponse.fileItem;
                              NXFileBase *file = [[NXFileBase alloc] init];
                              file.name = fileItem.name;
                              file.size = [fileItem.size longLongValue];
                              file.fullServicePath = fileItem.pathDisplay;
                              file.fullPath = fileItem.pathDisplay;
                              if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                                  [self.delegate uploadFileFinished:file fromLocalPath:srcPath error:nil];
                              }
                        
                          }else{
                              if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
                                                       [self.delegate uploadFileFinished:nil fromLocalPath:srcPath error:error];
                              }
                              
                          }
                    }];
                    
                }];
            }
        }];
        
        
    }
   
    
    return YES;
}

-(BOOL) cancelUploadFile:(NSString *)filename toPath:(NXFileBase *)folder
{
    if (self.uploadRequestDic.count > 0) {
        for (NXSuperRESTAPIRequest *request in _uploadRequestDic.allValues) {
            [request cancelRequest];}
      [self.uploadRequestDic removeAllObjects];
    }
   
    return YES;
}

-(BOOL) getUserInfo
{
    [self.getUserInfoRequestDic removeAllObjects];
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    NXDropboxGetCurrentAccountAPIRequest *getAccountRequest = [[NXDropboxGetCurrentAccountAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
    [self.getUserInfoRequestDic setObject:getAccountRequest forKey:optIdentify];
    WeakObj(self);
    [getAccountRequest requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        NXDropboxGetCurrentAccountAPIResponse *rsp = (NXDropboxGetCurrentAccountAPIResponse *)response;
        if (error == nil) {
            NSString *userEmail = rsp.userEmail;
            NSString *userName = rsp.userDisplayName;
            
            NXDropboxGetSpaceUsageAPIRequest *getspaceRq = [[NXDropboxGetSpaceUsageAPIRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:Dropbox_ACCESSTOKEN_KEYWORD];
             NSString *optIdentify = [[NSUUID UUID] UUIDString];
             [self.getUserInfoRequestDic setObject:getspaceRq forKey:optIdentify];
            [getspaceRq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                
                NXDropboxGetSpaceUsageAPIResponse *resp = (NXDropboxGetSpaceUsageAPIResponse *)response;
                if (error) {
                    error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_USER_INFO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_USER_INFO_ERROR", nil)}];
                }
                if (response && !error) {
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                        [self.delegate getUserInfoFinished:userName userEmail:userEmail totalQuota:resp.allocated usedQuota:resp.used error:error];
                    }
                }else{
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                        [self.delegate getUserInfoFinished:userName userEmail:userEmail totalQuota:nil usedQuota:nil error:error];
                    }
                }
            }];
        }
        else{
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_USER_INFO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_USER_INFO_ERROR", nil)}];
                [self.delegate getUserInfoFinished:nil userEmail:nil totalQuota:nil usedQuota:nil error:error];
            }
        }
    }];
    return YES;
}

-(BOOL) cancelGetUserInfo
{
    if (self.getUserInfoRequestDic.count > 0) {
        for (NXSuperRESTAPIRequest *request in _getUserInfoRequestDic.allValues) {
            [request cancelRequest];}
      [self.getUserInfoRequestDic removeAllObjects];
    }
    return YES;
}

- (void)dealloc
{
   [_downloadProgross removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

#pragma mark - Private method
- (void)listFolder:(NXFileBase *)parentFolder completeWithError:(NSError *)error
{
    NSMutableArray *resultFileList = [[NSMutableArray alloc] init];
    for (NXDropboxFileItem *item in self.DBFileListResult) {
        NXFileBase *fileItem = [self fetchFileInfo:item];
        [resultFileList addObject:fileItem];
    }
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(getFilesFinished:error:))) {
        [self.delegate getFilesFinished:resultFileList error:error];
    }
}

- (NXFileBase *)fetchFileInfo:(NXDropboxFileItem *) metaData
{
    NXFileBase *fileItem = nil;
    if ([metaData.tag isEqualToString:@"file"]) {
        fileItem = [[NXFile alloc] init];
        fileItem.fullServicePath = metaData.id_;
        fileItem.fullPath = metaData.pathDisplay;
        fileItem.size = metaData.size.longLongValue;
        fileItem.name = metaData.name;
        fileItem.lastModifiedDate = metaData.clientModified;
        NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:fileItem.lastModifiedDate
                                                                        dateStyle:NSDateFormatterShortStyle
                                                                        timeStyle:NSDateFormatterFullStyle];
        fileItem.lastModifiedTime = lastModifydateString;
        fileItem.serviceAlias = [self getServiceAlias];
        fileItem.serviceType = [NSNumber numberWithInteger:kServiceDropbox];
        
    }else{
        fileItem = [[NXFolder alloc] init];
        fileItem.name = ((NXDropboxFileItem*)metaData).name;
        fileItem.fullPath = ((NXDropboxFileItem*)metaData).pathDisplay;
        fileItem.fullServicePath = ((NXDropboxFileItem*)metaData).id_;
        fileItem.serviceAlias = [self getServiceAlias];
        fileItem.serviceType = [NSNumber numberWithInteger:kServiceDropbox];
        fileItem.lastModifiedDate = metaData.clientModified;
        NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:fileItem.lastModifiedDate
                                                                               dateStyle:NSDateFormatterShortStyle
                                                                               timeStyle:NSDateFormatterFullStyle];
        fileItem.lastModifiedTime = lastModifydateString;
        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
    }
    return fileItem;
}

#pragma -mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))] && [object isEqual:self.downloadProgross]) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileProgress:forFile:))) {
                [self.delegate downloadFileProgress:self.downloadProgross.fractionCompleted forFile:_currentDownloadFile.name];
                
                 NSLog(@" dropbox downloadprogress is : %f",self.downloadProgross.fractionCompleted);
            }
        }
    });
}
@end

