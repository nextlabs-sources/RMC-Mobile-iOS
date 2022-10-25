//
//  NXProjectCreateOperation.m
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectCreateOperation.h"
#import "NXProjectModel.h"
#import "NXRMCDef.h"
@interface NXProjectCreateOperation ()
@property (nonatomic, strong) NXProjectModel *porojectItem;
@property (nonatomic, strong) NXProjectCreateParmetersMD *parModel;
@property(nonatomic, weak) NXProjectCreateAPIRequest *createProjectRequest;
@end
@implementation NXProjectCreateOperation
- (instancetype)initWithParmeterModel:(NXProjectCreateParmetersMD *)parmeterModel {
    self = [super init];
    if (self) {
        _porojectItem = [[NXProjectModel alloc]init];
        _parModel = parmeterModel;
    }
    return self;
}

- (void)executeTask:(NSError **)error {
    NXProjectCreateAPIRequest *apiRequest = [[NXProjectCreateAPIRequest alloc]init];
    self.createProjectRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:_parModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXProjectCreateAPIResponse *detailResponse = (NXProjectCreateAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _porojectItem=detailResponse.ProjectModel;
                
                [weakSelf finish:nil];
            }else{
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:detailResponse.rmsStatuMessage}];
                [weakSelf finish:restError];
            }
        }else{
            [weakSelf finish:error];
        }
    }];

}
- (void)workFinished:(NSError *)error {
    if (self.createProjectCompletion) {
        self.createProjectCompletion(_porojectItem,_parModel,error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.createProjectRequest cancelRequest];
    if (self.createProjectCompletion) {
        self.createProjectCompletion(_porojectItem,_parModel,cancelError);
    }
}
@end
