//
//  NXCreateFolderInRepoOperation.h
//  nxrmc
//
//  Created by EShi on 12/27/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXRepositoryModel.h"

typedef void(^createFolderInRepoCompletion)(NXFileBase *fileItem, NXRepositoryModel* repo, NSError *error);
@interface NXCreateFolderInRepoOperation : NSOperation
- (instancetype) initWithFolderName:(NSString *)folderName underFolder:(NXFileBase *)parentFolder repository:(NXRepositoryModel *)repo;
@property(nonatomic, copy) createFolderInRepoCompletion createFolderComp;
@end
