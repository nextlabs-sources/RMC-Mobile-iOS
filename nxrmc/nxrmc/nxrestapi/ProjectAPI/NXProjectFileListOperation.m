//
//  NXProjectFileListOperation.m
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectFileListOperation.h"
#import "NXProjectFileListParameterModel.h"
#import "NXProjectFileListingAPI.h"
#import "NXRMCDef.h"
@interface NXProjectFileListOperation ()
@property(nonatomic, strong) NXProjectFileListParameterModel *parameterModel;
@property(nonatomic, strong) NSArray *fileItems;
@property(nonatomic, weak) NXProjectFileListingAPIRequest *listFileRequest;
@end
@implementation NXProjectFileListOperation
-(instancetype)initWithParmeterModel:(NXProjectFileListParameterModel *)parmeterModel{
    self = [super init];
    if (self) {
        self.parameterModel = parmeterModel;
        _fileItems = [NSArray array];
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXProjectFileListingAPIRequest *apiRequest = [[NXProjectFileListingAPIRequest alloc]init];
    self.listFileRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.parameterModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXProjectFileListingAPIResponse *detailResponse = (NXProjectFileListingAPIResponse*) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _fileItems=detailResponse.fileItems;
                
                [weakSelf finish:nil];
            }else if(detailResponse.rmsStatuCode == 400){ // means user is kicked
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_KICKED userInfo:nil];
                [weakSelf finish:restError];
            }else{
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                [weakSelf finish:restError];
            }
        }else{
            [weakSelf finish:error];
        }
    }];
    

}
- (void)workFinished:(NSError *)error {
    if (self.ProjectFileListCompletion) {
        self.ProjectFileListCompletion(_fileItems,self.parameterModel,error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.listFileRequest cancelRequest];
    if (self.ProjectFileListCompletion) {
        self.ProjectFileListCompletion(_fileItems,self.parameterModel,cancelError);
    }
}
@end
