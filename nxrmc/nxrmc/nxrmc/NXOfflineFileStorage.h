//
//  NXOfflineFileStorage.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOfflineFile.h"
#import "NXSharedWithMeFile.h"
#import "NXWorkSpaceItem.h"


@class NXMyVaultFileItem, NXProjectFileItem;
@class NXMyVaultFile,NXProjectFile,NXSharedWithProjectFileItem,NXSharedWithProjectFile;

@interface NXOfflineFileStorage : NSObject

#pragma - mark - INSERT
+ (void)insertNewOfflineFileItem:(NXOfflineFile *)fileItem;
+ (void)insertNewOfflineFileItems:(NSArray *)fileItemsArray;

#pragma - mark - UPDATE
+ (void)updateOfflineFileItem:(NXOfflineFile *)fileItem;
+ (void)updateOfflineItems:(NXOfflineFile *)fileItemsArray;

#pragma - mark - DELETE
+ (void)deleteOfflineFileItemWithKey:(NSString *)fileKey;
+ (void)deleteOfflineFileItem:(NXOfflineFile *)offlineFile;
+ (void)deleteOfflineFileItems:(NSArray *)fileItemsArray;

#pragma - mark - FETCH
+ (NXOfflineFile *)getOfflineFileItem:(NXFileBase *)fileItem;
+(NXFileState)getOfflineFileState:(NXFileBase *)fileItem;
+ (NSArray *)allOfflineFileItems;
+ (NSMutableArray *)queryAllOfflineFilesInProject:(NSNumber *)projectId;
+ (NSArray *)allOfflineFileListFromMyVaultOrSharedWithMe;
+ (NSArray *)allOfflineFileListFromWorkSpace;
+ (NSArray *)allOfflineFileListFromMyVault;
+ (NSArray *)allOfflineFileListFromSharedWithMe;
+(NXProjectFile *)getProjectFilePartner:(NXOfflineFile *)offlineFile;
+(NXMyVaultFile *)getMyVaultFilePartner:(NXOfflineFile *)offlineFile;
+(NXSharedWithMeFile *)getSharedWithMeFilePartner:(NXOfflineFile *)offlineFile;
+(NXWorkSpaceFile *)getWorkSpaceFilePartner:(NXOfflineFile *)offlineFile;
+(NXSharedWithProjectFile *)getShareWithProjectFilePartner:(NXOfflineFile *)offlineFile;
+(BOOL)hasConvertFailedOfflineFile;

@end
