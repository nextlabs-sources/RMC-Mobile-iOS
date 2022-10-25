//
//  NXDownloadRepoFileOperation.h
//  nxrmc
//
//  Created by EShi on 1/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFile.h"
#import "NXFolder.h"
#import "NXRepositoryModel.h"
#import "NXWebFileDownloadOperation.h"

typedef void(^NXDownloadRepoFileCompletion)(NXFileBase *file, NSError *error);
@interface NXDownloadRepoFileOperation : NSOperation<NXWebFileDownloadOperation>
- (instancetype) initWithDestFile:(NXFileBase *) destFile repository:(NXRepositoryModel *)repo;
- (instancetype) initWithDestFile:(NXFileBase *) destFile toSize:(NSUInteger)size repository:(NXRepositoryModel *)repo;
- (instancetype) initWithDestFile:(NXFileBase *) destFile toSize:(NSUInteger)size repository:(NXRepositoryModel *)repo downType:(NSInteger)downType;
@property(nonatomic, copy) NXDownloadRepoFileCompletion downloadFileComp;
@property(nonatomic, strong) NSProgress *downloadProgress;
@end
