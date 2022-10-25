//
//  NXPojectFileSharingOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXProjectFileSharingOperation.h"

@interface NXProjectFileSharingOperation ()
@property (nonatomic, strong) NXSharingProjectFileRequest *request;
@property (nonatomic, strong) NXSharingProjectFileModel *model;
@property (nonatomic, strong) NSArray *aNewSharingList;
@property (nonatomic, strong) NSArray *alreadySharingList;
@end
@implementation NXProjectFileSharingOperation
- (instancetype)initWithModel:(NXSharingProjectFileModel *)model {
    if (self = [super init]) {
        _model = model;
        _aNewSharingList = [NSArray array];
        _alreadySharingList = [NSArray array];
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXSharingProjectFileRequest *apiRequest = [[NXSharingProjectFileRequest alloc] init];
    self.request = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.model Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXSharingProjectFileResponse *detailResponse = (NXSharingProjectFileResponse*) response;
        if (error) {
            [weakSelf finish:error];
            return ;
        }
        if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
            self.aNewSharingList = detailResponse.anewSharedList;
            self.alreadySharingList = detailResponse.alreadySharedList;
        }else{
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:detailResponse.rmsStatuMessage};
            error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:userInfo];
        }
        [weakSelf finish:error];
    }];
    
}

- (void)workFinished:(NSError *)error {
    if (self.projectFileSharingCompletion) {
        self.projectFileSharingCompletion (self.aNewSharingList,self.alreadySharingList,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.request cancelRequest];
    if (self.projectFileSharingCompletion) {
        self.projectFileSharingCompletion (nil, nil,cancelError);
    }
    
}
@end
