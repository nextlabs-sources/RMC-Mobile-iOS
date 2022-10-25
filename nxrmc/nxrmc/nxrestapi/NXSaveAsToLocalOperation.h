//
//  NXSaveAsToLocalOperation.h
//  nxrmc
//
//  Created by Sznag on 2022/2/15.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
typedef void(^saveAsFinishCompletion)(NXFileBase *spaceFile,NSError *error);
@interface NXSaveAsToLocalOperation : NXOperationBase
@property(nonatomic, copy)saveAsFinishCompletion saveAsFinishCompletion;
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem;
@end

NS_ASSUME_NONNULL_END
