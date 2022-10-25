//
//  NXSharedWorkspace.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWorkspace.h"
#import "NXRepositoryModel.h"
#import "NXSuperRESTAPI.h"
#import "NXSharedWorkspaceDownloadAPI.h"
#import "NXSharedWorkspaceUploadAPI.h"
#import "NXSharedWorkspaceFilesListAPI.h"
#import "NXSharedWorkspaceGetFileMetaDataAPI.h"
@interface NXSharedWorkspace ()
@property(nonatomic, strong) NXRepositoryModel *repoModel;
@property(nonatomic, strong) NXSuperRESTAPIRequest *curRequest;
@property(nonatomic, strong) NXFileBase *curFile;
@end
#define ACCESSTOKEN_KEYWORD @"Authorization"
@implementation NXSharedWorkspace
- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel {
    if (self = [super init]) {
        _repoModel = repoModel;
    }
    return self;
}
-(void) setAlias:(NSString *) alias {
    
}
#pragma mark - NXServiceOperation
-(BOOL) getFiles:(NXFileBase*)folder {
    self.curFile = folder;
    self.curRequest = [[NXSharedWorkspaceFilesListAPIRequest alloc] initWithRepo:self.repoModel];
    WeakObj(self);
    [self.curRequest requestWithObject:folder.fullPath Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (self) {
            if (error == nil) {
                NXSharedWorkspaceFilesListAPIResponse *getFileListResponse = (NXSharedWorkspaceFilesListAPIResponse *)response;
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(getFilesFinished:error:))) {
                    [self.delegate getFilesFinished:getFileListResponse.filesArray error:error];
                }
            }else {
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(getFilesFinished:error:))) {
                    [self.delegate getFilesFinished:nil error:error];
                }
            }

        }
    }];
    return YES;
}
-(BOOL) cancelGetFiles:(NXFileBase*)folder {
    [self.curRequest cancelRequest];
    return YES;
}
- (BOOL)getMetaData:(NXFileBase *)file {
    self.curFile = file;
    self.curRequest = [[NXSharedWorkspaceGetFileMetaDataAPIRequest alloc] initWithRepo:self.repoModel];
    WeakObj(self);
    [self.curRequest requestWithObject:file Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXSharedWorkspaceGetFileMetaDataAPIResponse *metadataResponse = (NXSharedWorkspaceGetFileMetaDataAPIResponse *)response;
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(getMetaDataFinished:error:))) {
                [self.delegate getMetaDataFinished:metadataResponse.fileItem error:error];
            }
        }else{
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(getMetaDataFinished:error:))) {
                           [self.delegate getMetaDataFinished:nil error:error];
                       }
            
        }
    }];
    return YES;
}
- (BOOL)cancelGetMetaData:(NXFileBase *)file {
    [self.curRequest cancelRequest];
    return YES;
}

- (BOOL)downloadFile:(NXFileBase *)file size:(NSUInteger)size downloadType:(NSInteger)downloadType {
    self.curFile = file;
    BOOL ret = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:file];
    self.curRequest = [[NXSharedWorkspaceDownloadAPIRequest alloc] initWithRepo:self.repoModel];
    if (size == 0) {
        size = file.size;
    }
    if (!file.fullPath) {
        file.fullPath = file.fullServicePath;
    }
    NSDictionary *dict = @{@"start":@0,@"length":@(size),@"path":file.fullPath,@"type":@(downloadType),@"isnxl":@(ret)};
    WeakObj(self);
    [self.curRequest requestWithObject:dict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            StrongObj(self);
            NXSharedWorkspaceDownloadAPIResponse *downloadResponse = (NXSharedWorkspaceDownloadAPIResponse *)response;
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
                [self.delegate downloadFileFinished:file fileData:downloadResponse.resultData error:nil];
            }
        }else {
            NSError *nxError ;
            if (error.code == 403) {
                nxError = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
            }else{
                nxError = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_DOWNLOAD_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DOWNLOAD_FILE_ERROR", nil)}];;
            }
            
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
                [self.delegate downloadFileFinished:file fileData:nil error:nxError];
            }
        }
    }];
    return YES;
    
}
-(BOOL) cancelDownloadFile:(NXFileBase*)file {
    [self.curRequest cancelRequest];
    return YES;
}


-(BOOL) getUserInfo {
    
   
    return YES;
}
-(BOOL) cancelGetUserInfo {
    return YES;
}

- (BOOL)uploadFile:(NSString *)filename toPath:(NXFileBase *)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile {
    self.curFile = folder;
    NXFileBase *file = [[NXFileBase alloc] init];
    file.name = filename;
    file.localPath = srcPath;
    self.curRequest = [[NXSharedWorkspaceUploadAPIRequest alloc] initWithRepo:self.repoModel];
    NXSharedWorkspaceUploadFileModel *model = [[NXSharedWorkspaceUploadFileModel alloc] init];
    model.parentFolder = folder;
    model.file = file;
    if (type == NXUploadTypeOverWrite) {
        model.overwrite = YES;
    }else if(type == NXUploadTypeNormal){
        model.overwrite = NO;
    }
    model.uploadType = NXUploadTypeNXLFile;
       WeakObj(self);
       [self.curRequest requestWithObject:model Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
           StrongObj(self);
           NXSharedWorkspaceUploadAPIResponse *uploadFileResponse = (NXSharedWorkspaceUploadAPIResponse *)response;
           NXFile *file = nil;
           if (uploadFileResponse && uploadFileResponse.uploadedFile) {
               file = uploadFileResponse.uploadedFile;
           }
           if (uploadFileResponse.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
               error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_AUTHFAILED userInfo:@{NSLocalizedDescriptionKey:uploadFileResponse.rmsStatuMessage?:@""}];
           
           }
           if (DELEGATE_HAS_METHOD(self.delegate, @selector(uploadFileFinished:fromLocalPath:error:))) {
               [self.delegate uploadFileFinished:file fromLocalPath:srcPath error:error];
           }
       }];
   
    return YES;
}

- (BOOL)cancelUploadFile:(NSString *)filename toPath:(NXFileBase *)folder {
    [self.curRequest cancelRequest];
    return YES;
}

-(void) setDelegate: (id<NXServiceOperationDelegate>) delegate {
    _delegate = delegate;
}
-(BOOL) isProgressSupported {
    return NO;
}


-(NSString *) getServiceAlias {
    return self.repoModel.service_alias;
}

- (BOOL)downloadFile:(NXFileBase *)file size:(NSUInteger)size {
    return NO;
}



@end
