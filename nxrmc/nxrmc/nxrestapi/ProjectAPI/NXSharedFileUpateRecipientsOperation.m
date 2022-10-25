//
//  NXProjectSharedFileUpateRecipientsOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSharedFileUpateRecipientsOperation.h"

@interface NXSharedFileUpateRecipientsOperation ()
@property (nonatomic, strong) NXUpdateProjectSharingRecipientsRequest *request;
@property (nonatomic, strong) NXUpdateSharingRecipientsModel *model;
@property (nonatomic, strong) NSArray *aNewSharingList;
@property (nonatomic, strong) NSArray *alreadySharingList;
@property (nonatomic, strong) NSArray *removeSharedList;
@end
@implementation NXSharedFileUpateRecipientsOperation
- (instancetype)initWithModel:(NXUpdateSharingRecipientsModel *)model {
    if (self = [super init]) {
        _model = model;
        _aNewSharingList = [NSArray array];
        _alreadySharingList = [NSArray array];
        _removeSharedList = [NSArray array];
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXUpdateProjectSharingRecipientsRequest *apiRequest = [[NXUpdateProjectSharingRecipientsRequest alloc] init];
    self.request = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.model Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            [weakSelf finish:error];
            return;
        }
        NXUpdateProjectSharingRecipientsAPIResponse *detailResponse = (NXUpdateProjectSharingRecipientsAPIResponse*) response;
        if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
            self.aNewSharingList = detailResponse.addedRecipients;
            self.alreadySharingList = detailResponse.alreadySharingRecpipents;
            self.removeSharedList = detailResponse.removedRecipients;
        }else{
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:detailResponse.rmsStatuMessage};
            error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:userInfo];
        }
        [weakSelf finish:error];
    }];
    
}

- (void)workFinished:(NSError *)error {
    if (self.projectFileUpdateRecipientsCompletion) {
        self.projectFileUpdateRecipientsCompletion (self.aNewSharingList,self.alreadySharingList,self.removeSharedList,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.request cancelRequest];
    if (self.projectFileUpdateRecipientsCompletion) {
        self.projectFileUpdateRecipientsCompletion (nil, nil,nil,cancelError);
    }
    
}
@end
