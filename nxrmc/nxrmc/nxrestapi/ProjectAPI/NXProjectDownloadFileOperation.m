//
//  NXProjectDownloadFileOperation.m
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectDownloadFileOperation.h"
#import "NXProjectDownloadFileAPI.h"
#import "NXLoginUser.h"
#import "NXRMCDef.h"
#import "NXCacheManager.h"

@interface NXProjectDownloadFileOperation ()

@property(nonatomic, strong) NSData *fileData;
@property(nonatomic, weak) NXProjectDownloadFileAPIRequest *downloadRequest;
@property(nonatomic, copy) NXWebFileDownloadOperationCompletionBlock webFileDownloadCompletion;
@end

@implementation NXProjectDownloadFileOperation

#pragma -mark INIT METHOD

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel file:(NXProjectFile *)file start:(NSUInteger)start length:(NSUInteger )length downloadType:(NSInteger )downloadType;
{
    if (projectModel == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        _fileData = [[NSData alloc] init];
        _prjectModel = projectModel;
        _file = file;
        _startIndex = start;
        _length = length;
        _downloadType = [NSNumber numberWithInteger:downloadType];
    }
    return self;

}

#pragma -mark OVERRIDE METHOD

- (void)executeTask:(NSError **)error
{
    NXProjectDownloadFileAPIRequest *request = [[NXProjectDownloadFileAPIRequest alloc]init];
    self.downloadRequest = request;
    WeakObj(self);
    NSDictionary *paraDic = @{PROJECT_ID:_prjectModel.projectId,FILE_PATH:_file.fullServicePath,START:[NSNumber numberWithUnsignedInteger:_startIndex],LENGTH:[NSNumber numberWithUnsignedInteger:_length], DOWNLOAD_TYPE:_downloadType};
    [request requestWithObject:paraDic withUploadProgress:nil downloadProgress:self.downloadProgress Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
            NXProjectDownloadFileAPIResponse *returnResponse = (NXProjectDownloadFileAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _fileData = returnResponse.resultData;
                [self finish:nil];
            }
            else
            {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey : returnResponse.rmsStatuMessage}];
                [self finish:restError];
            }
        }
        else
        {
            if (error.code == 403 || error.code == 400) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
            }
            [self finish:error];
        }
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
    if (self.webFileDownloadCompletion) {
        self.webFileDownloadCompletion(self.file, nil, cancelError);
    }
}

#pragma mark - NXWebFileDownloadOperation
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion
{
    self.file = (NXProjectFile *)file;
    self.downloadProgress = progress;
    self.webFileDownloadCompletion = completion;
}
- (void)cancelDownload
{
    [self cancel];
}

@end

