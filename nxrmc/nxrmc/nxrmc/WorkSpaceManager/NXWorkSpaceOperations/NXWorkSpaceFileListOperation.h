//
//  NXWorkSpaceFileListOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

@class NXWorkSpaceFolder;
typedef void(^getWorkSPaceFileListCompletion)(NSArray *workSpaceFileList,NXWorkSpaceFolder *workSpaceFolder,NSError *error);
typedef void(^getWorkSPaceFileTotalNumberAndStorageCompletion)(NSNumber *fileNumber,NSNumber *storageSize,NSError *error);
@interface NXWorkSpaceFileListOperation : NXOperationBase
@property(nonatomic, copy) getWorkSPaceFileListCompletion getWorkSPaceFileListCompletion;
@property(nonatomic, copy) getWorkSPaceFileTotalNumberAndStorageCompletion getWorkSPaceFileTotalNumberAndStorageCompletion;
- (instancetype)initWithWorkSpaceFolder:(NXWorkSpaceFolder *)workSpaceFolder;
@end


