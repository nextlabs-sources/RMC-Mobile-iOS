//
//  NXDeleteFileFromMyVaultFolderOperation.h
//  nxrmc
//
//  Created by nextlabs on 1/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMyVaultFile.h"

typedef void(^DeleteFileFromMyVaultFolderCompletion)(NXMyVaultFile *file, NSError *error);

@interface NXDeleteFileFromMyVaultFolderOperation : NSOperation

- (instancetype)initWithFile:(NXMyVaultFile *)file;
@property(nonatomic, copy) DeleteFileFromMyVaultFolderCompletion completion;

@end
