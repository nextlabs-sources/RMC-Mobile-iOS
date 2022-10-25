//
//  NXSharedWithProjectFileDownloadOperation.m
//  nxrmc
//
//  Created by 时滕 on 2020/1/10.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFileDownloadOperation.h"
#import "NXSharedWithProjectFileDownloadAPI.h"
#import "NXLoginUser.h"
#import "NXRMCDef.h"
#import "NXCacheManager.h"

@interface NXSharedWithProjectFileDownloadOperation ()

@property(nonatomic, strong) NSData *fileData;
@property(nonatomic, weak) NXSharedWithProjectFileDownloadRequest *downloadRequest;
@property(nonatomic, copy) NXWebFileDownloadOperationCompletionBlock webFileDownloadCompletion;
@property(nonatomic, assign) NSUInteger downloadSize;
@end

@implementation NXSharedWithProjectFileDownloadOperation

#pragma -mark INIT METHOD

-(instancetype)initWithSharedWithProjectFile:(NXSharedWithProjectFile *)file size:(NSUInteger)size forViewer:(BOOL)forViewer;
{
    
    self = [super init];
    if (self) {
        _fileData = [[NSData alloc] init];
        _downloadSize = size;
        _file = file;
        _forViewer = forViewer;
    }
    return self;
    
}

#pragma -mark OVERRIDE METHOD

- (void)executeTask:(NSError **)error
{
    NXSharedWithProjectFileDownloadRequest *request = [[NXSharedWithProjectFileDownloadRequest alloc] initWithDownloadSize:self.downloadSize isForView:self.forViewer];
    self.downloadRequest = request;
    if (_forViewer) {
        request.forViewer = true;
    }
    else
    {
        request.forViewer = false;
    }
    
    WeakObj(self);
//    NSDictionary *paraDic = @{@"transactionCode":self.file.transactionCode,@"transactionId":self.file.transactionId};
    [request requestWithObject:self.file withUploadProgress:nil downloadProgress:self.downloadProgress Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
         NXSharedWithProjectFileDownloadResponse *returnResponse = (NXSharedWithProjectFileDownloadResponse *) response;
        if (!error){
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _fileData = returnResponse.fileData;
                self.file.name = returnResponse.file.name;
                self.file.size = returnResponse.file.size;
                self.file.lastModifiedDate = returnResponse.file.lastModifiedDate;
                
                [self finish:nil];
            }
            else
            {
                if (returnResponse.rmsStatuCode == 4001) {
                    NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_SHAREDFILE_REVOKED_OR_DELETED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                    [self finish:restError];
                }else{
                    NSError * restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DOWNLOAD_FILE_ERROR", nil)}];
                    [self finish:restError];
                }
            }
        }
        else
        {
            if (error.code == 403) { // means this file may delete or revoked by the owner
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_SHAREDFILE_REVOKED_OR_DELETED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                [self finish:restError];
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DOWNLOAD_FILE_ERROR", nil)}];
                [self finish:error];
            }
        }
    }];
}

- (void)workFinished:(NSError *)error
{
    if (self.sharedWithProjectDownloadFileCompletion)
    {
        NSURL *tempFileUrl = [NXCacheManager getProjectCachedFilePathWithFileName:_file.name];
        [_fileData writeToURL:tempFileUrl atomically:YES];
        _file.localPath = tempFileUrl.path;
        self.sharedWithProjectDownloadFileCompletion(self.file,error);
    }
    
    if (self.webFileDownloadCompletion) {
        self.webFileDownloadCompletion(self.file, _fileData, error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.downloadRequest cancelRequest];
    if (self.sharedWithProjectDownloadFileCompletion)
    {
        self.sharedWithProjectDownloadFileCompletion(nil,cancelError);
    }
}

#pragma mark - NXWebFileDownloadOperation
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion
{
    self.file = (NXSharedWithProjectFile *)file;
    self.downloadProgress = progress;
    self.webFileDownloadCompletion = completion;
}
- (void)cancelDownload
{
    [self cancel];
}

@end
