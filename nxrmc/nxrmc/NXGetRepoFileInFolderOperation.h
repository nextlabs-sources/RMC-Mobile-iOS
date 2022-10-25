//
//  NXGetRepoFileInFolderOperation.h
//  nxrmc
//
//  Created by EShi on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFolder.h"
#import "NXRepositoryModel.h"
#import "NXOperationBase.h"

typedef void(^getRepoFileInFolderCompletion)(NSArray *fileList, NXFileBase *folder, NXRepositoryModel* repo, NSError *error);
@interface NXGetRepoFileInFolderOperation : NSOperation
-(instancetype) initWithParentFolder:(NXFileBase *) parentFolder repository:(NXRepositoryModel *)repo;

@property(nonatomic, copy) getRepoFileInFolderCompletion getFileCompletion;

@end
