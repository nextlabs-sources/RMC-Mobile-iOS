//
//  NXProjectUpateOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 21/8/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectUpateOperation.h"
#import "NXProjectModel.h"
#import "NXRMCDef.h"
@interface NXProjectUpateOperation ()
@property (nonatomic, strong) NXProjectModel *porojectItem;
@property (nonatomic, strong)NXProjectUpdateParmetersMD *parModel;
@property (nonatomic, weak)NXProjectUpdateAPIRequest *updateAPIRequest;
@end
@implementation NXProjectUpateOperation
- (instancetype)initWithParmeterModel:(NXProjectUpdateParmetersMD *)parmeterModel {
    self = [super init];
    if (self) {
        _porojectItem = [[NXProjectModel alloc]init];
        _parModel = parmeterModel;
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXProjectUpdateAPIRequest *apiRequest = [[NXProjectUpdateAPIRequest alloc]init];
    self.updateAPIRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:_parModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXProjectUpdateAPIResponse *detailResponse = (NXProjectUpdateAPIResponse *) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _porojectItem = detailResponse.ProjectModel;
                
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
    if (self.updateProjectCompletion) {
        self.updateProjectCompletion(_porojectItem,_parModel,error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.updateAPIRequest cancelRequest];
    if (self.updateProjectCompletion) {
        self.updateProjectCompletion(_porojectItem,_parModel,cancelError);
    }
}


@end
