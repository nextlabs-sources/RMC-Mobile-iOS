//
//  NXProjectUploadFileOperation.m
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectUploadFileOperation.h"
#import "NXProjectUploadFileParameterModel.h"
#import "NXProjectUploadFileAPI.h"
#import "NXRMCDef.h"
#import "NXProjectFile.h"
@interface NXProjectUploadFileOperation ()
@property (nonatomic, strong)NXProjectUploadFileParameterModel *parameterModel;
@property (nonatomic, strong)NXProjectFile *fileItem;
@property (nonatomic, weak) NXProjectUploadFileAPIRequest *uploadFileRequest;
@end
@implementation NXProjectUploadFileOperation
- (instancetype)initWithParmeterModel:(NXProjectUploadFileParameterModel *)parmeterModel {
    self = [super init];
    if (self) {
        self.parameterModel = parmeterModel;
        _fileItem = [[NXProjectFile alloc]init];
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXProjectUploadFileAPIRequest *apiRequest = [[NXProjectUploadFileAPIRequest alloc] init];
    self.uploadFileRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.parameterModel withUploadProgress:self.uploadProgress downloadProgress:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXProjectUploadFileAPIResponse *detailResponse = (NXProjectUploadFileAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _fileItem=detailResponse.fileItem;
                
                [weakSelf finish:nil];
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_AUTHFAILED userInfo:@{NSLocalizedDescriptionKey:detailResponse.rmsStatuMessage}];
                [weakSelf finish:error];
            }
        }else{
            [weakSelf finish:error];
        }
    }];

}

- (void)workFinished:(NSError *)error {
    if (self.projectUploadFileCompletion) {
        self.projectUploadFileCompletion (_fileItem,self.parameterModel,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.uploadFileRequest cancelRequest];
    if (self.projectUploadFileCompletion) {
        self.projectUploadFileCompletion (nil, nil,cancelError);
    }
    
}
@end
