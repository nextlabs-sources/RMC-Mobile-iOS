//
//  NXCopyNxlFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/4/9.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
typedef void(^copyNxlFileFinishCompletion)(NXFileBase *spaceFile,NSError *error);
@interface NXCopyNxlFileOperation : NXOperationBase

@property(nonatomic, copy)copyNxlFileFinishCompletion copyNxlFileCompletion;
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem andDestSpaceType:(NSString *)destSapcePath;
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem shouldOverwrite:(BOOL)overwrite andDestSpaceType:(NSString *)destSapceType andDestSpacePathFolder:(NXFileBase *)destSpacePathFolder;
@end

NS_ASSUME_NONNULL_END
