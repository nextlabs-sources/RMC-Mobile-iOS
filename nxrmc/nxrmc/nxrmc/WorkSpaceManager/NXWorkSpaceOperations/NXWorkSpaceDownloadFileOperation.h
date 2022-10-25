//
//  NXWorkSpaceDownloadFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXWebFileDownloadOperation.h"
NS_ASSUME_NONNULL_BEGIN
@class NXWorkSpaceFile;
@interface NXWorkSpaceDownloadFileOperation : NXOperationBase<NXWebFileDownloadOperation>
@property(nonatomic,strong) NXWorkSpaceFile *file;
@property(nonatomic,assign) NSUInteger startIndex;
@property(nonatomic,assign) NSUInteger length;
@property(nonatomic, strong) NSNumber *downloadType;
@property(nonatomic, strong) NSProgress *downloadProgress;
-(instancetype)initWithWorkSpaceFile:(NXWorkSpaceFile *)file start:(NSUInteger)start length:(NSUInteger )length downloadType:(NSInteger)downloadType;
@end

NS_ASSUME_NONNULL_END
