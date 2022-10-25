//
//  NXRepoFileStorage.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepoFileStorage.h"
#import "MagicalRecord.h"
#import "NXCommonUtils.h"
#import "NXRepoFileItem+CoreDataClass.h"
#import "NXFavoriteFile+CoreDataClass.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXSharePointFolder.h"
#import "NXSharePointFile.h"
#import "NXSharedWorkspaceFile.h"

@implementation NXRepoFileStorage
+(void)addFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        for (NXFileBase *file in fileItems) {
            NXRepoFileItem *newRepoItem = [NXRepoFileItem MR_createEntityInContext:localContext];
            newRepoItem.fileServicePath = file.fullServicePath;
            newRepoItem.fileDispalyPath = file.fullPath;
            newRepoItem.fileKey = [NXCommonUtils fileKeyForFile:file];
            newRepoItem.fileName = file.name;
            newRepoItem.fileServicePath = file.fullServicePath;
            newRepoItem.isFavorite = [NSNumber numberWithBool:file.isFavorite];
            newRepoItem.lastModified = file.lastModifiedDate;
            newRepoItem.size = [NSNumber numberWithLongLong:file.size];
            
            if ([file isKindOfClass:[NXFolder class]]) {
                newRepoItem.isFolder = [NSNumber numberWithBool:YES];
            }else{
                newRepoItem.isFolder = [NSNumber numberWithBool:NO];
            }
            
            // add fav mark
            NXFavoriteFile *favFilePar = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", newRepoItem.fileKey] inContext:localContext];
            if (favFilePar) {
                favFilePar.repoFilePartner = newRepoItem;
                newRepoItem.favFilePar = favFilePar;
                newRepoItem.isFavorite = [NSNumber numberWithBool:YES];
            }
            
            // add parent
            if (!parentFolder.isRoot) {
                NXRepoFileItem *parentFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:parentFolder]] inContext:localContext];
                assert(parentFileItem);
                [parentFileItem addChildFileItemObject:newRepoItem];
                newRepoItem.parentFileItem = parentFileItem;
            }
            
            // set bound service
            NXBoundService *repo = [NXBoundService MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"service_id==%@", file.repoId] inContext:localContext];
            assert(repo);
            [repo addRepoFilesObject:newRepoItem];
            newRepoItem.repository = repo;
        }
        
    }];
}

+ (void)deleteFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXRepoFileItem *delFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        [delFileItem MR_deleteEntityInContext:localContext]; // fav and child/parent relationship will automatically set
    }];
}

+ (void)updateFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        repoFileItem.lastModified = fileItem.lastModifiedDate;
        repoFileItem.size = [NSNumber numberWithLongLong:fileItem.size];
        repoFileItem.fileName = fileItem.name;
        repoFileItem.fileDispalyPath = fileItem.fullPath;
    }];
}

+ (void)updateFileItemSize:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        repoFileItem.size = [NSNumber numberWithLongLong:fileItem.size];
    }];
}

+ (void)updateFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSMutableArray *newList = [[NSMutableArray alloc] initWithArray:fileItems];
    NSMutableArray *tempDeleteChildren = [[NSMutableArray alloc] init];
    NSArray *localDATAARRA = [self getFileItemsCopyUnderFolder:parentFolder];
    for (NXFileBase *child in localDATAARRA) {
        BOOL isfind = NO;
        NXFileBase *tempFile;
        for (NXFileBase *file in newList) {
            if ([child isEqual:file]) {
                isfind = YES;
                
                tempFile = file ;
                // update file's reposiotry information.
                child.lastModifiedTime =  file.lastModifiedTime;
                child.lastModifiedDate = file.lastModifiedDate;
                child.size = file.size;
                child.refreshDate = file.refreshDate;
                child.isRoot = file.isRoot;
                child.name = file.name;
                child.SPSiteId = file.SPSiteId;
                child.fullPath = file.fullPath;
                file.serviceAlias = [child.serviceAlias copy];
                [self updateFileItem:child];
                break;
            }
        }
        
        if (!isfind) {
            [tempDeleteChildren addObject:child];
        } else {
            [newList removeObject:tempFile];
        }
    }
    for (NXFileBase *file in tempDeleteChildren) {
        [NXRepoFileStorage deleteFileItem:file];
        [[NXLoginUser sharedInstance].nxlOptManager cleanCachedRight:file];
    }
    
    for (NXFileBase *newchild in newList) {
        [NXRepoFileStorage addFileItem:newchild underFolder:parentFolder];
    }
}

+ (void)addFileItem:(NXFileBase *)file underFolder:(NXFileBase *)parentFolder
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXRepoFileItem *newRepoItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@",[NXCommonUtils fileKeyForFile:file]] inContext:localContext];
        if (!newRepoItem) {
           newRepoItem = [NXRepoFileItem MR_createEntityInContext:localContext];
        }
       
        newRepoItem.fileServicePath = file.fullPath;
        newRepoItem.fileKey = [NXCommonUtils fileKeyForFile:file];
        newRepoItem.fileName = file.name;
        newRepoItem.fileDispalyPath = file.fullPath;
        newRepoItem.fileServicePath = file.fullServicePath;
        newRepoItem.isFavorite = [NSNumber numberWithBool:file.isFavorite];
        newRepoItem.lastModified = file.lastModifiedDate;
        newRepoItem.size = [NSNumber numberWithLongLong:file.size];
        
        if ([file isKindOfClass:[NXFolder class]]) {
            newRepoItem.isFolder = [NSNumber numberWithBool:YES];
            if ([file isKindOfClass:[NXSharePointFolder class]]) {
                NXSharePointFolder *folder = (NXSharePointFolder *)file;
                newRepoItem.folderType = [NSNumber numberWithInteger:folder.folderType];
                newRepoItem.ownerSiteURL = folder.ownerSiteURL;
            }
        }else{
            newRepoItem.isFolder = [NSNumber numberWithBool:NO];
            if ([file isKindOfClass:[NXSharePointFile class]]) {
                NXSharePointFile *sharePointFile = (NXSharePointFile *)file;
                newRepoItem.ownerSiteURL = sharePointFile.ownerSiteURL;
            }
        }
        
        // add fav mark
        NXFavoriteFile *favFilePar = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", newRepoItem.fileKey]  inContext:localContext];
        if (favFilePar) {
            favFilePar.repoFilePartner = newRepoItem;
            newRepoItem.favFilePar = favFilePar;
            newRepoItem.isFavorite = [NSNumber numberWithBool:YES];
        }
        
        // add parent
        if (!parentFolder.isRoot) {
            NXRepoFileItem *parentFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:parentFolder]] inContext:localContext];
            assert(parentFileItem);
            if (parentFileItem) {
                [parentFileItem addChildFileItemObject:newRepoItem];
                newRepoItem.parentFileItem = parentFileItem;
            }
           
        }
        
        // set bound service
        NXBoundService *repo = [NXBoundService MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"service_id==%@", file.repoId] inContext:localContext];
        if (repo) {
            [repo addRepoFilesObject:newRepoItem];
            newRepoItem.repository = repo;
        }
    }];
}

+ (void)markFavFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        
        repoFileItem.isFavorite = [NSNumber numberWithBool:YES];
        NXFavoriteFile *favFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        if (favFile) {
            favFile.repoFilePartner = repoFileItem;
            repoFileItem.favFilePar = favFile;
        }else{
            favFile = [NXFavoriteFile MR_createEntityInContext:localContext];
            favFile.fileDispalyPath = repoFileItem.fileDispalyPath;
            favFile.fileKey = [NXCommonUtils fileKeyForFile:fileItem];
            favFile.fileName = repoFileItem.fileName;
            favFile.fileServicePath = repoFileItem.fileServicePath;
            favFile.lastModified = repoFileItem.lastModified;
            favFile.myVaultFile = [NSNumber numberWithBool:NO];
            favFile.size = repoFileItem.size;
            favFile.repoFilePartner = repoFileItem;
            repoFileItem.favFilePar = favFile;
        }
    }];
}

+ (void)unmarkFavFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        repoFileItem.isFavorite = [NSNumber numberWithBool:NO];
        NXFavoriteFile *favFile = [NXFavoriteFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        if (favFile) {
            [favFile MR_deleteEntityInContext:localContext];
        }
    }];
}

+ (NXFileBase *)getParentOfFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:[NSManagedObjectContext MR_defaultContext]];
    __block NXFileBase *parentFolder = nil;
    dispatch_main_sync_safe(^{
        if (repoFileItem) {
            NXRepoFileItem *parentFileItem = repoFileItem.parentFileItem;
            if (parentFileItem) {
                parentFolder = [self transRepoFileItemIntoFileBase:parentFileItem];
                parentFolder.repoId = fileItem.repoId;
            }else{ // means root folder
                parentFolder = [NXCommonUtils createRootFolderByRepoType:repoFileItem.repository.service_type.integerValue];
                parentFolder.repoId = fileItem.repoId;
            }
        }
    });
    return parentFolder;
}

+ (NSUInteger)allRepoFilesCount
{
    if (![NXLoginUser sharedInstance].isLogInState) {
         return 0;
     }
    
  NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"isFolder == %@",[NSNumber numberWithBool:NO]];
   __block NSUInteger totalFilesCount = 0;
        dispatch_main_sync_safe(^{
            NSArray *fileList = [NXRepoFileItem MR_findAllWithPredicate:fetchPredicate inContext:[NSManagedObjectContext MR_defaultContext]];
                if (fileList.count > 0) {
                      totalFilesCount = fileList.count;
                }
          
        });
    return totalFilesCount;
}

+ (NSUInteger)allMyDriveFilesCount
{
    if (![NXLoginUser sharedInstance].isLogInState) {
           return 0;
       }
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"isFolder == %@ && repository.service_type.intergerValue == %ld",[NSNumber numberWithBool:NO], kServiceSkyDrmBox];
     __block NSUInteger totalFilesCount = 0;
          dispatch_main_sync_safe(^{
              NSArray *fileList = [NXRepoFileItem MR_findAllWithPredicate:fetchPredicate inContext:[NSManagedObjectContext MR_defaultContext]];
              if (fileList) {
                  totalFilesCount = fileList.count;
              }
          });
      return totalFilesCount;
}

+ (NSArray *)getFileItemsCopyUnderFolder:(NXFileBase *)parentFolder
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    if (parentFolder.isRoot) {
        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"repository.service_id==%@ AND parentFileItem==nil", parentFolder.repoId];
        NSMutableArray *retFileList = [[NSMutableArray alloc] init];
        dispatch_main_sync_safe(^{
            NSArray *fileList = [NXRepoFileItem MR_findAllWithPredicate:fetchPredicate inContext:[NSManagedObjectContext MR_defaultContext]];
            for (NXRepoFileItem *fileItem in fileList) {
                NXFileBase *nxFile = [self transRepoFileItemIntoFileBase:fileItem];
                [retFileList addObject:nxFile];
            }
        });
        return retFileList;
    }else{
        
        NSMutableArray *retFileList = [[NSMutableArray alloc] init];
        dispatch_main_sync_safe((^{
            NXRepoFileItem *repoFileItem = [NXRepoFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:parentFolder]] inContext:[NSManagedObjectContext MR_defaultContext]];
            for (NXRepoFileItem *fileItem in repoFileItem.childFileItem) {
                NXFileBase *nxFile = [self transRepoFileItemIntoFileBase:fileItem];
                [retFileList addObject:nxFile];
            }
        }));
        return retFileList;
    }
}

+ (NXFileBase *)transRepoFileItemIntoFileBase:(NXRepoFileItem *)repoFileItem
{
    if (repoFileItem.ownerSiteURL.length > 0) {
        if (repoFileItem.isFolder.boolValue) {
            NXSharePointFolder *folderItem = [[NXSharePointFolder alloc] init];
            folderItem.sorceType = NXFileBaseSorceTypeRepoFile;
            folderItem.repoId = repoFileItem.repository.service_id;
            folderItem.name = repoFileItem.fileName;
            folderItem.fullPath = repoFileItem.fileDispalyPath;
            folderItem.fullServicePath = repoFileItem.fileServicePath;
            folderItem.lastModifiedDate = repoFileItem.lastModified;
            folderItem.serviceAlias = repoFileItem.repository.service_alias;
            folderItem.serviceAccountId = repoFileItem.repository.service_account_id;
            folderItem.serviceType = repoFileItem.repository.service_type;
            folderItem.isFavorite = repoFileItem.isFavorite.boolValue;
            folderItem.size = repoFileItem.size.longLongValue;
            folderItem.folderType = (SPFolderType)repoFileItem.folderType.integerValue;
            folderItem.ownerSiteURL = repoFileItem.ownerSiteURL;
            return folderItem;
        }
        else
        {
            NXSharePointFile *fileItem = [[NXSharePointFile alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
            fileItem.repoId = repoFileItem.repository.service_id;
            fileItem.name = repoFileItem.fileName;
            fileItem.fullPath = repoFileItem.fileDispalyPath;
            fileItem.fullServicePath = repoFileItem.fileServicePath;
            fileItem.lastModifiedDate = repoFileItem.lastModified;
            fileItem.serviceAlias = repoFileItem.repository.service_alias;
            fileItem.serviceAccountId = repoFileItem.repository.service_account_id;
            fileItem.serviceType = repoFileItem.repository.service_type;
            fileItem.isFavorite = repoFileItem.isFavorite.boolValue;
            fileItem.size = repoFileItem.size.longLongValue;
            fileItem.ownerSiteURL = repoFileItem.ownerSiteURL;
            return fileItem;
        }
    }
    
    if (repoFileItem.isFolder.boolValue) {
        if ([repoFileItem.repository.service_providerClass isEqualToString:@"APPLICATION"]) {
            NXSharedWorkspaceFolder*fileItem = [[NXSharedWorkspaceFolder alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeSharedWorkspaceFile;
            fileItem.repoId = repoFileItem.repository.service_id;
            fileItem.name = repoFileItem.fileName;
            fileItem.fullPath = repoFileItem.fileDispalyPath;
            fileItem.fullServicePath = repoFileItem.fileServicePath;
            fileItem.lastModifiedDate = repoFileItem.lastModified;
            fileItem.serviceAlias = repoFileItem.repository.service_alias;
            fileItem.serviceAccountId = repoFileItem.repository.service_account_id;
            fileItem.serviceType = repoFileItem.repository.service_type;
            fileItem.isFavorite = repoFileItem.isFavorite.boolValue;
            fileItem.size = repoFileItem.size.longLongValue;
            return fileItem;
        }
        NXFolder *folderItem = [[NXFolder alloc] init];
        folderItem.sorceType = NXFileBaseSorceTypeRepoFile;
        folderItem.repoId = repoFileItem.repository.service_id;
        folderItem.name = repoFileItem.fileName;
        folderItem.fullPath = repoFileItem.fileDispalyPath;
        folderItem.fullServicePath = repoFileItem.fileServicePath;
        folderItem.lastModifiedDate = repoFileItem.lastModified;
        folderItem.serviceAlias = repoFileItem.repository.service_alias;
        folderItem.serviceAccountId = repoFileItem.repository.service_account_id;
        folderItem.serviceType = repoFileItem.repository.service_type;
        folderItem.isFavorite = repoFileItem.isFavorite.boolValue;
        folderItem.size = repoFileItem.size.longLongValue;
        return folderItem;
    }else{
        if ([repoFileItem.repository.service_providerClass isEqualToString:@"APPLICATION"]) {
            NXSharedWorkspaceFile *fileItem = [[NXSharedWorkspaceFile alloc] init];
            fileItem.sorceType = NXFileBaseSorceTypeSharedWorkspaceFile;
            fileItem.repoId = repoFileItem.repository.service_id;
            fileItem.name = repoFileItem.fileName;
            fileItem.fullPath = repoFileItem.fileDispalyPath;
            fileItem.fullServicePath = repoFileItem.fileServicePath;
            fileItem.lastModifiedDate = repoFileItem.lastModified;
            fileItem.serviceAlias = repoFileItem.repository.service_alias;
            fileItem.serviceAccountId = repoFileItem.repository.service_account_id;
            fileItem.serviceType = repoFileItem.repository.service_type;
            fileItem.isFavorite = repoFileItem.isFavorite.boolValue;
            fileItem.size = repoFileItem.size.longLongValue;
            return fileItem;
        }
        NXFile *fileItem = [[NXFile alloc] init];
        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
        fileItem.repoId = repoFileItem.repository.service_id;
        fileItem.name = repoFileItem.fileName;
        fileItem.fullPath = repoFileItem.fileDispalyPath;
        fileItem.fullServicePath = repoFileItem.fileServicePath;
        fileItem.lastModifiedDate = repoFileItem.lastModified;
        fileItem.serviceAlias = repoFileItem.repository.service_alias;
        fileItem.serviceAccountId = repoFileItem.repository.service_account_id;
        fileItem.serviceType = repoFileItem.repository.service_type;
        fileItem.isFavorite = repoFileItem.isFavorite.boolValue;
        fileItem.size = repoFileItem.size.longLongValue;
        return fileItem;
    }
}

@end
