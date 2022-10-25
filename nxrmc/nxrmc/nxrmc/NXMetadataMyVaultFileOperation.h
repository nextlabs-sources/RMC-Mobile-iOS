//
//  NXMetadataMyVaultFileOperation.h
//  nxrmc
//
//  Created by nextlabs on 1/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMyVaultFile.h"

typedef void(^MetaDataMyVaultCompletion)(NXMyVaultFile *file, NSError *error);

@interface NXMetadataMyVaultFileOperation : NSOperation

@property(nonatomic, copy) MetaDataMyVaultCompletion completion;
- (instancetype)initWithFile:(NXMyVaultFile *)file;

@end
