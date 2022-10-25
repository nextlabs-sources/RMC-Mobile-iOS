//
//  NXOfflineFileOperation.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/14.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXOfflineFile.h"
#import "NXClassificationCategory.h"
#import "NXWatermarkWord.h"

typedef void(^NXOfflineFileOperationCompletionBlock)(NXOfflineFile *fileItem,NSError *error);
@protocol NXOfflineFileOperation <NSObject>
@required
- (NSOperation *)operateOfflineFile:(NXOfflineFile *)offlineFile completion:(NXOfflineFileOperationCompletionBlock)completion;
@end
