//
//  NXRepoFileStorage.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

@interface NXRepoFileStorage : NSObject
+ (void)addFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder;
+ (void)addFileItem:(NXFileBase *)fileItem underFolder:(NXFileBase *)parentFolder;

+ (void)deleteFileItem:(NXFileBase *)fileItem;

+ (void)updateFileItem:(NXFileBase *)fileItem;
+ (void)updateFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder;
+ (void)updateFileItemSize:(NXFileBase *)fileItem;

+ (NXFileBase *)getParentOfFileItem:(NXFileBase *)fileItem;
+ (NSArray *)getFileItemsCopyUnderFolder:(NXFileBase *)parentFolder;

+ (void)markFavFileItem:(NXFileBase *)fileItem;
+ (void)unmarkFavFileItem:(NXFileBase *)fileItem;
+ (NSUInteger)allRepoFilesCount;
+ (NSUInteger)allMyDriveFilesCount;

@end
