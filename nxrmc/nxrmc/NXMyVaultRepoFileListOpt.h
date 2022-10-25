//
//  NXMyVaultRepoFileListOpt.h
//  nxrmc
//
//  Created by Eren on 2020/5/14.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXFileBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^getMyVaultRepoFileInFolderCompletion)(NSArray *fileList, NXFileBase *folder, NSError *error);
@interface NXMyVaultRepoFileListOpt : NXOperationBase
-(instancetype) initWithParentFolder:(NXFileBase *) parentFolder shouldeReadCache:(BOOL) shouldReadCache;

@property(nonatomic, copy) getMyVaultRepoFileInFolderCompletion getFileCompletion;
@end

NS_ASSUME_NONNULL_END
