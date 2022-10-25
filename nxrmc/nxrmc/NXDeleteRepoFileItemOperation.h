//
//  NXDeleteRepoFileItemOperation.h
//  nxrmc
//
//  Created by EShi on 12/27/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXRepositoryModel.h"

typedef void(^deleteRepoFileInFolderCompletion)(NXFileBase *fileItem, NXRepositoryModel* repo, NSError *error);
@interface NXDeleteRepoFileItemOperation : NSOperation
-(instancetype) initWithDeleteFileItem:(NXFileBase *) fileItem repository:(NXRepositoryModel *)repo;
@property(nonatomic, copy) deleteRepoFileInFolderCompletion delFileCompletion;
@end
