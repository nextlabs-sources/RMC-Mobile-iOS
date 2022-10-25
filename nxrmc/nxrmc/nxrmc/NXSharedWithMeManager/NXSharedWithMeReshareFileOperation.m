//
//  NXSharedWithMeReshareFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSharedWithMeReshareFileOperation.h"
#import "NXSharedWithMeFile.h"
#import "NXSharedWithMeReshareFileAPI.h"
#import "NXShareWithMeReshareResponseModel.h"
@interface NXSharedWithMeReshareFileOperation ()
@property (nonatomic ,strong)NXSharedWithMeReshareFileAPIRequest *request;
@property (nonatomic ,strong)NXSharedWithMeFile *freshFile;
@property (nonatomic ,strong)NXSharedWithMeFile *originalFile;
@property (nonatomic ,strong)NXShareWithMeReshareResponseModel *resultModel;
@end
@implementation NXSharedWithMeReshareFileOperation
- (instancetype) initWithSharedWithMeFile:(NXSharedWithMeFile *)sharedWithMeFile withReceivers:(NSArray *)receiversArray {
    self = [super init];
    if (self) {
        NSString *receiverStr = [receiversArray componentsJoinedByString:@","];
        _originalFile = sharedWithMeFile;
        _originalFile.shareWith = receiverStr;
    }
    return  self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXSharedWithMeReshareFileAPIRequest *apiRequest = [[NXSharedWithMeReshareFileAPIRequest alloc]init];
    self.request = apiRequest;
    WeakObj(self);
    [apiRequest requestWithObject:_originalFile Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXSharedWithMeReshareFileAPIResponse *apiResponse = (NXSharedWithMeReshareFileAPIResponse *)response;
            if (apiResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                self.resultModel = apiResponse.responseModel;
                self.freshFile = self.originalFile;
                self.freshFile.transactionId = self.resultModel.freshTransactionId;
            } else {
                error = [[NSError alloc] initWithDomain:NX_ERROR_SHAREDFILE_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_SHAREDFILE_RESAHAREFILE_FAILED", NULL)}];
            }
           
        } else {
            error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", NULL)}];
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.finishReshareFileCompletion) {
        self.finishReshareFileCompletion(self.originalFile, self.freshFile, self.resultModel, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    if (self.request) {
        [self.request cancelRequest];
    }
}
@end
