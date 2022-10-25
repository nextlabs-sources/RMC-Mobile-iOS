//
//  NXSharedWithMeFileListOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSharedWithMeFileListOperation.h"
#import "NXSharedWithMeFileListAPI.h"

@interface NXSharedWithMeFileListOperation ()
@property (nonatomic, strong) NXSharedWithMeFileListAPIRequest *request;
@property (nonatomic, strong) NSArray *filesArray;
@property (nonatomic, strong) NXSharedWithMeFileListParameterModel *parameterModel;
@end
@implementation NXSharedWithMeFileListOperation
- (instancetype)initWithSharedWithMeFileListParameterModel:(NXSharedWithMeFileListParameterModel *)parameterModel {
    self = [super init];
    if (self) {
        _parameterModel = parameterModel;
        _filesArray = [NSArray array];
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXSharedWithMeFileListAPIRequest *apiRequest = [[NXSharedWithMeFileListAPIRequest alloc]init];
    self.request = apiRequest;
    WeakObj(self);
    [apiRequest requestWithObject:self.parameterModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXSharedWithMeFileListAPIResponse *apiResponse = (NXSharedWithMeFileListAPIResponse *)response;
            if ((apiResponse.rmsStatuCode = NXRMS_ERROR_CODE_SUCCESS)) {
                self.filesArray = apiResponse.itemsArray;
            } else {
                error = [[NSError alloc] initWithDomain:NX_ERROR_SHAREDFILE_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_SHAREDFILE_GETFILELIST_FAILED", NULL)}];
            }
            
        } else {
             error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNREACH", NULL)}];
        }
        [self finish:error];
    }];
}

- (void)workFinished:(NSError *)error {
    if (self.sharedWithMeFileListCompletion) {
        self.sharedWithMeFileListCompletion(self.parameterModel, self.filesArray, error);
    }
}

- (void)cancelWork:(NSError *)cancelError {
    if (self.request) {
        [self.request cancelRequest];
    }
}

@end
