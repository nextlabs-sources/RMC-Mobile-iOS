//
//  NXSharedWithMeReshareProjectFileOperation.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithMeReshareProjectFileOperation.h"
#import "NXSharedWithProjectFile.h"

@interface NXSharedWithMeReshareProjectFileOperation ()

@property (nonatomic ,strong)NXSharedWithMeReshareProjectFileAPIRequest *request;
@property (nonatomic ,strong)NXSharedWithMeReshareProjectFileRequestModel *resultModel;
@property (nonatomic ,strong)NXSharedWithMeReshareProjectFileResponseModel *responseModel;
@property (nonatomic ,strong)NXSharedWithProjectFile *freshFile;
@property (nonatomic ,strong)NXSharedWithProjectFile *originalFile;
@end

@implementation NXSharedWithMeReshareProjectFileOperation
- (instancetype)initWithSharedWithProjectFile:(NXSharedWithProjectFile *)sharedWithProjectFile withReceivers:(NXSharedWithMeReshareProjectFileRequestModel *)receiversArray; {
    self = [super init];
    if (self) {
        _originalFile = sharedWithProjectFile;
        _resultModel = receiversArray;
    }
    return  self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXSharedWithMeReshareProjectFileAPIRequest *apiRequest = [[NXSharedWithMeReshareProjectFileAPIRequest alloc]init];
    self.request = apiRequest;
    WeakObj(self);
    [apiRequest requestWithObject:self.resultModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXSharedWithMeReshareProjectFileAPIResponse *apiResponse = (NXSharedWithMeReshareProjectFileAPIResponse *)response;
            if (apiResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                self.responseModel = apiResponse.responseModel;
                self.freshFile = self.originalFile;
                self.freshFile.transactionId = apiResponse.responseModel.freshTransactionId;
            } else {
                error = [[NSError alloc] initWithDomain:NX_ERROR_SHAREDFILE_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:apiResponse.rmsStatuMessage?: NSLocalizedString(@"MSG_SHAREDFILE_RESAHAREFILE_FAILED", NULL)}];
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.finishReshareProjectFileCompletion) {
        self.finishReshareProjectFileCompletion(self.originalFile, self.freshFile, self.responseModel, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    if (self.request) {
        [self.request cancelRequest];
    }
}
@end
