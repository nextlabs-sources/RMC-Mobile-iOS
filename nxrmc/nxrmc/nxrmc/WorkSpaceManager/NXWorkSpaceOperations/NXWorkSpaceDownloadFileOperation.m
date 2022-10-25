//
//  NXWorkSpaceDownloadFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceDownloadFileOperation.h"
#import "NXWorkSpaceDownloadFileAPI.h"
#import "NXWebFileDownloadOperation.h"
#import "NXWorkSpaceItem.h"
#import "NXCacheManager.h"
@interface NXWorkSpaceDownloadFileOperation ()
@property(nonatomic, strong) NSData *fileData;
@property(nonatomic, weak) NXWorkSpaceDownloadFileRequest *downloadRequest;
@property(nonatomic, copy) NXWebFileDownloadOperationCompletionBlock webFileDownloadCompletion;
@end
@implementation NXWorkSpaceDownloadFileOperation
- (instancetype)initWithWorkSpaceFile:(NXWorkSpaceFile *)file start:(NSUInteger)start length:(NSUInteger)length downloadType:(NSInteger)downloadType {
    self = [super init];
    if (self) {
        _fileData = [[NSData alloc] init];
        _file = file;
        _startIndex = start;
        _length = length;
        _downloadType = [NSNumber numberWithInteger:downloadType];
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error{
    NXWorkSpaceDownloadFileRequest *request = [[NXWorkSpaceDownloadFileRequest alloc]init];
    self.downloadRequest = request;
    NSDictionary *paraDic = @{FILE_PATH:_file.fullServicePath,START:[NSNumber numberWithUnsignedInteger:_startIndex],LENGTH:[NSNumber numberWithUnsignedInteger:_length], DOWNLOAD_TYPE:_downloadType};
    [request requestWithObject:paraDic withUploadProgress:nil downloadProgress:self.downloadProgress Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error){
           NXWorkSpaceDownloadFileResponse *returnResponse = (NXWorkSpaceDownloadFileResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _fileData = returnResponse.resultData;
    
            }else {
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:returnResponse.rmsStatuMessage? :NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
            }
        }
        if (error.code == 403) {
            error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error
{
    if (self.webFileDownloadCompletion) {
        self.webFileDownloadCompletion(self.file, _fileData, error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.downloadRequest cancelRequest];
}

#pragma mark - NXWebFileDownloadOperation
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion
{
    self.file =  (NXWorkSpaceFile *)file;
    self.downloadProgress = progress;
    self.webFileDownloadCompletion = completion;
}
- (void)cancelDownload
{
    [self cancel];
}
@end
