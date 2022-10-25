//
//  NXWebFileDownloadDefaultOperation.h
//  nxrmc
//
//  Created by 时滕 on 2019/12/5.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXWebFileDownloadOperation.h"
NS_ASSUME_NONNULL_BEGIN

@interface NXWebFileDownloadDefaultOperation : NXOperationBase<NXWebFileDownloadOperation>
@property(nonatomic,strong) NXFileBase *file;
@property(nonatomic, copy) NXWebFileDownloadOperationCompletionBlock webFileDownloadCompletion;
@property(nonatomic, strong) NSProgress *downloadProgress;
@end

NS_ASSUME_NONNULL_END
