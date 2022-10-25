//
//  NXProjectMetaDataOperation.m
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectMetaDataOperation.h"
#import "NXProjectMetadataAPI.h"
#import "NXProjectModel.h"
#import "NXRMCDef.h"
@interface NXProjectMetaDataOperation ()
@property (nonatomic, strong) NSNumber *projectId;
@property (nonatomic, strong) NXProjectModel *projectMetaData;
@property (nonatomic, weak) NXProjectMetadataAPIRequest *projectMetaDataRequest;
@end
@implementation NXProjectMetaDataOperation

- (instancetype)initWithProjectModelId:(NSNumber *)projectId {
    self = [super init];
    if (self) {
        _projectMetaData = [[NXProjectModel alloc]init];

        self.projectId = projectId;
        
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXProjectMetadataAPIRequest *apiRequest = [[NXProjectMetadataAPIRequest alloc]init];
    self.projectMetaDataRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.projectId Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
           NXProjectMetadataAPIResponse *detailResponse = (NXProjectMetadataAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _projectMetaData = detailResponse.projectItem;
                
                [weakSelf finish:nil];
            }else{
                
                NSString *errorMsg = detailResponse.rmsStatuMessage;
                
                if (detailResponse.rmsStatuCode == 400) {
                    errorMsg = NSLocalizedString(@"MSG_COM_UNAUTHORIZED_TO_PROJECT", NULL);
                }
                
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
                [weakSelf finish:restError];
            }
        }else{
            [weakSelf finish:error];
        }
    }];

}
- (void)workFinished:(NSError *)error {
    if (self.ProjectMetaDataCompletion) {
        self.ProjectMetaDataCompletion(_projectMetaData,self.projectId,error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.projectMetaDataRequest cancelRequest];
    if (self.ProjectMetaDataCompletion) {
        self.ProjectMetaDataCompletion(nil, nil,cancelError);
    }
}
@end
