//
//  NXMyVaultFileSystemTree.h
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMyVaultFile.h"
#import "NXMyVaultListParModel.h"

@class NXMyVaultListParModel;
@class NXLProfile;
@interface NXMyVaultFileSystemTree : NSObject
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile;

-(NSArray *)getFileItemsCopyUnderFolder:(NXMyVaultFile *)parentFolder;
-(NSArray *)getFileItemsCopyUnderFolder:(NXMyVaultFile *)parentFolder filterModel:(NXMyVaultListParModel *)filterModel;

-(void)updateFileItems:(NSArray *)fileItems underFolder:(NXMyVaultFile *)parentFolder;
-(void)updateMyVaultFileItemMetadataInStorage:(NXMyVaultFile *)myVaultFile;
-(void)deleteFileItem:(NXMyVaultFile *)fileItem;
-(void)addFileItem:(NXMyVaultFile *)fileItem underFolder:(NXMyVaultFile *)parentFolder;
@end
