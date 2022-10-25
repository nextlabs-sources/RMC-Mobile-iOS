//
//  NXMyVaultFileStorage.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 23/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMyVaultFileStorage.h"
#import "MagicalRecord.h"
#import "NXCommonUtils.h"
#import "NXMyVaultFileItem+CoreDataClass.h"
#import "NXFavoriteFile+CoreDataClass.h"
#import "NXOfflineFileItem+CoreDataClass.h"

@implementation NXMyVaultFileStorage

#pragma - mark - INSERT
+ (void)insertNewMyVaultFileItem:(NXMyVaultFile *)myVaultFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSString *fileKey = [NXCommonUtils fileKeyForFile:myVaultFile];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        
        if (!myVaultFileItem) {
            myVaultFileItem = [NXMyVaultFileItem MR_createEntityInContext:localContext];
        }
        myVaultFileItem.fileDisplayPath = myVaultFile.fullPath;
        myVaultFileItem.fileServicePath = myVaultFile.fullServicePath;
        myVaultFileItem.deleted = [NSNumber numberWithBool:myVaultFile.isDeleted];
        myVaultFileItem.duid = myVaultFile.duid;
        myVaultFileItem.fileKey = fileKey;
        myVaultFileItem.fileLink = myVaultFile.fileLink;
        myVaultFileItem.fileName = myVaultFile.name;
        myVaultFileItem.revoked = [NSNumber numberWithBool:myVaultFile.isRevoked];
        myVaultFileItem.shared = [NSNumber numberWithBool:myVaultFile.isShared];
        myVaultFileItem.protectedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.protectedOn.longLongValue];
        myVaultFileItem.sharedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.sharedOn.longLongValue];
        myVaultFileItem.sharedWith = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.sharedWith];
        myVaultFileItem.rights = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.rights];
        myVaultFileItem.recipients = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.recipients];
        myVaultFileItem.size = [NSNumber numberWithLongLong:myVaultFile.size];
        myVaultFileItem.sourceFilePathDisplay = myVaultFile.metaData.sourceFilePathDisplay;
        myVaultFileItem.sourceRepoId = myVaultFile.metaData.sourceRepoId;
        myVaultFileItem.sourceRepoName = myVaultFile.metaData.sourceRepoName;
        myVaultFileItem.sourceRepoType = myVaultFile.metaData.sourceRepoType;
        myVaultFileItem.sourceFilePathId = myVaultFile.metaData.SourceFilePathId;
        
        // check if myVault file is fav
        NXFavoriteFile *favoriteFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        if (favoriteFile) {
            myVaultFileItem.isFavorite = [NSNumber numberWithBool:YES];
            favoriteFile.myVaultPartner = myVaultFileItem;
            favoriteFile.duid = myVaultFile.duid;
            myVaultFileItem.favFilePartner = favoriteFile;
        }
    }];
}

+ (void)insertMyVaultFileItems:(NSArray *)myVaultFileItems
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        for (NXMyVaultFile *myVaultFile in myVaultFileItems) {
            @autoreleasepool {
                NSString *fileKey = [NXCommonUtils fileKeyForFile:myVaultFile];
                NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
                
                if (!myVaultFileItem) {
                    myVaultFileItem = [NXMyVaultFileItem MR_createEntityInContext:localContext];
                }
                
                myVaultFileItem.deleted = [NSNumber numberWithBool:myVaultFile.isDeleted];
                myVaultFileItem.duid = myVaultFile.duid;
                myVaultFileItem.fileKey = fileKey;
                myVaultFileItem.fileName = myVaultFile.name;
                myVaultFileItem.fileServicePath = myVaultFile.fullServicePath;
                myVaultFileItem.fileDisplayPath = myVaultFile.fullPath;
                myVaultFileItem.revoked = [NSNumber numberWithBool:myVaultFile.isRevoked];
                myVaultFileItem.shared = [NSNumber numberWithBool:myVaultFile.isShared];
                myVaultFileItem.size = [NSNumber numberWithLongLong:myVaultFile.size];
                myVaultFileItem.sourceFilePathDisplay = myVaultFile.metaData.sourceFilePathDisplay;
                myVaultFileItem.sourceRepoId = myVaultFile.metaData.sourceRepoId;
                myVaultFileItem.sourceRepoName = myVaultFile.metaData.sourceRepoName;
                myVaultFileItem.sourceRepoType = myVaultFile.metaData.sourceRepoType;
                myVaultFileItem.sourceFilePathId = myVaultFile.metaData.SourceFilePathId;
                
                if (myVaultFile.fileLink.length > 0) {
                    myVaultFileItem.fileLink = myVaultFile.fileLink;
                }
                
                if (myVaultFile.rights.count >= 1) {
                    myVaultFileItem.rights = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.rights];
                }
                if (myVaultFile.sharedWith.count > 0) {
                    myVaultFileItem.sharedWith = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.sharedWith];
                }
                if (myVaultFile.recipients.count > 0) {
                    myVaultFileItem.recipients = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.recipients];
                    
                }
                
                if (myVaultFile.protectedOn != nil) {
                    myVaultFileItem.protectedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.protectedOn.longLongValue];
                }
                
                if (myVaultFile.sharedOn) {
                    myVaultFileItem.sharedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.sharedOn.longLongValue];
                }
                
                // check if myVault file is fav
                NXFavoriteFile *favoriteFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
                if (favoriteFile) {
                    myVaultFileItem.isFavorite = [NSNumber numberWithBool:YES];
                    favoriteFile.myVaultPartner = myVaultFileItem;
                    favoriteFile.duid = myVaultFileItem.duid;
                    myVaultFileItem.favFilePartner = favoriteFile;
                    myVaultFile.isFavorite = YES; // here update outside property
                }
                
                // check if myVault file is off
                NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
                if (offlineFile) {
                    myVaultFileItem.isOffline = [NSNumber numberWithBool:YES];
                    offlineFile.myVaultPartner = myVaultFileItem;
                    myVaultFileItem.offlineFilePartner = offlineFile;
                    myVaultFile.isOffline = YES; // here update outside property
                }
            }
        }
    }];
}

#pragma - mark - UPDATE
+ (void)updateMyVaultFileItemInStorage:(NXMyVaultFile *)myVaultFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSString *fileKey = [NXCommonUtils fileKeyForFile:myVaultFile];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        
        if (!myVaultFileItem) {
            myVaultFileItem = [NXMyVaultFileItem MR_createEntityInContext:localContext];
        }
        
        myVaultFileItem.deleted = [NSNumber numberWithBool:myVaultFile.isDeleted];
        myVaultFileItem.duid = myVaultFile.duid;
        myVaultFileItem.fileKey = fileKey;
        myVaultFileItem.fileName = myVaultFile.name;
        myVaultFileItem.fileServicePath = myVaultFile.fullServicePath;
        myVaultFileItem.fileDisplayPath = myVaultFile.fullPath;
        myVaultFileItem.revoked = [NSNumber numberWithBool:myVaultFile.isRevoked];
        myVaultFileItem.shared = [NSNumber numberWithBool:myVaultFile.isShared];
        myVaultFileItem.size = [NSNumber numberWithLongLong:myVaultFile.size];
        myVaultFileItem.sourceFilePathDisplay = myVaultFile.metaData.sourceFilePathDisplay;
        myVaultFileItem.sourceRepoId = myVaultFile.metaData.sourceRepoId;
        myVaultFileItem.sourceRepoName = myVaultFile.metaData.sourceRepoName;
        myVaultFileItem.sourceRepoType = myVaultFile.metaData.sourceRepoType;
        myVaultFileItem.sourceFilePathId = myVaultFile.metaData.SourceFilePathId;
       
        if (myVaultFile.fileLink.length > 0) {
            myVaultFileItem.fileLink = myVaultFile.fileLink;
        }
        if (myVaultFile.sharedWith.count > 0) {
            myVaultFileItem.sharedWith = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.sharedWith];
        }
        if (myVaultFile.rights.count >= 1) {
            myVaultFileItem.rights = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.rights];
        }
        
        if (myVaultFile.recipients.count > 0) {
            myVaultFileItem.recipients = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.recipients];
            
        }
        
        if (myVaultFile.protectedOn != nil) {
            myVaultFileItem.protectedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.protectedOn.longLongValue];
        }
        
        if (myVaultFile.sharedOn) {
            myVaultFileItem.sharedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.sharedOn.longLongValue];
        }
        
        // check if myVault file is fav
        NXFavoriteFile *favoriteFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        if (favoriteFile) {
            if (myVaultFile.isDeleted == YES) {
                [favoriteFile MR_deleteEntityInContext:localContext];
            }else{
                myVaultFileItem.isFavorite = [NSNumber numberWithBool:YES];
                favoriteFile.myVaultPartner = myVaultFileItem;
                favoriteFile.duid = myVaultFileItem.duid;
                myVaultFileItem.favFilePartner = favoriteFile;
                myVaultFile.isFavorite = YES; // here update outside property
            }
        }
        
        // check if myVault file is off
        NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        if (offlineFile) {
            myVaultFileItem.isOffline = [NSNumber numberWithBool:YES];
            offlineFile.myVaultPartner = myVaultFileItem;
            myVaultFileItem.offlineFilePartner = offlineFile;
            myVaultFile.isOffline = YES; // here update outside property
        }
    }];
}

+ (void)updateMyVaultFileItemsInStorage:(NSArray *)myVaultFileItems
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSMutableArray *newList = [[NSMutableArray alloc] initWithArray:myVaultFileItems];
    NSMutableArray *tempDeleteChildren = [[NSMutableArray alloc] init];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NXMyVaultFileItem *myVaultFileItem in [NXMyVaultFileItem MR_findAllInContext:localContext]) {
            BOOL isFind = NO;
            for (NXMyVaultFile *myVaultFile in myVaultFileItems) {
                if ([[NXCommonUtils fileKeyForFile:myVaultFile] isEqualToString:myVaultFileItem.fileKey]) {
                    isFind = YES;
                    [newList removeObject:myVaultFile];
                    [self updateMyVaultFileItem:myVaultFileItem withMyVaultFile:myVaultFile inContext:localContext];
                }
            }
            if (!isFind) {
                [tempDeleteChildren addObject:myVaultFileItem];
            }
        }
        for (NXMyVaultFile *myVaultFile in newList) {
            NXMyVaultFileItem *newMyVaultFileItem = [NXMyVaultFileItem MR_createEntityInContext:localContext];
            [self updateMyVaultFileItem:newMyVaultFileItem withMyVaultFile:myVaultFile inContext:localContext];
        }
        for (NXMyVaultFileItem *myVaultFileItem in tempDeleteChildren) {
            NXFavoriteFile *favoriteFileItem = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", myVaultFileItem.fileKey] inContext:localContext];
            if (favoriteFileItem) {
                [favoriteFileItem MR_deleteEntityInContext:localContext];
            }
            
            NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", myVaultFileItem.fileKey] inContext:localContext];
            if (offlineFileItem) {
                [offlineFileItem MR_deleteEntityInContext:localContext];
            }
            
            [NXMyVaultFileItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", myVaultFileItem.fileKey] inContext:localContext];
            
        }
    }];
}

+ (void)updateMyVaultFileItem:(NXMyVaultFileItem *)myVaultFileItem withMyVaultFile:(NXMyVaultFile *)myVaultFile inContext:(NSManagedObjectContext *) localContext{
    NSString *fileKey = [NXCommonUtils fileKeyForFile:myVaultFile];
    myVaultFileItem.deleted = [NSNumber numberWithBool:myVaultFile.isDeleted];
    myVaultFileItem.duid = myVaultFile.duid;
    myVaultFileItem.fileKey = fileKey;
    myVaultFileItem.fileName = myVaultFile.name;
    myVaultFileItem.fileServicePath = myVaultFile.fullServicePath;
    myVaultFileItem.fileDisplayPath = myVaultFile.fullPath;
    myVaultFileItem.revoked = [NSNumber numberWithBool:myVaultFile.isRevoked];
    myVaultFileItem.shared = [NSNumber numberWithBool:myVaultFile.isShared];
    myVaultFileItem.size = [NSNumber numberWithLongLong:myVaultFile.size];
    myVaultFileItem.sourceFilePathDisplay = myVaultFile.metaData.sourceFilePathDisplay;
    myVaultFileItem.sourceRepoId = myVaultFile.metaData.sourceRepoId;
    myVaultFileItem.sourceRepoName = myVaultFile.metaData.sourceRepoName;
    myVaultFileItem.sourceRepoType = myVaultFile.metaData.sourceRepoType;
    myVaultFileItem.sourceFilePathId = myVaultFile.metaData.SourceFilePathId;
    if (myVaultFile.sharedWith.count > 0) {
        myVaultFileItem.sharedWith = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.sharedWith];
    }else {
        myVaultFileItem.sharedWith = nil;
    }
    
    if (myVaultFile.fileLink.length > 0) {
        myVaultFileItem.fileLink = myVaultFile.fileLink;
    }
    
    if (myVaultFile.rights.count >= 1) {
        myVaultFileItem.rights = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.rights];
    }else {
        myVaultFileItem.rights = nil;
    }
    
    if (myVaultFile.recipients.count > 0) {
        myVaultFileItem.recipients = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.recipients];
    }else {
        myVaultFileItem.recipients = nil;
    }
    
    if (myVaultFile.protectedOn != nil) {
        myVaultFileItem.protectedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.protectedOn.longLongValue];
    }
    
    if (myVaultFile.sharedOn) {
        myVaultFileItem.sharedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.sharedOn.longLongValue];
    }
    
    // check if myVault file is fav
    NXFavoriteFile *favoriteFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
    if (favoriteFile) {
        if (myVaultFile.isDeleted == YES) {
            [favoriteFile MR_deleteEntityInContext:localContext];
        }else{
            myVaultFileItem.isFavorite = [NSNumber numberWithBool:YES];
            favoriteFile.myVaultPartner = myVaultFileItem;
            favoriteFile.duid = myVaultFileItem.duid;
            myVaultFileItem.favFilePartner = favoriteFile;
            myVaultFile.isFavorite = YES; // here update outside property
        }
    }
    
    // check if myVault file is off
    NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
    if (offlineFile) {
        myVaultFileItem.isOffline = [NSNumber numberWithBool:YES];
        offlineFile.myVaultPartner = myVaultFileItem;
        myVaultFileItem.offlineFilePartner = offlineFile;
        myVaultFile.isOffline = YES; // here update outside property
    }
}

+ (void)updateMyVaultFileItemMetadataInStorage:(NXMyVaultFile *)myVaultFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:myVaultFile]] inContext:localContext];
        if (myVaultFileItem) {
            myVaultFileItem.rights = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.rights];
            myVaultFileItem.fileLink = myVaultFile.fileLink;
            myVaultFileItem.sharedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.sharedOn.longLongValue];
            myVaultFileItem.protectedOn = [NSDate dateWithTimeIntervalSince1970:myVaultFile.protectedOn.longLongValue];
            myVaultFileItem.recipients = [NSKeyedArchiver archivedDataWithRootObject:myVaultFile.recipients];
        }
    }];
}

+ (void)updateMyVaultFileRevokedStatus:(NXMyVaultFile *)myVaultFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:myVaultFile]] inContext:localContext];
        if (myVaultFileItem) {
            myVaultFileItem.revoked = [NSNumber numberWithBool:YES];
        }
    }];
}

+ (void)updateMyVaultFileSharedStatus:(NXMyVaultFile *)myVaultFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:myVaultFile]] inContext:localContext];
        if (myVaultFileItem) {
            myVaultFileItem.shared = [NSNumber numberWithBool:YES];
        }
    }];
}

#pragma - mark - DELETE
// just mark as deleted ,do not delete in coredata in fact
+ (void)deleteMyVaultFileItemInStorage:(NXMyVaultFile *)myVaultFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:myVaultFile]] inContext:localContext];
        myVaultFileItem.deleted = [NSNumber numberWithBool:YES];
        
        NXFavoriteFile *favoriteFileItem = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:myVaultFile]] inContext:localContext];
        if (favoriteFileItem) {
            [favoriteFileItem MR_deleteEntityInContext:localContext];
        }
        
        NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:myVaultFile]] inContext:localContext];
        if (offlineFileItem) {
            [offlineFileItem MR_deleteEntityInContext:localContext];
        }
    }];
}

+ (void)deleteMyVaultFileItemsInStorage:(NSArray *)myVaultFileItems
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    for (NXMyVaultFile *item in myVaultFileItems) {
        @autoreleasepool {
            [NXMyVaultFileStorage deleteMyVaultFileItemInStorage:item];
        }
    }
}

#pragma - mark - FETCH
+ (NSArray *)getAllMyVaultFiles
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NSMutableArray *nxMyVaultFileArray = [[NSMutableArray alloc] init];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSPredicate *predicate = nil;
        NSFetchRequest *request = [NXMyVaultFileItem MR_createFetchRequest];
        
        [request setPredicate:predicate];
        [request setIncludesPropertyValues:YES];
        [request setReturnsObjectsAsFaults:NO];
        [request setIncludesPendingChanges:YES];
        
        NSArray * fetchedObjects = [NXMyVaultFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
        
        
        for (NXMyVaultFileItem *myVaultFileItem in fetchedObjects) {
            @autoreleasepool {
                NXMyVaultFile *nxMyVaultFile = [self convertStorageDataToMyVaultFile:myVaultFileItem];
                [nxMyVaultFileArray addObject:nxMyVaultFile];
            }
        }
    }];
    return nxMyVaultFileArray;
}

+ (NSUInteger)getAllMyVaultFilesCount{
    if (![NXLoginUser sharedInstance].isLogInState) {
          return 0;
      }
    __block NSUInteger totalFilesCount = 0;
       [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
           NSPredicate *predicate = nil;
           NSFetchRequest *request = [NXMyVaultFileItem MR_createFetchRequest];
           
           [request setPredicate:predicate];
           [request setIncludesPropertyValues:YES];
           [request setReturnsObjectsAsFaults:NO];
           [request setIncludesPendingChanges:YES];
           
           NSArray * fetchedObjects = [NXMyVaultFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
           totalFilesCount = fetchedObjects.count;
       }];
       return totalFilesCount;
}

+ (NSArray *)getMyVaultFilesForShareByMe
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NSMutableArray *nxMyVaultFileArray = [[NSMutableArray alloc] init];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deleted == %@ AND shared == %@ AND revoked == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
        
        NSFetchRequest *request = [NXMyVaultFileItem MR_createFetchRequestInContext:localContext];
        
        [request setPredicate:predicate];
        [request setIncludesPropertyValues:YES];
        [request setReturnsObjectsAsFaults:NO];
        [request setIncludesPendingChanges:YES];
        
        NSArray * fetchedObjects = [NXMyVaultFileItem MR_executeFetchRequest:request inContext:localContext];
        
        
        for (NXMyVaultFileItem *myVaultFileItem in fetchedObjects) {
            @autoreleasepool {
                NXMyVaultFile *nxMyVaultFile = [self convertStorageDataToMyVaultFile:myVaultFileItem];
                [nxMyVaultFileArray addObject:nxMyVaultFile];
            }
        }
    }];
    return nxMyVaultFileArray;
}

+ (NSArray *)getAllMyVaultFilesWithFilterModel:(NXMyVaultListParModel *)model
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
   
    NSMutableArray *nxMyVaultFileArray = [[NSMutableArray alloc] init];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
       NSPredicate *predicate;
       switch (model.filterType) {
           case NXMyvaultListFilterTypeAllFiles:
               predicate =  [NSPredicate predicateWithFormat:@"duid != nil"];;
               break;
           case NXMyvaultListFilterTypeActivedTransaction:
               predicate = [NSPredicate predicateWithFormat:@"deleted == %@ AND shared == %@ AND revoked == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
               break;
               
           case NXMyvaultListFilterTypeProtected:
               predicate = [NSPredicate predicateWithFormat:@"revoked == %@ AND shared == %@",[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]];
               break;
           case NXMyvaultListFilterTypeActivedRevoked:
               predicate = [NSPredicate predicateWithFormat:@"revoked == %@",[NSNumber numberWithBool:YES]];
               break;
               
           case NXMyvaultListFilterTypeActivedDeleted:
               predicate = [NSPredicate predicateWithFormat:@"deleted == %@", [NSNumber numberWithBool:YES]];
               break;
               
           case NXMyvaultListFilterTypeAllShared:
               predicate = [NSPredicate predicateWithFormat:@"deleted == %@ AND shared == %@ AND revoked == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
               break;
               
           default:
               predicate = nil;
               break;
       }
        
        NSFetchRequest *request = [NXMyVaultFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sharedOn" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        if(predicate){
            [request setPredicate:predicate];
        }
     
        [request setSortDescriptors:sortDescriptors];
        
        NSArray *fetchedObjects = [NXMyVaultFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
        for (NXMyVaultFileItem *myVaultFileItem in fetchedObjects) {
            @autoreleasepool {
                NXMyVaultFile *nxMyVaultFile = [self convertStorageDataToMyVaultFile:myVaultFileItem];
                [nxMyVaultFileArray addObject:nxMyVaultFile];
            }
        }
    }];
    return nxMyVaultFileArray;
}

#pragma - mark - CONVERT METHOD
+ (NXMyVaultFile *)convertStorageDataToMyVaultFile:(NXMyVaultFileItem *)storageMyVaultFileItem
{
    
    NXMyVaultFile *myVaultFile = [[NXMyVaultFile alloc] init];
    // Local  MY_DRIVE  SHAREPOINT_ONLINE ONE_DRIVE SHAREPOINT_ONPREMISE LOCAL_DRIVE DROPBOX GOOGLE_DRIVE BOX
   // NSString *type = storageMyVaultFileItem.sourceRepoType;
    myVaultFile.sorceType = NXFileBaseSorceTypeMyVaultFile;
    NXMyVaultFileCustomMetadata * metaData = [[NXMyVaultFileCustomMetadata alloc] init];
    myVaultFile.name = storageMyVaultFileItem.fileName;
    myVaultFile.size = storageMyVaultFileItem.size.longLongValue;
    myVaultFile.fileLink = storageMyVaultFileItem.fileLink;
    if (storageMyVaultFileItem.recipients) {
        myVaultFile.recipients = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:storageMyVaultFileItem.recipients];
    }
    myVaultFile.sharedWith = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData: storageMyVaultFileItem.sharedWith];
    myVaultFile.sharedOn =  [NSNumber numberWithLongLong:[storageMyVaultFileItem.sharedOn timeIntervalSince1970]];
    myVaultFile.duid = storageMyVaultFileItem.duid;
    myVaultFile.isShared = storageMyVaultFileItem.shared.boolValue;
    myVaultFile.isRevoked = storageMyVaultFileItem.revoked.boolValue;
    myVaultFile.isDeleted = storageMyVaultFileItem.deleted.boolValue;
    if (storageMyVaultFileItem.rights) {
         myVaultFile.rights = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:storageMyVaultFileItem.rights];
    }
    myVaultFile.protectedOn = [NSNumber numberWithLongLong:[storageMyVaultFileItem.protectedOn timeIntervalSince1970]];
    myVaultFile.isFavorite = storageMyVaultFileItem.isFavorite.boolValue;
    myVaultFile.isOffline = storageMyVaultFileItem.isOffline.boolValue;
    myVaultFile.fullPath = storageMyVaultFileItem.fileDisplayPath;
    myVaultFile.fullServicePath = storageMyVaultFileItem.fileServicePath;
    myVaultFile.lastModifiedDate = storageMyVaultFileItem.sharedOn;
    
    metaData.SourceFilePathId = storageMyVaultFileItem.sourceFilePathId;
    metaData.sourceRepoId = storageMyVaultFileItem.sourceRepoId;
    metaData.sourceRepoName = storageMyVaultFileItem.sourceRepoName;
    metaData.sourceRepoType = storageMyVaultFileItem.sourceRepoType;
    metaData.sourceFilePathDisplay = storageMyVaultFileItem.sourceFilePathDisplay;
    
    
    myVaultFile.metaData = metaData;
    
    return myVaultFile;
}

#pragma - mark - MARK/UNMARK FAVORITE METHOD
+ (void)markFavFileItem:(NXMyVaultFile *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        if (myVaultFileItem) {
            myVaultFileItem.isFavorite = [NSNumber numberWithBool:YES];
        }
        
        NXFavoriteFile *favoriteFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        if (favoriteFile) {
            //stpe1 delete old data first if it exist
            [favoriteFile MR_deleteEntityInContext:localContext];
        }
        
        //step2 create new records for fav file item in storage
        NXFavoriteFile *newFavoriteFile = [NXFavoriteFile MR_createEntityInContext:localContext];
        
        newFavoriteFile.fileKey = [NXCommonUtils fileKeyForFile:fileItem];
        newFavoriteFile.fileDispalyPath = fileItem.fullPath;
        newFavoriteFile.fileName = fileItem.name;
        newFavoriteFile.fileServicePath = fileItem.fullServicePath;
        newFavoriteFile.lastModified = fileItem.lastModifiedDate;
        newFavoriteFile.myVaultFile = [NSNumber numberWithBool:YES];
        newFavoriteFile.duid = fileItem.duid;
        newFavoriteFile.size = [NSNumber numberWithLongLong:fileItem.size];
        newFavoriteFile.repoFilePartner = nil;
        newFavoriteFile.myVaultPartner = myVaultFileItem;
        myVaultFileItem.favFilePartner = newFavoriteFile;
    }];
}

+ (void)unmarkFavFileItem:(NXMyVaultFile *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXMyVaultFileItem *myVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        if (myVaultFileItem) {
            myVaultFileItem.isFavorite = [NSNumber numberWithBool:NO];
            myVaultFileItem.favFilePartner = nil;
        }
        
        NXFavoriteFile *favoriteFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        if (favoriteFile) {
            [favoriteFile MR_deleteEntityInContext:localContext];
        }
    }];
}

@end
