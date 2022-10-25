//
//  NXSharedWithProjectFileDownloadOperation.h
//  nxrmc
//
//  Created by 时滕 on 2020/1/10.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXWebFileDownloadOperation.h"

@class NXSharedWithProjectFile;
typedef void(^sharedWithProjectDownloadFileCompletion)(NXSharedWithProjectFile *file, NSError *error);

@interface NXSharedWithProjectFileDownloadOperation : NXOperationBase<NXWebFileDownloadOperation>
@property(nonatomic,strong) NXSharedWithProjectFile *file;
@property(nonatomic,assign) BOOL forViewer;
@property(nonatomic, strong) NSProgress *downloadProgress;

@property(nonatomic, copy) sharedWithProjectDownloadFileCompletion sharedWithProjectDownloadFileCompletion;

-(instancetype)initWithSharedWithProjectFile:(NXSharedWithProjectFile *)file size:(NSUInteger)size forViewer:(BOOL)forViewer;
@end

