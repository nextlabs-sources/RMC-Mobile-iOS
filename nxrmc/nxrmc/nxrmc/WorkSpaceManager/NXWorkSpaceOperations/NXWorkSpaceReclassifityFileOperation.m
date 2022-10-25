//
//  NXWorkSpaceReclassifityFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceReclassifityFileOperation.h"
#import "NXWorkSpaceReclassifyFileAPI.h"
#import "NXWorkSpaceItem.h"
@interface NXWorkSpaceReclassifityFileOperation ()
@property(nonatomic, strong)NXWorkSpaceReclassifyFileModel *workSpaceReclassifyModel;
@property(nonatomic, strong)NXWorkSpaceReclassifyFileRequest *request;
@property(nonatomic, strong)NXWorkSpaceFile *spaceFile;
@end
@implementation NXWorkSpaceReclassifityFileOperation
- (instancetype)initWithWorkSpaceReclassifyModel:(NXWorkSpaceReclassifyFileModel *)model{
    self = [super init];
    if (self) {
        _workSpaceReclassifyModel = model;
        _spaceFile = [[NXWorkSpaceFile alloc]init];
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXWorkSpaceReclassifyFileRequest *request = [[NXWorkSpaceReclassifyFileRequest alloc]init];
    self.request = request;
    [request requestWithObject:self.workSpaceReclassifyModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXWorkSpaceReclassifyFileResponse *detailResponse = (NXWorkSpaceReclassifyFileResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _spaceFile = detailResponse.workSpaceItem;
                
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.reclassifyWorkSpaceFileCompletion) {
        self.reclassifyWorkSpaceFileCompletion(self.spaceFile,self.workSpaceReclassifyModel, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.request cancelRequest];
}
@end
