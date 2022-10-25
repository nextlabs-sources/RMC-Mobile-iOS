//
//  NXSharedWithMeReshareFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXShareWithMeReshareResponseModel.h"
@class NXSharedWithMeFile;

typedef void(^finishReshareFileCompletion)(NXSharedWithMeFile *originalFile,NXSharedWithMeFile *freshFile,NXShareWithMeReshareResponseModel *responseModel,NSError *error);

@interface NXSharedWithMeReshareFileOperation : NXOperationBase
- (instancetype)initWithSharedWithMeFile:(NXSharedWithMeFile *)sharedWithMeFile withReceivers:(NSArray *)receiversArray;
@property (nonatomic ,copy) finishReshareFileCompletion finishReshareFileCompletion;
@end
