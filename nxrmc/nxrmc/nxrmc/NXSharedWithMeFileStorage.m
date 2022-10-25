//
//  NXSharedWithMeFileStorage.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/10/11.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXSharedWithMeFileStorage.h"
#import "NXCommonUtils.h"
#import "NXLoginUser.h"
#import "MagicalRecord.h"
#import "NXShareWithMeFileItem+CoreDataClass.h"
#import "NXSharedWithMeFile.h"
#import "NXOfflineFileItem+CoreDataClass.h"

@implementation NXSharedWithMeFileStorage

#pragma -mark -INSERT
+ (void)insertNewSharedWithMeFileItem:(NXSharedWithMeFile *)shareWithMeFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSString *fileKey = [NXCommonUtils fileKeyForFile:shareWithMeFile];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXShareWithMeFileItem *sharedWithFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        
        if (!sharedWithFileItem) {
            sharedWithFileItem = [NXShareWithMeFileItem MR_createEntityInContext:localContext];
        }
        
        sharedWithFileItem.fileKey = fileKey;
        sharedWithFileItem.duid = shareWithMeFile.duid;
        sharedWithFileItem.name = shareWithMeFile.name;
        sharedWithFileItem.fileType = shareWithMeFile.fileType;
        sharedWithFileItem.size = [NSNumber numberWithLongLong:shareWithMeFile.size];
        sharedWithFileItem.shareDate = [NSDate dateWithTimeIntervalSince1970: shareWithMeFile.sharedDate];
        sharedWithFileItem.shareBy = shareWithMeFile.sharedBy;
        sharedWithFileItem.transactionId = shareWithMeFile.transactionId;
        sharedWithFileItem.transactionCode = shareWithMeFile.transactionCode;
        sharedWithFileItem.sharedLink = shareWithMeFile.sharedLink;
        sharedWithFileItem.rights = [NSJSONSerialization dataWithJSONObject:shareWithMeFile.rights options:NSJSONWritingPrettyPrinted error:nil];
        sharedWithFileItem.comment = shareWithMeFile.reshareComment;
        sharedWithFileItem.isOwner = [NSNumber numberWithBool:shareWithMeFile.isOwner];
        sharedWithFileItem.lastModified = shareWithMeFile.lastModified;
        
        // check if current file is off
        NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        if (offlineFile) {
            offlineFile.shareWithMeFilePartner = sharedWithFileItem;
            sharedWithFileItem.offlineFilePartner = offlineFile;
        }
    }];
}

+ (void)insertSharedWithMeFileItems:(NSArray *)sharedWithMeFileItems
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        for (NXSharedWithMeFile *shareWithMeFile in sharedWithMeFileItems) {
            NSString *fileKey = [NXCommonUtils fileKeyForFile:shareWithMeFile];
            
            NXShareWithMeFileItem *sharedWithFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
            
            if (!sharedWithFileItem) {
                sharedWithFileItem = [NXShareWithMeFileItem MR_createEntityInContext:localContext];
            }
            
            sharedWithFileItem.fileKey = fileKey;
            sharedWithFileItem.duid = shareWithMeFile.duid;
            sharedWithFileItem.name = shareWithMeFile.name;
            sharedWithFileItem.fileType = shareWithMeFile.fileType;
            sharedWithFileItem.size = [NSNumber numberWithLongLong:shareWithMeFile.size];
            sharedWithFileItem.shareDate = [NSDate dateWithTimeIntervalSince1970:shareWithMeFile.sharedDate];
            sharedWithFileItem.shareBy = shareWithMeFile.sharedBy;
            sharedWithFileItem.transactionId = shareWithMeFile.transactionId;
            sharedWithFileItem.transactionCode = shareWithMeFile.transactionCode;
            sharedWithFileItem.sharedLink = shareWithMeFile.sharedLink;
            sharedWithFileItem.rights = [NSKeyedArchiver archivedDataWithRootObject:shareWithMeFile.rights];
            sharedWithFileItem.comment = shareWithMeFile.reshareComment;
            sharedWithFileItem.isOwner = [NSNumber numberWithBool:shareWithMeFile.isOwner];
            sharedWithFileItem.lastModified = shareWithMeFile.lastModified;
            
            // check if current file is off
            NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
            if (offlineFile) {
                offlineFile.shareWithMeFilePartner = sharedWithFileItem;
                sharedWithFileItem.offlineFilePartner = offlineFile;
            }
        }
    }];
}

#pragma -mark - UPDATE
+ (void)updateSharedWithMeFileItemInStorage:(NXSharedWithMeFile *)sharedWithMeFile
{
    
}
+ (void)updateSharedWithMeFileItemsInStorage:(NSArray *)sharedWithMeFileItems
{
    
}

#pragma -mark - DELETE
+ (void)deleteSharedWithMeFileItemInStorage:(NXSharedWithMeFile *)sharedWithMeFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:sharedWithMeFile]] inContext:localContext];
        
        if (sharedWithMeFileItem) {
            [sharedWithMeFileItem MR_deleteEntityInContext:localContext];
        }
    }];
}

+ (void)deleteSharedWithMeFileItemsInStorage:(NSArray *)sharedWithMeFileItems
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    for (NXSharedWithMeFile *item in sharedWithMeFileItems) {
        [NXSharedWithMeFileStorage deleteSharedWithMeFileItemInStorage:item];
    }
}

+ (void)deleteSharedWithMeFileItemsByDuidInStorage:(NSMutableSet *)sharedWithMeFileItemsDuidArray
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    for (NSString *duid in sharedWithMeFileItemsDuidArray) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            
            NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"duid==%@",duid] inContext:localContext];
            if (sharedWithMeFileItem) {
                [sharedWithMeFileItem MR_deleteEntityInContext:localContext];
            }
        }];
    }
}

#pragma -mark - FETCH
+ (NXSharedWithMeFile *)getSharedWithMeFileByFileKey:(NSString *)fileKey
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
    
    if (sharedWithMeFileItem) {
        return [NXSharedWithMeFileStorage convertStorageDataToSharedWithMeFile:sharedWithMeFileItem];
    }
    return nil;
}

+ (NSArray *)getAllSharedWithMeFiles
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NSMutableArray *sharedWithMeFileArray = [[NSMutableArray alloc] init];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSFetchRequest *request = [NXShareWithMeFileItem MR_createFetchRequest];
        [request setIncludesPropertyValues:YES];
        [request setReturnsObjectsAsFaults:NO];
        [request setIncludesPendingChanges:YES];
        
        NSArray *fetchedObjects = [NXShareWithMeFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
        
        for (NXShareWithMeFileItem *shareWithMeFileItem in fetchedObjects) {
            @autoreleasepool {
                NXSharedWithMeFile *sharedWithMeFile = [self convertStorageDataToSharedWithMeFile:shareWithMeFileItem];
                [sharedWithMeFileArray addObject:sharedWithMeFile];
            }
        }
    }];
   
    return sharedWithMeFileArray;
}

#pragma -mark - CONVERT METHOD
+ (NXSharedWithMeFile *)convertStorageDataToSharedWithMeFile:(NXShareWithMeFileItem *)storageSharedWithMeFileItem
{
    NXSharedWithMeFile *sharedWithMeFile = [[NXSharedWithMeFile alloc] init];
    sharedWithMeFile.duid = storageSharedWithMeFileItem.duid;
    sharedWithMeFile.name = storageSharedWithMeFileItem.name;
    sharedWithMeFile.fileType = storageSharedWithMeFileItem.fileType;
    sharedWithMeFile.size = storageSharedWithMeFileItem.size.longLongValue;
    sharedWithMeFile.sharedDate = [storageSharedWithMeFileItem.shareDate timeIntervalSince1970];
    sharedWithMeFile.sharedBy = storageSharedWithMeFileItem.shareBy;
    sharedWithMeFile.transactionId = storageSharedWithMeFileItem.transactionId;
    sharedWithMeFile.transactionCode = storageSharedWithMeFileItem.transactionCode;
    sharedWithMeFile.rights = [NSKeyedUnarchiver unarchiveObjectWithData:storageSharedWithMeFileItem.rights];
    sharedWithMeFile.comment = storageSharedWithMeFileItem.comment;
    sharedWithMeFile.isOwner = storageSharedWithMeFileItem.isOwner.boolValue;
    sharedWithMeFile.sorceType = NXFileBaseSorceTypeShareWithMe;
    
    sharedWithMeFile.fullServicePath = storageSharedWithMeFileItem.transactionCode;
    sharedWithMeFile.lastModified = storageSharedWithMeFileItem.lastModified;
    if (sharedWithMeFile.lastModified) {
        long long lastModified =  sharedWithMeFile.lastModified.longLongValue/1000;
        sharedWithMeFile.lastModifiedTime = [NSString stringWithFormat:@"%0lld", lastModified];
        sharedWithMeFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:lastModified];
    }else {
        sharedWithMeFile.lastModifiedTime = [NSString stringWithFormat:@"%f",sharedWithMeFile.sharedDate];
        sharedWithMeFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:sharedWithMeFile.sharedDate];
    }
 
    
    if (storageSharedWithMeFileItem.offlineFilePartner) {
        sharedWithMeFile.isOffline = YES;
    }else{
        sharedWithMeFile.isOffline = NO;
    }
    
    return sharedWithMeFile;
}

@end
