//
//  NXAllProjectListOperation.m
//  nxrmc
//
//  Created by Sznag on 2020/3/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXAllProjectListOperation.h"
#import "NXAllProjectListAPI.h"
@interface NXAllProjectListOperation ()
@property (nonatomic, strong)NSString *projectKindType;
@property (nonatomic, strong)NSArray *projectItems;
@property (nonatomic, weak) NXAllProjectListAPIRequest *listProjectRequest;

@end
@implementation NXAllProjectListOperation
- (instancetype)init {
    if (self = [super init]) {
        _projectItems = [NSArray array];
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXAllProjectListAPIRequest *apiRequest = [[NXAllProjectListAPIRequest alloc]init];
    self.listProjectRequest = apiRequest;
    WeakObj(self);
    [apiRequest requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
             NXAllProjectListAPIResponse *detailResponse = (NXAllProjectListAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _projectItems = detailResponse.itemsArray;
            
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:detailResponse.rmsStatuMessage}];
            }
        }
        
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.getProjectListCompletion) {
        self.getProjectListCompletion(_projectItems,error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.listProjectRequest cancelRequest];
}

@end
