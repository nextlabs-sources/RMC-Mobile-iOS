//
//  NXRevokeSharingFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXRevokingSharedFileOperation.h"
#import "NXRevokeSharedFileAPI.h"
@interface NXRevokingSharedFileOperation ()
@property(nonatomic, strong)NSString *fileDuid;
@property(nonatomic, strong)NXRevokeSharedFileRequest *request;
@end
@implementation NXRevokingSharedFileOperation

- (instancetype)initWithFileDuid:(NSString *)fileDuid {
    if (self = [super init]) {
        _fileDuid = fileDuid;
    }
    return self;
    
}
- (void)executeTask:(NSError **)error {
    NXRevokeSharedFileRequest *apiRequest = [[NXRevokeSharedFileRequest alloc] init];
    self.request = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.fileDuid Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            [weakSelf finish:error];
            return ;
        }
        NXRevokeSharedFileResponse *detailResponse = (NXRevokeSharedFileResponse *)response;
        if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
        }else{
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:detailResponse.rmsStatuMessage};
            error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:userInfo];
        }
        [weakSelf finish:error];
    }];
    
    
}

- (void)workFinished:(NSError *)error {
    if (self.revokeSharedFileCompletion) {
        self.revokeSharedFileCompletion (error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.request cancelRequest];
    if (self.revokeSharedFileCompletion) {
        self.revokeSharedFileCompletion (cancelError);
    }
    
}
@end
