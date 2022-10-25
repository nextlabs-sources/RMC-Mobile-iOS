//
//  NXMyVaultGetFileListOperation.h
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMyVaultFile.h"
#import "NXMyVaultListParModel.h"

typedef void(^getFileListInMyVaultFolderOperationCompletion)(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error);
@interface NXGetFileListInMyVaultFolderOperation : NSOperation
- (instancetype)initWithParentFolder:(NXFileBase *)parentFolder filterModel:(NXMyVaultListParModel *)filterModel;
@property(nonatomic, copy)getFileListInMyVaultFolderOperationCompletion completion;
@end
