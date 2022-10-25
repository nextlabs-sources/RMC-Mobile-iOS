//
//  NXWorkSpaceUploadFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXWorkSpaceUploadFileAPI.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^uploadWorkSpaceFileCompletion)(NXWorkSpaceFile *workSpaceFile,NXWorkSpaceUploadFileModel *uploadWorkSpcaeModel,NSError *error);
@interface NXWorkSpaceUploadFileOperation : NXOperationBase
- (instancetype)initWithWorkSpaceUploadFileModel:(NXWorkSpaceUploadFileModel *)model;
@property (nonatomic, copy)uploadWorkSpaceFileCompletion uploadWorkSpaceFileCompletion;
@end

NS_ASSUME_NONNULL_END
