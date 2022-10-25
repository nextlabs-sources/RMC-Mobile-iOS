//
//  NXProjectDownloadFileOperation.h
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"
#import "NXProjectFile.h"
#import "NXWebFileDownloadOperation.h"

typedef void(^projectDownloadFileCompletion)(NXProjectFile *file,NSError *error);

@interface NXProjectDownloadFileOperation : NXOperationBase<NXWebFileDownloadOperation>

@property(nonatomic,strong) NXProjectModel *prjectModel;
@property(nonatomic,strong) NXProjectFile *file;
@property(nonatomic,assign) NSUInteger startIndex;
@property(nonatomic,assign) NSUInteger length;
@property(nonatomic, strong) NSNumber *downloadType;
@property(nonatomic, strong) NSProgress *downloadProgress;

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel file:(NXProjectFile *)file start:(NSUInteger)start length:(NSUInteger )length downloadType:(NSInteger)downloadType;

@end
