//
//  NXSharedWithMeFileStorage.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/10/11.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NXSharedWithMeFile;
@class NXShareWithMeFileItem;

@interface NXSharedWithMeFileStorage : NSObject

#pragma - mark - INSERT
+ (void)insertNewSharedWithMeFileItem:(NXSharedWithMeFile *)sharedWithMeFile;
+ (void)insertSharedWithMeFileItems:(NSArray *)sharedWithMeFileItems;

#pragma - mark - UPDATE
+ (void)updateSharedWithMeFileItemInStorage:(NXSharedWithMeFile *)sharedWithMeFile;
+ (void)updateSharedWithMeFileItemsInStorage:(NSArray *)sharedWithMeFileItems;

#pragma - mark - DELETE
+ (void)deleteSharedWithMeFileItemInStorage:(NXSharedWithMeFile *)sharedWithMeFile;
+ (void)deleteSharedWithMeFileItemsInStorage:(NSArray *)sharedWithMeFileItems;
+ (void)deleteSharedWithMeFileItemsByDuidInStorage:(NSMutableSet *)sharedWithMeFileItemsDuidArray;

#pragma - mark - FETCH
+ (NXSharedWithMeFile *)getSharedWithMeFileByFileKey:(NSString *)fileKey;
+ (NSArray *)getAllSharedWithMeFiles;

#pragma - mark - CONVERT METHOD
+ (NXSharedWithMeFile *)convertStorageDataToSharedWithMeFile:(NXShareWithMeFileItem *)storageSharedWithMeFileItem;

@end


