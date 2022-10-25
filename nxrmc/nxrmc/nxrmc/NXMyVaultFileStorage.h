//
//  NXMyVaultFileStorage.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 23/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMyVaultFile.h"
#import "NXMyVaultListParModel.h"
@class NXMyVaultFileItem;

@interface NXMyVaultFileStorage : NSObject

#pragma - mark - INSERT
+ (void)insertNewMyVaultFileItem:(NXMyVaultFile *)myVaultFile;
+ (void)insertMyVaultFileItems:(NSArray *)myVaultFileItems;

#pragma - mark - UPDATE
+ (void)updateMyVaultFileItemInStorage:(NXMyVaultFile *)myVaultFile;
+ (void)updateMyVaultFileItemsInStorage:(NSArray *)myVaultFileItems;
+ (void)updateMyVaultFileItemMetadataInStorage:(NXMyVaultFile *)myVaultFile;

+ (void)updateMyVaultFileRevokedStatus:(NXMyVaultFile *)myVaultFile;
+ (void)updateMyVaultFileSharedStatus:(NXMyVaultFile *)myVaultFile;

#pragma - mark - DELETE
// just mark as deleted ,do not delete in coredata in fact
+ (void)deleteMyVaultFileItemInStorage:(NXMyVaultFile *)myVaultFile;
+ (void)deleteMyVaultFileItemsInStorage:(NSArray *)myVaultFileItems;

#pragma - mark - FETCH
+ (NSArray *)getAllMyVaultFiles;
+ (NSUInteger)getAllMyVaultFilesCount;
+ (NSArray *)getMyVaultFilesForShareByMe;
+ (NSArray *)getAllMyVaultFilesWithFilterModel:(NXMyVaultListParModel *)model;

#pragma - mark - CONVERT METHOD
+ (NXMyVaultFile *)convertStorageDataToMyVaultFile:(NXMyVaultFileItem *)storageMyVaultFileItem;

#pragma - mark - MARK/UNMARK FAVORITE METHOD
+ (void)markFavFileItem:(NXMyVaultFile *)fileItem;
+ (void)unmarkFavFileItem:(NXMyVaultFile *)fileItem;


@end
