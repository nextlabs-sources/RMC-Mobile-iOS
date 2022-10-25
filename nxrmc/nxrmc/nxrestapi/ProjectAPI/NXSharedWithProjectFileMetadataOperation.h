//
//  NXSharedWithProjectFileMetadataOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/1.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

NS_ASSUME_NONNULL_BEGIN
@class NXSharedWithProjectFile;
typedef void(^getSharedWithProjectFileMetadataCompletion)(NXSharedWithProjectFile *fileItem,NSError *error);
@interface NXSharedWithProjectFileMetadataOperation : NXOperationBase
-(instancetype)initWithSharedWithProjectFile:(NXSharedWithProjectFile *)fileItem;
@property(nonatomic, copy) getSharedWithProjectFileMetadataCompletion getSharedWithProjectFileMetadataCompletion;
@end

NS_ASSUME_NONNULL_END
