//
//  NXWebFileDownloadOperation.h
//  nxrmc
//
//  Created by EShi on 2/24/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

typedef void(^NXWebFileDownloadOperationCompletionBlock)(NXFileBase *fileBase, NSData *fileData, NSError *error);
@protocol NXWebFileDownloadOperation <NSObject>
@required
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion;
- (void)cancelDownload;
@end
