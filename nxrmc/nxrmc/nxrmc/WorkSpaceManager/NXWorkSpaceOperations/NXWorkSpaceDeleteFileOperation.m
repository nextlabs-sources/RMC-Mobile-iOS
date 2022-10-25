//
//  NXWorkSpaceDeleteFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceDeleteFileOperation.h"
#import "NXWorkSpaceDeleteItemAPI.h"
#import "NXWorkSpaceItem.h"
@interface NXWorkSpaceDeleteFileOperation ()
@property(nonatomic, strong)NXFileBase *workSpaceItem;
@property(nonatomic, strong)NXWorkSpaceDeleteItemRequest *request;
@end
@implementation NXWorkSpaceDeleteFileOperation
- (instancetype)initWithNXWorkSpaceFile:(NXFileBase *)workSpaceFile {
    self = [super init];
    if (self) {
        _workSpaceItem = workSpaceFile;
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error{
    NXWorkSpaceDeleteItemRequest *request = [[NXWorkSpaceDeleteItemRequest alloc]init];
    self.request = request;
    [request requestWithObject:self.workSpaceItem Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXWorkSpaceDeleteItemResponse *workSpaceUploadResponse = (NXWorkSpaceDeleteItemResponse *)response;
            if (workSpaceUploadResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS){
              
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.deleteWorkSpaceFileCompletion) {
        self.deleteWorkSpaceFileCompletion(self.workSpaceItem, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.request cancelRequest];
}
@end
