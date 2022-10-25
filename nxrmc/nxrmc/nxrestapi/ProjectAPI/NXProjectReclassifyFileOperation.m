//
//  NXProjectReclassifyFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/5/8.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXProjectReclassifyFileOperation.h"
#import "NXProjectReclassifyFileAPI.h"
#import "NXProjectFile.h"
#import "NXProjectUploadFileParameterModel.h"
@interface NXProjectReclassifyFileOperation ()
@property (nonatomic, strong)NXProjectUploadFileParameterModel *parameterModel;
@property (nonatomic, strong)NXProjectFile *fileItem;
@property (nonatomic, weak) NXProjectReclassifyFileAPIRequest *reclassifyFileRequest;
@end
@implementation NXProjectReclassifyFileOperation
- (instancetype)initWithParmeterModel:(NXProjectUploadFileParameterModel *)parmeterModel {
    self = [super init];
    if (self) {
        _parameterModel = parmeterModel;
        _fileItem = [[NXProjectFile alloc]init];
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXProjectReclassifyFileAPIRequest *apiRequest = [[NXProjectReclassifyFileAPIRequest alloc]init];
    self.reclassifyFileRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.parameterModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXProjectReclassifyFileAPIResponse *detailResponse = (NXProjectReclassifyFileAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _fileItem = detailResponse.fileItem;
                _fileItem.duid = _parameterModel.duid;
                
                [weakSelf finish:nil];
            }else{
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:detailResponse.rmsStatuMessage?: NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                [weakSelf finish:restError];
            }
        }else{
            [weakSelf finish:error];
        }
    }];
    
}

- (void)workFinished:(NSError *)error {
    if (self.projectReclassifyFileCompletion) {
        self.projectReclassifyFileCompletion (_fileItem,self.parameterModel,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.reclassifyFileRequest cancelRequest];
    if (self.projectReclassifyFileCompletion) {
        self.projectReclassifyFileCompletion (nil, nil,cancelError);
    }
    
}
@end
