//
//  NXSharedWithProjectFileListOperation.h
//  nxrmc
//
//  Created by 时滕 on 2019/12/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXProjectModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^getSharedWithProjectFileListCompletion)(NXProjectModel *project,NSArray *fileListArray,NSError *error);

@interface NXSharedWithProjectFileListOperation : NXOperationBase
- (instancetype)initWithProjectModel:(NXProjectModel *)project;

@property (nonatomic ,copy) getSharedWithProjectFileListCompletion sharedWithProjectFileListCompletion;
@end

NS_ASSUME_NONNULL_END
