//
//  NXWorkSpaceGetFileMetadataOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceGetFileMetadataOperation.h"
#import "NXGetWorkSpaceFileMetadataAPI.h"
#import "NXWorkSpaceItem.h"
@interface NXWorkSpaceGetFileMetadataOperation ()
@property(nonatomic, strong)NXGetWorkSpaceFileMetadataRequest *request;
@property(nonatomic, strong)NXWorkSpaceFile *workSpaceFile;
@end
@implementation NXWorkSpaceGetFileMetadataOperation
- (instancetype)initWithWorkSpaceFile:(NXWorkSpaceFile *)workSpaceFile {
    self = [super init];
    if (self) {
        _workSpaceFile = workSpaceFile;
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXGetWorkSpaceFileMetadataRequest *request = [[NXGetWorkSpaceFileMetadataRequest alloc]init];
    self.request = request;
    [request requestWithObject:self.workSpaceFile Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXGetWorkSpaceFileMetadataResponse *detailResponse = (NXGetWorkSpaceFileMetadataResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                self.workSpaceFile = detailResponse.workSpaceFile;
                
            }else{
                
                NSString *errorMsg = detailResponse.rmsStatuMessage;
            
               error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.getWorkSpaceFileMetadataCompletion) {
        self.getWorkSpaceFileMetadataCompletion(self.workSpaceFile, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.request cancelRequest];
}
@end
