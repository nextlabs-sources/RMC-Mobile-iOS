//
//  NXSharedWithProjectFileListOperation.m
//  nxrmc
//
//  Created by 时滕 on 2019/12/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFileListOperation.h"
#import "NXSharedWithProjectFilesAPI.h"

@interface NXSharedWithProjectFileListOperation()
@property(nonatomic, strong) NXProjectModel *project;
@property (nonatomic, strong) NSArray *filesArray;
@property(nonatomic, strong) NXSharedWithProjectFilesRequest *listFileRequest;
@end

@implementation NXSharedWithProjectFileListOperation
- (instancetype)initWithProjectModel:(NXProjectModel *)project {
    if (self = [super init]) {
        _project = project;
    }
    return self;
}

- (void)executeTask:(NSError *__autoreleasing *)error {
    NXSharedWithProjectFilesRequest *apiRequest = [[NXSharedWithProjectFilesRequest alloc]init];
    self.listFileRequest = apiRequest;
    WeakObj(self);
    [apiRequest requestWithObject:self.project Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXSharedWithProjectFilesResponse *apiResponse = (NXSharedWithProjectFilesResponse *)response;
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
    if (self.sharedWithProjectFileListCompletion) {
        self.sharedWithProjectFileListCompletion(self.project, self.filesArray, error);
    }
}

- (void)cancelWork:(NSError *)cancelError {
    if (self.listFileRequest) {
        [self.listFileRequest cancelRequest];
    }
}
@end
