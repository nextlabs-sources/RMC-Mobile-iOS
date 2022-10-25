//
//  NXUploadFileToFolderInOperation.h
//  nxrmc
//
//  Created by EShi on 1/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFile.h"
#import "NXFolder.h"
#import "NXRepositoryModel.h"

typedef void(^uploadFileToFolderInRepoCompletion)(NXFileBase *fileItem, NXFileBase *parentFolder, NXRepositoryModel* repo, NSError *error);
@interface NXUploadFileToFolderInRepoOperation : NSOperation
-(instancetype) initWithUploadFile:(NSString *)fileName andIsOverwrite:(BOOL)isOverwrite fromPath:(NSString *)filePath parentFolder:(NXFileBase *) parentFolder repository:(NXRepositoryModel *)repo;
@property(nonatomic, copy) uploadFileToFolderInRepoCompletion uploadFileCompletion;
@property(nonatomic, strong) NSProgress *uploadProgress;
@end
