//
//  NXWorkSpaceCreateFolderOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceCreateFolderOperation.h"
#import "NXWorkSpaceItem.h"
@interface NXWorkSpaceCreateFolderOperation ()
@property(nonatomic, strong)NXFolder *workSpaceFolder;
@property(nonatomic, strong)NXWorkSpaceCreateFolderRequest *request;
@property(nonatomic, strong)NXWorkSpaceCreateFolderModel *workSpaceCreateFolderModel;
@end
@implementation NXWorkSpaceCreateFolderOperation
- (instancetype)initWithWorkSpaceCreateFolderModel:(NXWorkSpaceCreateFolderModel *)model {
    self = [super init];
    if (self) {
        _workSpaceCreateFolderModel = model;
        _workSpaceFolder = [[NXFolder alloc]init];
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXWorkSpaceCreateFolderRequest *request = [[NXWorkSpaceCreateFolderRequest alloc]init];
    self.request = request;
    [request requestWithObject:self.workSpaceCreateFolderModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXWorkSpaceCreateFolderResponse *workSpaceCreateFolderResponse = (NXWorkSpaceCreateFolderResponse *)response;
            if (workSpaceCreateFolderResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS){
                self.workSpaceFolder = workSpaceCreateFolderResponse.createdFolder;
            }else{
                if (workSpaceCreateFolderResponse.rmsStatuCode == NXRMS_ERROR_CODE_NOT_FOUND) {
                    error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:@"The workspace folder not found"}];
                }else{
                    error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:workSpaceCreateFolderResponse.rmsStatuMessage? :NSLocalizedString(@"MSG_ADD_FOLDER_ERROR", nil)}];
                }
               
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error{
    if (self.createWorkSpaceFolderCompletion) {
        self.createWorkSpaceFolderCompletion(self.workSpaceFolder, error);
    }
}
- (void)cancelWork:(NSError *)cancelError{
    [self.request cancelRequest];
}
@end
