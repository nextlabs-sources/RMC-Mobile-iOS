//
//  NXWorkSpaceCreateFolderOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXWorkSpaceCreateFolderAPI.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^createWorkSpaceFolderCompletion)(NXFolder *folder,NSError *error);
@interface NXWorkSpaceCreateFolderOperation : NXOperationBase
- (instancetype)initWithWorkSpaceCreateFolderModel:(NXWorkSpaceCreateFolderModel *)model;
@property(nonatomic, copy)createWorkSpaceFolderCompletion createWorkSpaceFolderCompletion;
@end

NS_ASSUME_NONNULL_END
