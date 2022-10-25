//
//  NXWorkSpaceReclassifityFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

NS_ASSUME_NONNULL_BEGIN
@class NXWorkSpaceReclassifyFileModel;
@class NXWorkSpaceFile;
typedef void(^reclassifyWorkSpaceFileCompletion)(NXWorkSpaceFile *spaceFile,NXWorkSpaceReclassifyFileModel *model,NSError *error);
@interface NXWorkSpaceReclassifityFileOperation : NXOperationBase
- (instancetype)initWithWorkSpaceReclassifyModel:(NXWorkSpaceReclassifyFileModel *)model;
@property(nonatomic, copy)reclassifyWorkSpaceFileCompletion reclassifyWorkSpaceFileCompletion;
@end

NS_ASSUME_NONNULL_END
