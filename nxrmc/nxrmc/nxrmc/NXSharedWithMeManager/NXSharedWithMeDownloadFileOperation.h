//
//  NXSharedWithMeDownloadFileOperation.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 12/06/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXWebFileDownloadOperation.h"

@class NXSharedWithMeFile;
typedef void(^sharedWithMeDownloadFileCompletion)(NXSharedWithMeFile *file,NSError *error);

@interface NXSharedWithMeDownloadFileOperation : NXOperationBase<NXWebFileDownloadOperation>

@property(nonatomic,strong) NXSharedWithMeFile *file;
@property(nonatomic,assign) BOOL forViewer;
@property(nonatomic, strong) NSProgress *downloadProgress;

@property(nonatomic, copy) sharedWithMeDownloadFileCompletion sharedWithMeDownloadFileCompletion;

-(instancetype)initWithSharedWithMeFile:(NXSharedWithMeFile *)file size:(NSUInteger)size forViewer:(BOOL)forViewer;

@end
