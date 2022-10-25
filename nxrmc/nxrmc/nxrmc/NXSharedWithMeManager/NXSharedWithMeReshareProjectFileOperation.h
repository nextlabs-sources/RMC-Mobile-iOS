//
//  NXSharedWithMeReshareProjectFileOperation.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSharedWithMeReshareProjectFileAPI.h"
#import "NXOperationBase.h"

@class NXSharedWithMeFile;

NS_ASSUME_NONNULL_BEGIN

typedef void(^finishReshareProjectFileCompletion)(NXSharedWithProjectFile *originalFile,NXSharedWithProjectFile *freshFile,NXSharedWithMeReshareProjectFileResponseModel *responseModel,NSError *error);

@interface NXSharedWithMeReshareProjectFileOperation : NXOperationBase
- (instancetype)initWithSharedWithProjectFile:(NXSharedWithProjectFile *)sharedWithProjectFile withReceivers:(NXSharedWithMeReshareProjectFileRequestModel *)receiverModel;
@property (nonatomic ,copy) finishReshareProjectFileCompletion finishReshareProjectFileCompletion;
@end

NS_ASSUME_NONNULL_END


