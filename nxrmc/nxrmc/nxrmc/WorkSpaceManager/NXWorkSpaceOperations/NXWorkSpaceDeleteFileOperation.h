//
//  NXWorkSpaceDeleteFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"


@class NXFileBase;
typedef void(^deleteWorkSpaceFileCompletion)(NXFileBase *spaceFile,NSError *error);
@interface NXWorkSpaceDeleteFileOperation : NXOperationBase
- (instancetype)initWithNXWorkSpaceFile:(NXFileBase *)workSpaceFile;
@property(nonatomic, copy)deleteWorkSpaceFileCompletion deleteWorkSpaceFileCompletion;
@end


