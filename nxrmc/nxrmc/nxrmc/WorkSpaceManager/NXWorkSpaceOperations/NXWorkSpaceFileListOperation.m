//
//  NXWorkSpaceFileListOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceFileListOperation.h"
#import "NXWorkSpaceFileListAPI.h"
#import "NXWorkSpaceItem.h"
@interface NXWorkSpaceFileListOperation ()
@property (nonatomic, strong) NSArray *fileListArray;
@property (nonatomic, strong) NXWorkSpaceFolder *workSpcaeFolder;
@property (nonatomic, strong) NXWorkSpaceFileListRequest *request;
@property (nonatomic, strong) NSNumber *fileNumber;
@property (nonatomic, strong) NSNumber *fileStorage;
@end
@implementation NXWorkSpaceFileListOperation
- (instancetype)initWithWorkSpaceFolder:(NXWorkSpaceFolder *)workSpaceFolder {
    self = [super init];
    if (self) {
        _workSpcaeFolder = workSpaceFolder;
        _fileListArray = [NSArray array];
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXWorkSpaceFileListRequest *request = [[NXWorkSpaceFileListRequest alloc]init];
    self.request = request;
    [request requestWithObject:self.workSpcaeFolder Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXWorkSaceFileListResponse *workSpaceResponse = (NXWorkSaceFileListResponse *)response;
            if (workSpaceResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS ) {
                _fileListArray = workSpaceResponse.workSpaceFileList;
                _fileNumber = workSpaceResponse.totalFiles;
                _fileStorage = workSpaceResponse.usage;

            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error{
    if (self.getWorkSPaceFileListCompletion) {
        self.getWorkSPaceFileListCompletion(self.fileListArray, self.workSpcaeFolder, error);
    }
    if (self.getWorkSPaceFileTotalNumberAndStorageCompletion) {
        self.getWorkSPaceFileTotalNumberAndStorageCompletion(self.fileNumber, self.fileStorage, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.request cancelRequest];
}
@end
