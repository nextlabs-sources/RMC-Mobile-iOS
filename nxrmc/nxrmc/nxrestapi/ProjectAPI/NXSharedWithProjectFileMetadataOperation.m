//
//  NXSharedWithProjectFileMetadataOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/1.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFileMetadataOperation.h"
#import "NXSharedWithProjectFile.h"
#import "NXSharedWithProjectFileMatadataAPI.h"
@interface NXSharedWithProjectFileMetadataOperation ()
@property(nonatomic, strong)NXSharedWithProjectFile *fileItem;
@property(nonatomic, strong)NXSharedWithProjectFileMatadataAPIRequest *metadataRequest;
@end
@implementation NXSharedWithProjectFileMetadataOperation
-(instancetype)initWithSharedWithProjectFile:(NXSharedWithProjectFile *)fileItem {
    if (self = [super init]) {
        _fileItem = fileItem;
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXSharedWithProjectFileMatadataAPIRequest *apiRequest = [[NXSharedWithProjectFileMatadataAPIRequest alloc]init];
    self.metadataRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.fileItem Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
          NXSharedWithProjectFileMatadataAPIResponse *detailResponse = (NXSharedWithProjectFileMatadataAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                self.fileItem = detailResponse.fileItem;
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
    if (self.getSharedWithProjectFileMetadataCompletion) {
        self.getSharedWithProjectFileMetadataCompletion(self.fileItem,error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.metadataRequest cancelRequest];
    if (self.getSharedWithProjectFileMetadataCompletion) {
        self.getSharedWithProjectFileMetadataCompletion(self.fileItem,cancelError);
    }
}
@end
