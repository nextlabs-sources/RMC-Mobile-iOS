//
//  NXFavFileStorage.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 23/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavFileStorage.h"
#import "MagicalRecord.h"
#import "NXCommonUtils.h"
#import "NXRepoFileItem+CoreDataClass.h"
#import "NXFavoriteFile+CoreDataClass.h"
#import "NXMyVaultFileItem+CoreDataClass.h"

@implementation NXFavFileStorage

#pragma - mark - INSERT
+ (void)insertNewFavFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSString *fileKey = [NXCommonUtils fileKeyForFile:fileItem];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXFavoriteFile *newFavFileItem = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        
        if (!newFavFileItem) {
            newFavFileItem = [NXFavoriteFile MR_createEntityInContext:localContext];
        }
        
        newFavFileItem.fileDispalyPath = fileItem.fullPath;
        newFavFileItem.fileKey = fileKey;
        newFavFileItem.fileName = fileItem.name;
        newFavFileItem.fileServicePath = fileItem.fullServicePath;
        newFavFileItem.lastModified = fileItem.lastModifiedDate;
        newFavFileItem.size = [NSNumber numberWithLongLong:fileItem.size];
        newFavFileItem.repoId = fileItem.repoId;
        
        if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile) {
            NXMyVaultFile *myvaultFile = (NXMyVaultFile *)fileItem;
            
            newFavFileItem.myVaultFile = [NSNumber numberWithBool:YES];
            if (newFavFileItem.lastModified == nil) {
                newFavFileItem.lastModified = [NSDate dateWithTimeIntervalSince1970:myvaultFile.sharedOn.longLongValue];
            }
            
            // add relationShip for myVaultFileItem
            NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
            if (myvaultFileItem) {
                newFavFileItem.myVaultPartner = myvaultFileItem;
                myvaultFileItem.favFilePartner = newFavFileItem;
                newFavFileItem.duid = myvaultFileItem.duid;
                myvaultFileItem.isFavorite = [NSNumber numberWithBool:YES];
            }
        }
        else if(fileItem.sorceType == NXFileBaseSorceTypeRepoFile)
        {
            newFavFileItem.myVaultFile = [NSNumber numberWithBool:NO];
            
            // add relationShip for repoFileItem
            NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
            if (repoFileItem) {
                newFavFileItem.repoFilePartner = repoFileItem;
                repoFileItem.favFilePar = newFavFileItem;
                repoFileItem.isFavorite = [NSNumber numberWithBool:YES];
            }
        }
    }];
}

+ (void)insertNewFavFileItems:(NSArray *)fileItemsArray
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NXFileBase *fileItem in fileItemsArray) {
            NSString *fileKey = [NXCommonUtils fileKeyForFile:fileItem];
            NXFavoriteFile *newFavFileItem = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
            
            if (!newFavFileItem) {
                newFavFileItem = [NXFavoriteFile MR_createEntityInContext:localContext];
            }
            
            newFavFileItem.fileDispalyPath = fileItem.fullPath;
            newFavFileItem.fileKey = fileKey;
            newFavFileItem.fileName = fileItem.name;
            newFavFileItem.fileServicePath = fileItem.fullServicePath;
            newFavFileItem.lastModified = fileItem.lastModifiedDate;
            newFavFileItem.size = [NSNumber numberWithLongLong:fileItem.size];
            newFavFileItem.repoId = fileItem.repoId;
            
            if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile) {
                NXMyVaultFile *myvaultFile = (NXMyVaultFile *)fileItem;
                
                newFavFileItem.myVaultFile = [NSNumber numberWithBool:YES];
                if (newFavFileItem.lastModified == nil) {
                    newFavFileItem.lastModified = [NSDate dateWithTimeIntervalSince1970:myvaultFile.sharedOn.longLongValue];
                }
                
                // add relationShip for myVaultFileItem
                NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
                if (myvaultFileItem) {
                    newFavFileItem.myVaultPartner = myvaultFileItem;
                    myvaultFileItem.favFilePartner = newFavFileItem;
                    newFavFileItem.duid = myvaultFileItem.duid;
                    myvaultFileItem.isFavorite = [NSNumber numberWithBool:YES];
                }
            }
            else if(fileItem.sorceType == NXFileBaseSorceTypeRepoFile)
            {
                newFavFileItem.myVaultFile = [NSNumber numberWithBool:NO];
                
                // add relationShip for repoFileItem
                NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
                if (repoFileItem) {
                    newFavFileItem.repoFilePartner = repoFileItem;
                    repoFileItem.favFilePar = newFavFileItem;
                    repoFileItem.isFavorite = [NSNumber numberWithBool:YES];
                }
            }
        }
    }];
   
}

#pragma - mark - UPDATE
+ (void)updateFavFileItem:(NXFileBase *)fileItem
{
    
}

+ (void)updateFavFileItems:(NXFileBase *)fileItemsArray
{
    
}

#pragma - mark - DELETE
+ (void)deleteFavFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NXFavoriteFile *favoriteFileItem = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        
        if (favoriteFileItem) {
            if (favoriteFileItem.repoFilePartner) {
                favoriteFileItem.repoFilePartner.isFavorite = [NSNumber numberWithBool:NO];
            }
            
            if (favoriteFileItem.myVaultPartner) {
                favoriteFileItem.myVaultPartner.isFavorite = [NSNumber numberWithBool:NO];
            }
            [favoriteFileItem MR_deleteEntityInContext:localContext];
        }
    }];
}

+ (void)deleteFavFileItems:(NSArray *)fileItemsArray
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    for (NXFileBase *item in fileItemsArray) {
        [self deleteFavFileItem:item];
    }
}

#pragma - mark - FETCH
+ (NXFileBase *)getFavFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NXFavoriteFile *favoriteFileItem = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:[NSManagedObjectContext MR_defaultContext]];
    if (favoriteFileItem) {
        NXFileBase *fileItem = nil;
        if (favoriteFileItem.myVaultFile.boolValue == YES) {
            fileItem = (NXMyVaultFile *)[[NXMyVaultFile alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeMyVaultFile;
            fileItem.repoId = favoriteFileItem.repoId;
            fileItem.serviceAlias = @"MyVault";
        }
        else
        {
            fileItem = [[NXFile alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
            fileItem.repoId = favoriteFileItem.repoId;
            fileItem.serviceAlias = @"MyDrive";
        }
        
        fileItem.fullServicePath = favoriteFileItem.fileServicePath;
        fileItem.name = favoriteFileItem.fileName;
        fileItem.lastModifiedDate = favoriteFileItem.lastModified;
        fileItem.lastModifiedTime = [NSString stringWithFormat:@"%ld", (long)[favoriteFileItem.lastModified timeIntervalSince1970]];
        fileItem.size = favoriteFileItem.size.longLongValue;
        fileItem.fullPath = favoriteFileItem.fileDispalyPath;
        fileItem.isFavorite = YES;
        return fileItem;
    }
    return nil;
}
+(NSArray *)allFavFileItemsInMyVault{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSArray array];
    }
    NSArray *favoriteFileItems = [NXFavoriteFile MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NXFavoriteFile *favFileItem in favoriteFileItems) {
        if (favFileItem.myVaultFile.boolValue == YES) {
            NXMyVaultFile *fileItem = [[NXMyVaultFile alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeMyVaultFile;
            fileItem.serviceAlias = @"MyVault";
            fileItem.repoId = favFileItem.repoId;
            fileItem.fullServicePath = favFileItem.fileServicePath;
            fileItem.fullPath = favFileItem.fileDispalyPath;
            fileItem.name = favFileItem.fileName;
            fileItem.lastModifiedDate = favFileItem.lastModified;
            fileItem.lastModifiedTime = [NSString stringWithFormat:@"%ld", (long)[favFileItem.lastModified timeIntervalSince1970]];
            fileItem.size = favFileItem.size.longLongValue;
            fileItem.fullPath = favFileItem.fileDispalyPath;
            fileItem.isFavorite = YES;
            fileItem.duid = favFileItem.duid;
            fileItem.isShared = favFileItem.myVaultPartner.shared.boolValue;
            fileItem.isRevoked = favFileItem.myVaultPartner.revoked.boolValue;
            fileItem.isDeleted = favFileItem.myVaultPartner.deleted.boolValue;
            
            NXMyVaultFileCustomMetadata *metaData = [[NXMyVaultFileCustomMetadata alloc] init];
            metaData.sourceRepoId = favFileItem.myVaultPartner.sourceRepoId;
            metaData.sourceRepoName = favFileItem.myVaultPartner.sourceRepoName;
            metaData.sourceRepoType = favFileItem.myVaultPartner.sourceRepoType;
            metaData.sourceFilePathDisplay = favFileItem.myVaultPartner.sourceFilePathDisplay;
            metaData.SourceFilePathId = favFileItem.myVaultPartner.sourceFilePathId;
            
            fileItem.metaData = metaData;
            
            [retArray addObject:fileItem];
        }
    }
    return retArray;
    
}
+ (NSArray *)allFavFileItems
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSArray array];
    }
    NSArray *favoriteFileItems = [NXFavoriteFile MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NXFavoriteFile *favFileItem in favoriteFileItems) {
        
        if (favFileItem.myVaultFile.boolValue == YES) {
            NXMyVaultFile *fileItem = [[NXMyVaultFile alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeMyVaultFile;
            fileItem.serviceAlias = @"MyVault";
            fileItem.repoId = favFileItem.repoId;
            fileItem.fullServicePath = favFileItem.fileServicePath;
            fileItem.fullPath = favFileItem.fileDispalyPath;
            fileItem.name = favFileItem.fileName;
            fileItem.lastModifiedDate = favFileItem.lastModified;
            fileItem.lastModifiedTime = [NSString stringWithFormat:@"%ld", (long)[favFileItem.lastModified timeIntervalSince1970]];
            fileItem.size = favFileItem.size.longLongValue;
            fileItem.fullPath = favFileItem.fileDispalyPath;
            fileItem.isFavorite = YES;
            fileItem.duid = favFileItem.duid;
            fileItem.isShared = favFileItem.myVaultPartner.shared.boolValue;
            fileItem.isRevoked = favFileItem.myVaultPartner.revoked.boolValue;
            fileItem.isDeleted = favFileItem.myVaultPartner.deleted.boolValue;
            
            NXMyVaultFileCustomMetadata *metaData = [[NXMyVaultFileCustomMetadata alloc] init];
            metaData.sourceRepoId = favFileItem.myVaultPartner.sourceRepoId;
            metaData.sourceRepoName = favFileItem.myVaultPartner.sourceRepoName;
            metaData.sourceRepoType = favFileItem.myVaultPartner.sourceRepoType;
            metaData.sourceFilePathDisplay = favFileItem.myVaultPartner.sourceFilePathDisplay;
            metaData.SourceFilePathId = favFileItem.myVaultPartner.sourceFilePathId;
            
            fileItem.metaData = metaData;
            
            [retArray addObject:fileItem];
        }
        else
        {
            NXFile *fileItem = [[NXFile alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
            fileItem.serviceAlias = @"MyDrive";
            fileItem.repoId = favFileItem.repoId;
            fileItem.fullServicePath = favFileItem.fileServicePath;
            fileItem.name = favFileItem.fileName;
            fileItem.fullPath = favFileItem.fileDispalyPath;
            fileItem.lastModifiedDate = favFileItem.lastModified;
            fileItem.lastModifiedTime = [NSString stringWithFormat:@"%ld", (long)[favFileItem.lastModified timeIntervalSince1970]];
            fileItem.size = favFileItem.size.longLongValue;
            fileItem.fullPath = favFileItem.fileDispalyPath;
            fileItem.isFavorite = YES;
            fileItem.serviceType = favFileItem.repoFilePartner.repository.service_type;
            [retArray addObject:fileItem];
        }
    }
    return retArray;
}

+ (NSArray *)allFavFileItemsInMyDrive{
    if (![NXLoginUser sharedInstance].isLogInState) {
          return [NSArray array];
      }
      NSArray *favoriteFileItems = [NXFavoriteFile MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
      NSMutableArray *retArray = [[NSMutableArray alloc] init];
      for (NXFavoriteFile *favFileItem in favoriteFileItems) {
          
          if (favFileItem.myVaultFile.boolValue == YES) {
          }else
          {
              NXFile *fileItem = [[NXFile alloc] init];
              fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
              fileItem.serviceAlias = @"MyDrive";
              fileItem.repoId = favFileItem.repoId;
              fileItem.fullServicePath = favFileItem.fileServicePath;
              fileItem.name = favFileItem.fileName;
              fileItem.fullPath = favFileItem.fileDispalyPath;
              fileItem.lastModifiedDate = favFileItem.lastModified;
              fileItem.lastModifiedTime = [NSString stringWithFormat:@"%ld", (long)[favFileItem.lastModified timeIntervalSince1970]];
              fileItem.size = favFileItem.size.longLongValue;
              fileItem.fullPath = favFileItem.fileDispalyPath;
              fileItem.isFavorite = YES;
              fileItem.serviceType = favFileItem.repoFilePartner.repository.service_type;
              [retArray addObject:fileItem];
          }
      }
      return retArray;
}

@end
