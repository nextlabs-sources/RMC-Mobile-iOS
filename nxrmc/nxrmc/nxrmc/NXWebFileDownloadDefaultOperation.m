//
//  NXWebFileDownloadDefaultOperation.m
//  nxrmc
//
//  Created by 时滕 on 2019/12/5.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWebFileDownloadDefaultOperation.h"
#import "NXRMCDef.h"
@implementation NXWebFileDownloadDefaultOperation
#pragma -mark OVERRIDE METHOD

- (void)executeTask:(NSError **)error
{
    NSError * restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DOWNLOAD_FILE_ERROR", nil)}];
    [self finish:restError];
}

- (void)workFinished:(NSError *)error
{
    if (self.webFileDownloadCompletion) {
        self.webFileDownloadCompletion(self.file, nil, error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    if (self.webFileDownloadCompletion) {
        self.webFileDownloadCompletion(self.file, nil, cancelError);
    }
}

#pragma mark - NXWebFileDownloadOperation
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion
{
    self.file = file;
    self.downloadProgress = progress;
    self.webFileDownloadCompletion = completion;
}
- (void)cancelDownload
{
    [self cancel];
}
@end
