//
//  NXFavFileStorage.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 23/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

@class NXMyVaultFileItem, NXRepoFileItem;

@interface NXFavFileStorage : NSObject

#pragma - mark - INSERT
+ (void)insertNewFavFileItem:(NXFileBase *)fileItem;
+ (void)insertNewFavFileItems:(NSArray *)fileItemsArray;

#pragma - mark - UPDATE
+ (void)updateFavFileItem:(NXFileBase *)fileItem;
+ (void)updateFavFileItems:(NXFileBase *)fileItemsArray;

#pragma - mark - DELETE
+ (void)deleteFavFileItem:(NXFileBase *)fileItem;
+ (void)deleteFavFileItems:(NSArray *)fileItemsArray;

#pragma - mark - FETCH
+ (NXFileBase *)getFavFileItem:(NXFileBase *)fileItem;
+ (NSArray *)allFavFileItems;
+ (NSArray *)allFavFileItemsInMyDrive;
+(NSArray *)allFavFileItemsInMyVault;

@end
