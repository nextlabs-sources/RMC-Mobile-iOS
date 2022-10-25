//
//  NXProjectRecentFilesOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectRecentFilesOperation.h"
#import "NXProjectFileListParameterModel.h"
#import "NXProjectRecentFilesAPI.h"
#import "NXRMCDef.h"
@interface NXProjectRecentFilesOperation ()
@property(nonatomic, strong) NXProjectFileListParameterModel *parameterModel;
@property(nonatomic, strong) NSArray *fileItems;
@property(nonatomic, strong) NSDictionary *spaceDict;
@property(nonatomic, weak) NXProjectRecentFilesAPIRequest *listFileRequest;
@end
@implementation NXProjectRecentFilesOperation
-(instancetype)initWithParmeterModel:(NXProjectFileListParameterModel *)parmeterModel{
    self =[super init];
    if (self) {
        self.parameterModel = parmeterModel;
        _fileItems = [NSArray array];
        _spaceDict = [NSDictionary dictionary];
    }
    return self;
}
- (void)executeTask:(NSError **)error {
    NXProjectRecentFilesAPIRequest *apiRequest = [[NXProjectRecentFilesAPIRequest alloc]init];
    self.listFileRequest = apiRequest;
    __weak typeof(self) weakSelf = self;
    [apiRequest requestWithObject:self.parameterModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXProjectRecentFilesAPIResponse *detailResponse = (NXProjectRecentFilesAPIResponse *) response;
            if (detailResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
                _fileItems = detailResponse.fileItems;
                _spaceDict = detailResponse.spaceDict;
                [weakSelf finish:nil];
            }else{
                NSString *errorMsg = detailResponse.rmsStatuMessage;
                if (detailResponse.rmsStatuCode == 400) {
                    errorMsg = NSLocalizedString(@"MSG_COM_UNAUTHORIZED_TO_PROJECT", NULL);
                }
                
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_KICKED userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
                [weakSelf finish:restError];
            }
        }else{
            [weakSelf finish:error];
        }
    }];
}
- (void)workFinished:(NSError *)error {
    if (self.ProjectFileListCompletion) {
        self.ProjectFileListCompletion(_fileItems,_spaceDict,self.parameterModel,error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.listFileRequest cancelRequest];
    if (self.ProjectFileListCompletion) {
        self.ProjectFileListCompletion(_fileItems,_spaceDict,self.parameterModel,cancelError);
    }
}
@end
