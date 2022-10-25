//
//  NXSharedWithMeDownloadFileOperation.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 12/06/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSharedWithMeDownloadFileOperation.h"
#import "NXSharedWithMeDownloadFileAPI.h"
#import "NXLoginUser.h"
#import "NXRMCDef.h"
#import "NXCacheManager.h"

@interface NXSharedWithMeDownloadFileOperation ()

@property(nonatomic, strong) NSData *fileData;
@property(nonatomic, weak) NXSharedWithMeDownloadFileAPIRequest *downloadRequest;
@property(nonatomic, copy) NXWebFileDownloadOperationCompletionBlock webFileDownloadCompletion;
@property(nonatomic, assign) NSUInteger downloadSize;
@end

@implementation NXSharedWithMeDownloadFileOperation

#pragma -mark INIT METHOD

-(instancetype)initWithSharedWithMeFile:(NXSharedWithMeFile *)file size:(NSUInteger)size forViewer:(BOOL)forViewer;
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
    NXSharedWithMeDownloadFileAPIRequest *request = [[NXSharedWithMeDownloadFileAPIRequest alloc] initWithDownloadSize:self.downloadSize isForView:self.forViewer];
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
         NXSharedWithMeDownloadFileAPIResponse *returnResponse = (NXSharedWithMeDownloadFileAPIResponse *) response;
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
                [self finish:error];
            }
        }
    }];
}

- (void)workFinished:(NSError *)error
{
    if (self.sharedWithMeDownloadFileCompletion)
    {
        NSURL *tempFileUrl = [NXCacheManager getProjectCachedFilePathWithFileName:_file.name];
        [_fileData writeToURL:tempFileUrl atomically:YES];
        _file.localPath = tempFileUrl.path;
        self.sharedWithMeDownloadFileCompletion(self.file,error);
    }
    
    if (self.webFileDownloadCompletion) {
        self.webFileDownloadCompletion(self.file, _fileData, error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.downloadRequest cancelRequest];
    if (self.sharedWithMeDownloadFileCompletion)
    {
        self.sharedWithMeDownloadFileCompletion(nil,cancelError);
    }
}

#pragma mark - NXWebFileDownloadOperation
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion
{
    self.file = (NXSharedWithMeFile *)file;
    self.downloadProgress = progress;
    self.webFileDownloadCompletion = completion;
}
- (void)cancelDownload
{
    [self cancel];
}

@end

