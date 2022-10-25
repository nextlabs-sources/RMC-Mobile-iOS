//
//  NXWorkSpaceUploadFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceUploadFileOperation.h"
@interface NXWorkSpaceUploadFileOperation ()
@property(nonatomic, strong)NXWorkSpaceUploadFileRequest *request;
@property(nonatomic, strong)NXWorkSpaceFile *workSpaceFile;
@property(nonatomic, strong)NXWorkSpaceUploadFileModel *workSpaceUploadModel;
@end
@implementation NXWorkSpaceUploadFileOperation
- (instancetype)initWithWorkSpaceUploadFileModel:(NXWorkSpaceUploadFileModel *)model{
    self = [super init];
    if (self) {
        _workSpaceUploadModel = model;
        _workSpaceFile = [[NXWorkSpaceFile alloc]init];
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error{
    NXWorkSpaceUploadFileRequest *request = [[NXWorkSpaceUploadFileRequest alloc]init];
    self.request = request;
    [request requestWithObject:self.workSpaceUploadModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXWorkSpaceUploadFileResponse *workSpaceUploadResponse = (NXWorkSpaceUploadFileResponse *)response;
            if (workSpaceUploadResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS){
                _workSpaceFile = workSpaceUploadResponse.uploadedFile;
            }else if(workSpaceUploadResponse.rmsStatuCode == NXRMS_ERROR_CODE_NOT_FOUND){
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:@"Workspace folder not found"}];
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:response.rmsStatuMessage}];
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.uploadWorkSpaceFileCompletion) {
        self.uploadWorkSpaceFileCompletion(self.workSpaceFile, self.workSpaceUploadModel, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.request cancelRequest];
    if (self.uploadWorkSpaceFileCompletion) {
        self.uploadWorkSpaceFileCompletion(self.workSpaceFile, self.workSpaceUploadModel,cancelError);
    }
}
@end
