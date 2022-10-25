//
//  NXUploadFileToMyVaultFolderOperation.h
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMyVaultFile.h"

typedef void(^uploadFileToMyVaultFolderCompletion)(NXMyVaultFile *uploadedFile, NXFileBase *parentFolder, NSError *error);
@interface NXUploadFileToMyVaultFolderOperation : NSOperation

- (instancetype)initWithParentFolder:(NXFileBase *)destFolder fileName:(NSString *)fileName fileItem:(NXFileBase *)fileItem fileData:(NSData *)fileData;
@property(nonatomic, copy)uploadFileToMyVaultFolderCompletion completion;
@property(nonatomic, strong)NSProgress *progress;
@end
