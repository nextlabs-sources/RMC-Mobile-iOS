//
//  NXProjectListOperation.m
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectListOperation.h"
#import "NXProjectListAPI.h"
#import "NXRMCDef.h"
#import "NXProjectsListParameterModel.h"
@interface NXProjectListOperation ()
@property (nonatomic, strong)NSString *projectKindType;
@property (nonatomic, strong)NSArray *projectItems;
@property (nonatomic, weak) NXProjectListAPIRequest *listProjectRequest;
@property (nonatomic, strong)NXProjectsListParameterModel *parameterModel;
@end
@implementation NXProjectListOperation

-(instancetype) initWithProjectListParameterModel:(NXProjectsListParameterModel *)parameterModel {
    self=[super init];
    if (self) {
        _parameterModel = parameterModel;
        _projectItems = [NSArray array];
    }
    return self;
}

- (void)dealloc
{

}

- (void)executeTask:(NSError **)error {
    NXProjectListAPIRequest *apiRequest = [[NXProjectListAPIRequest alloc]init];
    self.listProjectRequest = apiRequest;
    WeakObj(self);
    [apiRequest requestWithObject:_parameterModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
             NXProjectListAPIResponse *detailResponse = (NXProjectListAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _projectItems = detailResponse.itemsArray;
            
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
            }
        }
        
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.getProjectListCompletion) {
        self.getProjectListCompletion(_projectItems,self.projectKindType,error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.listProjectRequest cancelRequest];
}

@end
