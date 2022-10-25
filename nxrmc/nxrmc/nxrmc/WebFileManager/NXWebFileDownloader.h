//
//  NXWebFileDownloader.h
//  nxrmc
//
//  Created by EShi on 2/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

typedef void(^NXWebFileDownloaderProgressBlock)(int64_t receivedSize, int64_t totalCount, double fractionCompleted);
typedef void(^NXWebFileDownloaderCompletedBlock)(NXFileBase *fileItem, NSData *fileData, NSError *error);


@interface NXWebFileDownloader : NSObject
+ (instancetype)sharedInstance;
- (void)downloadFile:(NXFileBase *)fileItem toSize:(NSUInteger)size withProgressBlock:(NXWebFileDownloaderProgressBlock)progressBlock forKey:(NSString *)fileKey downloadType:(NSInteger)downloadType completion:(NXWebFileDownloaderCompletedBlock)completedBlock;
- (void)cancelDownloadOperation:(NSString *)downloadOptIdentify;
@end
