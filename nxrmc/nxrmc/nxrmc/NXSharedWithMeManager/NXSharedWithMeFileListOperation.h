//
//  NXSharedWithMeFileListOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
@class NXSharedWithMeFileListParameterModel;

typedef void(^getSharedWithMeFileListCompletion)(NXSharedWithMeFileListParameterModel *parameterModel,NSArray *fileListArray,NSError *error);

@interface NXSharedWithMeFileListOperation : NXOperationBase
- (instancetype)initWithSharedWithMeFileListParameterModel:(NXSharedWithMeFileListParameterModel *)parameterModel;

@property (nonatomic ,copy)getSharedWithMeFileListCompletion sharedWithMeFileListCompletion;

@end
