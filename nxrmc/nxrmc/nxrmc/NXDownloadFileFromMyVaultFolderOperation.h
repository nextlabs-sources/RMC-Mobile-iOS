//
//  NXDownloadFileFromMyVaultFolderOperation.h
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMyVaultFile.h"
#import "NXWebFileDownloadOperation.h"

typedef void(^downloadFileFromMyVaultFolderCompletion)(NXMyVaultFile* destFile, NSString *fileName, NSData *fileData, NSError *error);

@interface NXDownloadFileFromMyVaultFolderOperation : NSOperation<NXWebFileDownloadOperation>
- (instancetype)initWithFile:(NXMyVaultFile *)file size:(NSUInteger)size downloadType:(NSInteger)downloadType;
@property(nonatomic, copy) downloadFileFromMyVaultFolderCompletion completion;
@property(nonatomic, strong) NSProgress *downloadProgress;
@end
