//
//  NXWorkSpaceGetFileMetadataOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
@class NXWorkSpaceFile;
typedef void(^getWorkSpaceFileMetadataCompletion)(NXWorkSpaceFile *workSpaceFile,NSError *error);
@interface NXWorkSpaceGetFileMetadataOperation : NXOperationBase
- (instancetype)initWithWorkSpaceFile:(NXWorkSpaceFile *)workSpaceFile;
@property(nonatomic, copy)getWorkSpaceFileMetadataCompletion getWorkSpaceFileMetadataCompletion;
@end

