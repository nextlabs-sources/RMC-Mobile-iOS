//
//  NXBox.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/11/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXBox.h"
#import "NXBoxGetFileListAPI.h"
#import "NXBoxDownloadFileAPI.h"
#import "NXBoxGetUserInfoAPI.h"
#import "NXBoxUploadFileAPI.h"

#define BOX_ACCESSTOKEN_KEYWORD @"Authorization"
@interface NXBox()
@property(nonatomic, strong) NXRepositoryModel *repoModel;
@property(nonatomic, strong) NXSuperRESTAPIRequest *curRequest;
@property(nonatomic, strong) NXFileBase *curFile;
@end
@implementation NXBox

- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel {
    if (self = [super init]) {
        _repoModel = repoModel;
    }
    return self;
}

#pragma mark - NXServiceOperation
-(BOOL) getFiles:(NXFileBase*)folder {
    self.curFile = folder;
    
    self.curRequest = [[NXBoxGetFileListRequest alloc] initWithRepo:_repoModel accessTokenKeyword:BOX_ACCESSTOKEN_KEYWORD];
    WeakObj(self);
    [self.curRequest requestWithObject:folder.fullServicePath Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (self) {
            if (error == nil) {
                NXBoxGetFileListResponse *getFileListResponse = (NXBoxGetFileListResponse *)response;
                [self fetchFileInfo:getFileListResponse.fileListArray];
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(getFilesFinished:error:))) {
                    [self.delegate getFilesFinished:getFileListResponse.fileListArray error:error];
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

-(BOOL) downloadFile:(NXFileBase*)file size:(NSUInteger)size {
    self.curFile = file;
    self.curRequest = [[NXBoxDownloadFileRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:BOX_ACCESSTOKEN_KEYWORD];
    [self.curRequest requestWithObject:file Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            NXBoxDownloadFileResponse *downloadResponse = (NXBoxDownloadFileResponse *)response;
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(downloadFileFinished:fileData:error:))) {
                [self.delegate downloadFileFinished:file fileData:downloadResponse.fileData error:nil];
            }
        }else {
            NSError *nxError = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_DOWNLOAD_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DOWNLOAD_FILE_ERROR", nil)}];;
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
    
    self.curRequest = [[NXBoxGetUserInfoRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:BOX_ACCESSTOKEN_KEYWORD];
    [self.curRequest requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            NXBoxGetUserInfoResponse *getUserInfoResponse = (NXBoxGetUserInfoResponse *)response;
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                [self.delegate getUserInfoFinished:getUserInfoResponse.name userEmail:getUserInfoResponse.login totalQuota:getUserInfoResponse.space_amount usedQuota:getUserInfoResponse.space_used error:error];
            }
        }else {
            error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_GET_USER_INFO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_USER_INFO_ERROR", nil)}];
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(getUserInfoFinished:userEmail:totalQuota:usedQuota:error:))) {
                [self.delegate getUserInfoFinished:nil userEmail:nil totalQuota:nil usedQuota:nil error:error];
            }
        }
    }];
    return YES;
}
-(BOOL) cancelGetUserInfo {
    return YES;
}

- (BOOL)uploadFile:(NSString *)filename toPath:(NXFileBase *)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType)type overWriteFile:(NXFileBase *)overWriteFile {
    self.curFile = folder;
    self.curRequest = [[NXBoxUploadFileRequest alloc] initWithRepo:self.repoModel accessTokenKeyword:BOX_ACCESSTOKEN_KEYWORD];
    NSDictionary *modelDict = @{
        BOX_UPLOAD_FILE_PATH_KEY : srcPath,
        BOX_UPLOAD_FILE_NAME_KEY : filename,
        BOX_UPLOAD_PARENT_FOLDER_KEY : folder,
    };
    WeakObj(self);
    [self.curRequest requestWithObject:modelDict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        NXBoxUploadFileResponse *uploadFileResponse = (NXBoxUploadFileResponse *)response;
        NXFile *file = nil;
        if (uploadFileResponse && uploadFileResponse.uploadedFile) {
            file = uploadFileResponse.uploadedFile;
            [self fetchFileInfo:@[file]];
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

-(void) setAlias:(NSString *) alias {
    
}
-(NSString *) getServiceAlias {
    return self.repoModel.service_alias;
}

#pragma mark - Private
- (void)fetchFileInfo:(NSArray *)fileList {
    for (NXFileBase *fileItem in fileList) {
        fileItem.parent = self.curFile;
        fileItem.fullPath = [self.curFile.fullPath stringByAppendingPathComponent:fileItem.name];
        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
    }
}
@end
