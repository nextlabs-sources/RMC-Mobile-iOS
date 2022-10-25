//
//  NXAddLocalNXLFileToOtherSpaceOperation.h
//  nxrmc
//
//  Created by Sznag on 2022/2/23.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
typedef void(^addLocalNXLFileFinishCompletion)(NXFileBase *spaceFile,NSError *error);
@interface NXAddLocalNXLFileToOtherSpaceOperation : NXOperationBase

@property(nonatomic, copy)addLocalNXLFileFinishCompletion addLocalNXLFileFinishCompletion;
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem shouldOverwrite:(BOOL)overwrite andDestSpaceType:(NSString *)destSapceType andDestSpacePathFolder:(NXFileBase *)destSpacePathFolder;
@end

NS_ASSUME_NONNULL_END
