//
//  NXOfflineFileStorage.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//
#import "NXOfflineFileStorage.h"
#import "MagicalRecord.h"
#import "NXCommonUtils.h"
#import "NXOfflineFileItem+CoreDataClass.h"
#import "NXProjectFileItem+CoreDataClass.h"
#import "NXProjectItem+CoreDataClass.h"
#import "NXMyVaultFileItem+CoreDataClass.h"
#import "NXShareWithMeFileItem+CoreDataClass.h"
#import "NXSharedWithProjectFileItem+CoreDataClass.h"
#import "NXWorkSpaceFileItem+CoreDataClass.h"
#import "NXOfflineFile.h"
#import "NXWorkSpaceStorage.h"
#import "NXSharedWithProjectFileStorage.h"


@implementation NXOfflineFileStorage

#pragma - mark - INSERT
+ (void)insertNewOfflineFileItem:(NXOfflineFile *)fileItem;
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXOfflineFileItem *newOfflineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
        
        if (!newOfflineFileItem) {
            newOfflineFileItem = [NXOfflineFileItem MR_createEntityInContext:localContext];
        }
        
        newOfflineFileItem.sourcePath = fileItem.sourcePath;
        newOfflineFileItem.state = [NSNumber numberWithInteger:fileItem.state];
        newOfflineFileItem.fileKey = fileItem.fileKey;
        newOfflineFileItem.duid = fileItem.duid;
        newOfflineFileItem.markAsOfflineDate = fileItem.markAsOfflineDate;
        newOfflineFileItem.isCenterPolicyEncrypted = [NSNumber numberWithBool:fileItem.isCenterPolicyEncrypted];
        
        if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile) {
            
            newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeMyVaultFile];
            
            // add relationShip for myVaultFileItem
            NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
            if (myvaultFileItem) {
                newOfflineFileItem.myVaultPartner = myvaultFileItem;
                myvaultFileItem.offlineFilePartner = newOfflineFileItem;
                myvaultFileItem.isOffline = [NSNumber numberWithBool:YES];
            }
        }
        else if(fileItem.sorceType == NXFileBaseSorceTypeProject)
        {
            newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeProject];
            
            // add relationShip for projectFileItem
            NXProjectFileItem *projectFileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
            if (projectFileItem) {
                newOfflineFileItem.myProjectFilePartner = projectFileItem;
                projectFileItem.offlineFilePartner = newOfflineFileItem;
                projectFileItem.isOffline = [NSNumber numberWithBool:YES];;
            }
        }else if(fileItem.sorceType == NXFileBaseSorceTypeShareWithMe){
             newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeShareWithMe];
            
            // add relationShip for sharedWithMeFileItem
            NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
            if (sharedWithMeFileItem) {
                newOfflineFileItem.shareWithMeFilePartner = sharedWithMeFileItem;
                sharedWithMeFileItem.offlineFilePartner = newOfflineFileItem;
            }
        }else if(fileItem.sorceType == NXFileBaseSorceTypeWorkSpace) {
            newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeWorkSpace];
            NXWorkSpaceFileItem *workSpaceFile = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
            if (workSpaceFile) {
                newOfflineFileItem.workSpaceFilePartner = workSpaceFile;
                workSpaceFile.offlineFilePartner = newOfflineFileItem;
                workSpaceFile.isOfflineLine = [NSNumber numberWithBool:YES];
            }
        }else if(fileItem.sorceType == NXFileBaseSorceTypeSharedWithProject) {
            newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeSharedWithProject];
            NXSharedWithProjectFileItem *shareWithProjectFile = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
            if (shareWithProjectFile) {
                newOfflineFileItem.shareWithProjectFileParter = shareWithProjectFile;
                shareWithProjectFile.offlineFilePartner = newOfflineFileItem;
                shareWithProjectFile.isOffline = [NSNumber numberWithBool:YES];
            }
        }
    }];
}

+ (void)insertNewOfflineFileItems:(NSArray *)fileItemsArray
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NXOfflineFile *fileItem in fileItemsArray) {
            NXOfflineFileItem *newOfflineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
            
            if (!newOfflineFileItem) {
                newOfflineFileItem = [NXOfflineFileItem MR_createEntityInContext:localContext];
            }
            
            newOfflineFileItem.sourcePath = fileItem.sourcePath;
            newOfflineFileItem.state = [NSNumber numberWithInteger:fileItem.state];
            newOfflineFileItem.fileKey =  fileItem.fileKey;
            newOfflineFileItem.duid = fileItem.duid;
            newOfflineFileItem.markAsOfflineDate = fileItem.markAsOfflineDate;
            newOfflineFileItem.isCenterPolicyEncrypted = [NSNumber numberWithBool:fileItem.isCenterPolicyEncrypted];
            
            if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile) {
                
                newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeMyVaultFile];
                // add relationShip for myVaultFileItem
                NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@",  fileItem.fileKey] inContext:localContext];
                if (myvaultFileItem) {
                    newOfflineFileItem.myVaultPartner = myvaultFileItem;
                    myvaultFileItem.offlineFilePartner = newOfflineFileItem;
                    myvaultFileItem.isOffline = [NSNumber numberWithBool:YES];
                }
            }
            else if(fileItem.sorceType == NXFileBaseSorceTypeProject)
            {
                newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeMyVaultFile];
                
                // add relationShip for projectFileItem
                NXProjectFileItem *projectFileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@",  fileItem.fileKey] inContext:localContext];
                if (projectFileItem) {
                    newOfflineFileItem.myProjectFilePartner = projectFileItem;
                    projectFileItem.offlineFilePartner = newOfflineFileItem;
                    projectFileItem.isOffline = [NSNumber numberWithBool:YES];
                }
            }else if(fileItem.sorceType == NXFileBaseSorceTypeShareWithMe){
                newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeShareWithMe];
                
                // add relationShip for sharedWithMeFileItem
                NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
                if (sharedWithMeFileItem) {
                    newOfflineFileItem.shareWithMeFilePartner = sharedWithMeFileItem;
                    sharedWithMeFileItem.offlineFilePartner = newOfflineFileItem;
                }
            }else if(fileItem.sorceType == NXFileBaseSorceTypeWorkSpace) {
                newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeWorkSpace];
                NXWorkSpaceFileItem *workSpaceFile = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
                if (workSpaceFile) {
                    newOfflineFileItem.workSpaceFilePartner = workSpaceFile;
                    workSpaceFile.offlineFilePartner = newOfflineFileItem;
                    workSpaceFile.isOfflineLine = [NSNumber numberWithBool:YES];
                }
            }else if(fileItem.sorceType == NXFileBaseSorceTypeSharedWithProject) {
                newOfflineFileItem.sourceType = [NSNumber numberWithInt:NXFileBaseSorceTypeSharedWithProject];
                NXSharedWithProjectFileItem *shareWithProjectFile = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:localContext];
                if (shareWithProjectFile) {
                    newOfflineFileItem.shareWithProjectFileParter = shareWithProjectFile;
                    shareWithProjectFile.offlineFilePartner = newOfflineFileItem;
                    shareWithProjectFile.isOffline = [NSNumber numberWithBool:YES];
                }
            }
        }
    }];
}

#pragma - mark - UPDATE
+ (void)updateOfflineFileItem:(NXOfflineFile *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@",fileItem.fileKey] inContext:localContext];
        
        if (offlineFileItem) {
            offlineFileItem.markAsOfflineDate = [NSDate date];
        }
    }];
}

+ (void)updateOfflineItems:(NXOfflineFile *)fileItemsArray
{
    
}

#pragma - mark - DELETE
+ (void)deleteOfflineFileItemWithKey:(NSString *)fileKey
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@",fileKey] inContext:localContext];
        
        if (offlineFileItem) {
            if (offlineFileItem.myProjectFilePartner) {
                offlineFileItem.myProjectFilePartner.isOffline = [NSNumber numberWithBool:NO];
            }
            
            if (offlineFileItem.myVaultPartner) {
                offlineFileItem.myVaultPartner.isOffline= [NSNumber numberWithBool:NO];
            }
            
            
            if (offlineFileItem.workSpaceFilePartner) {
                offlineFileItem.workSpaceFilePartner.isOfflineLine= [NSNumber numberWithBool:NO];
            }
            
            if (offlineFileItem.shareWithProjectFileParter) {
                offlineFileItem.shareWithProjectFileParter.isOffline = [NSNumber numberWithBool:NO];
            }
            
            [offlineFileItem MR_deleteEntityInContext:localContext];
        }
    }];
}

+ (void)deleteOfflineFileItem:(NXOfflineFile *)offlineFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@",offlineFile.fileKey] inContext:localContext];
        
        if (offlineFileItem) {
            if (offlineFileItem.myProjectFilePartner) {
                offlineFileItem.myProjectFilePartner.isOffline = [NSNumber numberWithBool:NO];
            }
            
            if (offlineFileItem.myVaultPartner) {
                offlineFileItem.myVaultPartner.isOffline= [NSNumber numberWithBool:NO];
            }
            
            if (offlineFileItem.workSpaceFilePartner) {
                offlineFileItem.workSpaceFilePartner.isOfflineLine= [NSNumber numberWithBool:NO];
            }
            
            if (offlineFileItem.shareWithProjectFileParter) {
                offlineFileItem.shareWithProjectFileParter.isOffline = [NSNumber numberWithBool:NO];
            }
            
            [offlineFileItem MR_deleteEntityInContext:localContext];
        }
    }];
}

+ (void)deleteOfflineFileItems:(NSArray *)fileItemsArray
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    for (NXOfflineFile *item in fileItemsArray) {
        [self deleteOfflineFileItem:item];
    }
}

#pragma - mark - FETCH
+ (NXOfflineFile *)getOfflineFileItem:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:[NSManagedObjectContext MR_defaultContext]];
    
    if (offlineFileItem) {
         NXOfflineFile *offlineFile = [[NXOfflineFile alloc] init];
        offlineFile.sourcePath = offlineFileItem.sourcePath;
        offlineFile.state = offlineFileItem.state.integerValue;
        offlineFile.fileKey = offlineFileItem.fileKey;
        offlineFile.duid = offlineFileItem.duid;
        offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
        offlineFile.isCenterPolicyEncrypted = [offlineFileItem.isCenterPolicyEncrypted boolValue];
        offlineFile.isOffline = YES;
        
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeMyVaultFile){
            offlineFile.sorceType = NXFileBaseSorceTypeMyVaultFile;
            
            NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (myvaultFileItem) {
                offlineFile.name = myvaultFileItem.fileName;
                offlineFile.fullServicePath = myvaultFileItem.fileServicePath;
                offlineFile.fullPath = myvaultFileItem.fileDisplayPath;
                offlineFile.isFavorite = myvaultFileItem.isFavorite.boolValue;
                offlineFile.size = myvaultFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = myvaultFileItem.sharedOn;
                if (!offlineFile.lastModifiedDate) {
                    offlineFile.lastModifiedDate = myvaultFileItem.protectedOn;
                }
            }
        }
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeProject){
            offlineFile.sorceType = NXFileBaseSorceTypeProject;
            NXProjectFileItem *projectFileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (projectFileItem) {
                offlineFile.name = projectFileItem.name;
                offlineFile.fullServicePath = projectFileItem.fullServicePath;
                offlineFile.fullPath = projectFileItem.fullPath;
                offlineFile.size = projectFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = projectFileItem.lastModifiedDate;
                offlineFile.lastModifiedTime = projectFileItem.lastModifiedTime;
            }
        }
        
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeShareWithMe){
            offlineFile.sorceType = NXFileBaseSorceTypeShareWithMe;
            NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (sharedWithMeFileItem) {
                offlineFile.name = sharedWithMeFileItem.name;
                offlineFile.fullServicePath = sharedWithMeFileItem.transactionCode;
                offlineFile.size = sharedWithMeFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = sharedWithMeFileItem.shareDate;
            }
        }
        
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeWorkSpace) {
            offlineFile.sorceType = NXFileBaseSorceTypeWorkSpace;
            NXWorkSpaceFileItem *workSpaceFileItem = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (workSpaceFileItem) {
                offlineFile.name = workSpaceFileItem.name;
                offlineFile.fullServicePath = workSpaceFileItem.fullServicePath;
                offlineFile.fullPath = workSpaceFileItem.fullPath;
                offlineFile.size = workSpaceFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = workSpaceFileItem.lastModified;
                offlineFile.duid = workSpaceFileItem.duid;
            }
        }
        
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeSharedWithProject) {
                  offlineFile.sorceType = NXFileBaseSorceTypeSharedWithProject;
                  NXSharedWithProjectFileItem *shareWithProjectFileItem = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
                  if (shareWithProjectFileItem) {
                      offlineFile.name = shareWithProjectFileItem.name;
                      offlineFile.size = shareWithProjectFileItem.size.longLongValue;
                      offlineFile.duid = shareWithProjectFileItem.duid;
                      offlineFile.lastModifiedDate = shareWithProjectFileItem.sharedDate;
                      offlineFile.fullServicePath = shareWithProjectFileItem.transactionCode;
                  }
              }
        
        return offlineFile;
    }
    return nil;
}

+(NXFileState)getOfflineFileState:(NXFileBase *)fileItem
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return NXFileStateNormal;
    }
    
    NSString *filekey = @"";
     if ([fileItem isKindOfClass:[NXOfflineFile class]]) {
         NXOfflineFile *offlineFile =( NXOfflineFile *)fileItem;
         if (offlineFile.fileKey.length > 0) {
             filekey = offlineFile.fileKey;
         }else{
            filekey = [NXCommonUtils fileKeyForFile:fileItem];
         }
      
     }else{
         filekey = [NXCommonUtils fileKeyForFile:fileItem];
     }
    
    NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", filekey] inContext:[NSManagedObjectContext MR_defaultContext]];
    
    if (offlineFileItem) {
        if (offlineFileItem.state.integerValue == NXFileStateOfflined) {
            return NXFileStateOfflined;
        }
        
        if (offlineFileItem.state.integerValue == NXFileStateOfflineFailed) {
            return NXFileStateOfflineFailed;
        }
    }
    return NXFileStateNormal;
}

+(NXProjectFile *)getProjectFilePartner:(NXOfflineFile *)offlineFile
{
    NXProjectFileItem *projectFileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFile.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
    if (projectFileItem) {
        NXProjectFile *projectfile = [[NXProjectFile alloc]init];
        projectfile.fullServicePath = projectFileItem.fullServicePath;
        projectfile.fullPath = projectFileItem.fullPath;
        projectfile.name = projectFileItem.name;
        projectfile.Id = projectFileItem.idid;
        projectfile.creationTime = projectFileItem.creationTime;
        projectfile.lastModifiedDate = projectFileItem.lastModifiedDate;
        projectfile.size = [projectFileItem.size longLongValue];
        projectfile.projectFileOwner = (NXProjectFileOwnerModel *)projectFileItem.projectFileOwner;
        projectfile.projectId = projectFileItem.projectId;
        projectfile.parentPath = projectFileItem.parentPath;
        projectfile.duid = projectFileItem.duid;
        projectfile.lastModifiedTime = projectFileItem.lastModifiedTime;
        projectfile.isOffline = projectFileItem.isOffline;
        return projectfile;
    }
    return nil;
}

+(NXMyVaultFile *)getMyVaultFilePartner:(NXOfflineFile *)offlineFile
{
    NXMyVaultFileItem *storageMyVaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFile.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
    if (storageMyVaultFileItem) {
        NXMyVaultFile *myVaultFile = [[NXMyVaultFile alloc] init];
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
    return nil;
}

+(NXSharedWithMeFile *)getSharedWithMeFilePartner:(NXOfflineFile *)offlineFile
{
    NXShareWithMeFileItem *storageSharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFile.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
    if (storageSharedWithMeFileItem) {
        NXSharedWithMeFile *sharedWithMeFile = [[NXSharedWithMeFile alloc] init];
        sharedWithMeFile.sorceType = NXFileBaseSorceTypeShareWithMe;
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
        sharedWithMeFile.lastModifiedTime = [NSString stringWithFormat:@"%f",sharedWithMeFile.sharedDate];
        sharedWithMeFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:sharedWithMeFile.sharedDate];
        
        if (storageSharedWithMeFileItem.offlineFilePartner) {
            sharedWithMeFile.isOffline = YES;
        }else{
            sharedWithMeFile.isOffline = NO;
        }
        return sharedWithMeFile;
    }
    return nil;
}

+(NXWorkSpaceFile *)getWorkSpaceFilePartner:(NXOfflineFile *)offlineFile {
    NXWorkSpaceFile *workSpaceFile = [NXWorkSpaceStorage queryWorkSpaceFileByFileKey:offlineFile.fileKey];
    return workSpaceFile;
}

+(NXSharedWithProjectFile *)getShareWithProjectFilePartner:(NXOfflineFile *)offlineFile{
  NXSharedWithProjectFileItem *storageSharedWithProjectFileItem = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFile.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
     if (storageSharedWithProjectFileItem) {
         NXSharedWithProjectFile *sharedWithProjectFile = [[NXSharedWithProjectFile alloc] init];
         sharedWithProjectFile.sorceType = NXFileBaseSorceTypeSharedWithProject;
         sharedWithProjectFile.duid = storageSharedWithProjectFileItem.duid;
         sharedWithProjectFile.name = storageSharedWithProjectFileItem.name;
         sharedWithProjectFile.fileType = storageSharedWithProjectFileItem.fileType;
         sharedWithProjectFile.size = storageSharedWithProjectFileItem.size.longLongValue;
         sharedWithProjectFile.sharedDate = [storageSharedWithProjectFileItem.sharedDate timeIntervalSince1970];
         sharedWithProjectFile.sharedBy = storageSharedWithProjectFileItem.sharedBy;
         sharedWithProjectFile.transactionId = storageSharedWithProjectFileItem.transactionId;
         sharedWithProjectFile.transactionCode = storageSharedWithProjectFileItem.transactionCode;
         sharedWithProjectFile.rights = [NSKeyedUnarchiver unarchiveObjectWithData:storageSharedWithProjectFileItem.rights];
         sharedWithProjectFile.comment = storageSharedWithProjectFileItem.comment;
         sharedWithProjectFile.isOwner = storageSharedWithProjectFileItem.isOwner.boolValue;
         
         sharedWithProjectFile.fullServicePath = storageSharedWithProjectFileItem.transactionCode;
         sharedWithProjectFile.lastModifiedTime = [NSString stringWithFormat:@"%f",sharedWithProjectFile.sharedDate];
         sharedWithProjectFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:sharedWithProjectFile.sharedDate];
         sharedWithProjectFile.spaceId = storageSharedWithProjectFileItem.spaceId;
         
         if (storageSharedWithProjectFileItem.offlineFilePartner) {
             sharedWithProjectFile.isOffline = YES;
          }else{
             sharedWithProjectFile.isOffline = NO;
          }
         NXProjectModel *projectModel = [NXProjectModel new];
         projectModel.projectId = storageSharedWithProjectFileItem.project.projectId;
         projectModel.membershipId = storageSharedWithProjectFileItem.project.membershipId;
         projectModel.name = storageSharedWithProjectFileItem.project.name;
         sharedWithProjectFile.sharedProject = projectModel;
         
         return sharedWithProjectFile;
     }
     return nil;
}

+ (NSArray *)allOfflineFileItems
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSArray array];
    }
    
    NSArray *offlineFileItems = [NXOfflineFileItem MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NXOfflineFileItem *offlineFileItem in offlineFileItems) {
        
        NXOfflineFile *offlineFile = [[NXOfflineFile alloc] init];
        offlineFile.sourcePath = offlineFileItem.sourcePath;
        offlineFile.state = offlineFileItem.state.integerValue;
        offlineFile.fileKey = offlineFileItem.fileKey;
        offlineFile.duid = offlineFileItem.duid;
        offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
        offlineFile.isCenterPolicyEncrypted = offlineFileItem.isCenterPolicyEncrypted.boolValue;
        offlineFile.isOffline = YES;
        
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeMyVaultFile){
            offlineFile.sorceType = NXFileBaseSorceTypeMyVaultFile;
            
            NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (myvaultFileItem) {
                offlineFile.name = myvaultFileItem.fileName;
                offlineFile.fullServicePath = myvaultFileItem.fileServicePath;
                offlineFile.fullPath = myvaultFileItem.fileDisplayPath;
                offlineFile.isFavorite = myvaultFileItem.isFavorite.boolValue;
                offlineFile.size = myvaultFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = myvaultFileItem.protectedOn;
                
                if (!offlineFile.lastModifiedDate) {
                     offlineFile.lastModifiedDate = myvaultFileItem.sharedOn;
                }
            }
        }
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeProject){
            offlineFile.sorceType = NXFileBaseSorceTypeProject;
              NXProjectFileItem *projectFileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (projectFileItem) {
                offlineFile.name = projectFileItem.name;
                offlineFile.fullServicePath = projectFileItem.fullServicePath;
                offlineFile.fullPath = projectFileItem.fullPath;
                offlineFile.size = projectFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = projectFileItem.lastModifiedDate;
                offlineFile.lastModifiedTime = projectFileItem.lastModifiedTime;
            }
        }
        
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeShareWithMe){
            offlineFile.sorceType = NXFileBaseSorceTypeShareWithMe;
            NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (sharedWithMeFileItem) {
                offlineFile.name = sharedWithMeFileItem.name;
                offlineFile.fullServicePath = sharedWithMeFileItem.transactionCode;
                offlineFile.size = sharedWithMeFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = sharedWithMeFileItem.shareDate;
            }
        }
        
        if (offlineFileItem.sourceType.integerValue == NXFileBaseSorceTypeSharedWithProject){
                  offlineFile.sorceType = NXFileBaseSorceTypeSharedWithProject;
                  NXSharedWithProjectFileItem *shareWithProjectFileItem = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
                  if (shareWithProjectFileItem) {
                      offlineFile.name = shareWithProjectFileItem.name;
                      offlineFile.fullServicePath = shareWithProjectFileItem.transactionCode;
                      offlineFile.size = shareWithProjectFileItem.size.longLongValue;
                      offlineFile.lastModifiedDate = shareWithProjectFileItem.sharedDate;
                  }
              }
        
        [retArray addObject:offlineFile];
    }
 
    return retArray;
}

+ (NSArray *)allOfflineFileListFromSharedWithMe
{
    if (![NXLoginUser sharedInstance].isLogInState) {
           return [NSArray array];
       }
       NSArray *offlineFiles = [NXOfflineFileItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"sourceType==%d",NXFileBaseSorceTypeShareWithMe]];
       NSMutableArray *retArray = [[NSMutableArray alloc] init];
       for (NXOfflineFileItem *offlineFileItem in offlineFiles) {
           
           NXOfflineFile *offlineFile = [[NXOfflineFile alloc] init];
           offlineFile.sourcePath = offlineFileItem.sourcePath;
           offlineFile.state = offlineFileItem.state.integerValue;
           offlineFile.fileKey = offlineFileItem.fileKey;
           offlineFile.duid = offlineFileItem.duid;
           offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
           offlineFile.isCenterPolicyEncrypted = offlineFileItem.isCenterPolicyEncrypted.boolValue;
           offlineFile.isOffline = YES;
           
           NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (sharedWithMeFileItem){
                offlineFile.sorceType = NXFileBaseSorceTypeShareWithMe;
                offlineFile.name = sharedWithMeFileItem.name;
                offlineFile.fullServicePath = sharedWithMeFileItem.transactionCode;
                offlineFile.size = sharedWithMeFileItem.size.longLongValue;
                offlineFile.lastModifiedDate = sharedWithMeFileItem.shareDate;
            }
                [retArray addObject:offlineFile];
       }
       return retArray;
}

+ (NSArray *)allOfflineFileListFromMyVault
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSArray array];
    }
    NSArray *offlineFiles = [NXOfflineFileItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"sourceType==%d",NXFileBaseSorceTypeMyVaultFile]];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NXOfflineFileItem *offlineFileItem in offlineFiles) {
        
        NXOfflineFile *offlineFile = [[NXOfflineFile alloc] init];
        offlineFile.sourcePath = offlineFileItem.sourcePath;
        offlineFile.state = offlineFileItem.state.integerValue;
        offlineFile.fileKey = offlineFileItem.fileKey;
        offlineFile.duid = offlineFileItem.duid;
        offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
        offlineFile.isCenterPolicyEncrypted = offlineFileItem.isCenterPolicyEncrypted.boolValue;
        offlineFile.isOffline = YES;
        
        NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
        if (myvaultFileItem) {
            offlineFile.name = myvaultFileItem.fileName;
            offlineFile.fullServicePath = myvaultFileItem.fileServicePath;
            offlineFile.fullPath = myvaultFileItem.fileDisplayPath;
            offlineFile.isFavorite = myvaultFileItem.isFavorite.boolValue;
            offlineFile.size = myvaultFileItem.size.longLongValue;
            offlineFile.lastModifiedDate = myvaultFileItem.sharedOn;
            offlineFile.sorceType = NXFileBaseSorceTypeMyVaultFile;
            
            if (!offlineFile.lastModifiedDate) {
                offlineFile.lastModifiedDate = myvaultFileItem.protectedOn;
            }
        }
        
        [retArray addObject:offlineFile];
    }
    
    return retArray;
}

+ (NSArray *)allOfflineFileListFromMyVaultOrSharedWithMe {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSArray array];
    }
    NSArray *offlineFiles = [NXOfflineFileItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"sourceType==%d OR sourceType==%d",NXFileBaseSorceTypeMyVaultFile,NXFileBaseSorceTypeShareWithMe]];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NXOfflineFileItem *offlineFileItem in offlineFiles) {
        
        NXOfflineFile *offlineFile = [[NXOfflineFile alloc] init];
        offlineFile.sourcePath = offlineFileItem.sourcePath;
        offlineFile.state = offlineFileItem.state.integerValue;
        offlineFile.fileKey = offlineFileItem.fileKey;
        offlineFile.duid = offlineFileItem.duid;
        offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
        offlineFile.isCenterPolicyEncrypted = offlineFileItem.isCenterPolicyEncrypted.boolValue;
        offlineFile.isOffline = YES;
            
        NXMyVaultFileItem *myvaultFileItem = [NXMyVaultFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
        if (myvaultFileItem) {
            offlineFile.name = myvaultFileItem.fileName;
            offlineFile.fullServicePath = myvaultFileItem.fileServicePath;
            offlineFile.fullPath = myvaultFileItem.fileDisplayPath;
            offlineFile.isFavorite = myvaultFileItem.isFavorite.boolValue;
            offlineFile.size = myvaultFileItem.size.longLongValue;
            offlineFile.lastModifiedDate = myvaultFileItem.sharedOn;
            offlineFile.sorceType = NXFileBaseSorceTypeMyVaultFile;
            
            if (!offlineFile.lastModifiedDate) {
                offlineFile.lastModifiedDate = myvaultFileItem.protectedOn;
            }
        }
        
        NXShareWithMeFileItem *sharedWithMeFileItem = [NXShareWithMeFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
        if (sharedWithMeFileItem){
            offlineFile.sorceType = NXFileBaseSorceTypeShareWithMe;
            offlineFile.name = sharedWithMeFileItem.name;
            offlineFile.fullServicePath = sharedWithMeFileItem.transactionCode;
            offlineFile.size = sharedWithMeFileItem.size.longLongValue;
            offlineFile.lastModifiedDate = sharedWithMeFileItem.shareDate;
        }
        
        [retArray addObject:offlineFile];
    }
    
    return retArray;
}

+ (NSArray *)allOfflineFileListFromWorkSpace {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSArray array];
    }
    
    NSArray *offlineFiles = [NXOfflineFileItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"sourceType==%d",NXFileBaseSorceTypeWorkSpace]];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NXOfflineFileItem *offlineFileItem in offlineFiles) {
        NXOfflineFile *offlineFile = [[NXOfflineFile alloc] init];
        offlineFile.sourcePath = offlineFileItem.sourcePath;
        offlineFile.state = offlineFileItem.state.integerValue;
        offlineFile.fileKey = offlineFileItem.fileKey;
        offlineFile.duid = offlineFileItem.duid;
        offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
        offlineFile.isCenterPolicyEncrypted = offlineFileItem.isCenterPolicyEncrypted.boolValue;
        offlineFile.isOffline = YES;
        offlineFile.sorceType = NXFileBaseSorceTypeWorkSpace;
        
        NXWorkSpaceFileItem *workSpaceFileItem = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", offlineFileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
        if (workSpaceFileItem) {
            offlineFile.name = workSpaceFileItem.name;
            offlineFile.fullServicePath = workSpaceFileItem.fullServicePath;
            offlineFile.fullPath = workSpaceFileItem.fullPath;
            offlineFile.size = workSpaceFileItem.size.longLongValue;
            offlineFile.lastModifiedDate = workSpaceFileItem.lastModified;
            offlineFile.duid = workSpaceFileItem.duid;
            [retArray addObject:offlineFile];
        }
    }
    return retArray;
}

+ (NSMutableArray *)queryAllOfflineFilesInProject:(NSNumber *)projectId {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableArray array];
    }
    NSMutableArray *fileArray = [NSMutableArray array];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@ AND isOffline==%@", projectId,[NSNumber numberWithBool:YES]];
    NSFetchRequest *request = [NXProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    [request setIncludesPropertyValues:YES];
    [request setReturnsObjectsAsFaults:NO];
    [request setIncludesPendingChanges:YES];
    [request setPredicate:predicate];
    NSArray *fetArray = [NXProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    [fetArray enumerateObjectsUsingBlock:^(NXProjectFileItem *fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
        NXOfflineFile *offlineFile = [[NXOfflineFile alloc]init];
        offlineFile.sourcePath = offlineFileItem.sourcePath;
        offlineFile.state = offlineFileItem.state.integerValue;
        offlineFile.fileKey = offlineFileItem.fileKey;
        offlineFile.duid = offlineFileItem.duid;
        offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
        offlineFile.isCenterPolicyEncrypted = offlineFileItem.isCenterPolicyEncrypted.boolValue;
        offlineFile.isOffline = YES;
        offlineFile.sorceType = NXFileBaseSorceTypeProject;
        offlineFile.name = fileItem.name;
        offlineFile.fullServicePath = fileItem.fullServicePath;
        offlineFile.fullPath = fileItem.fullPath;
        offlineFile.size = fileItem.size.longLongValue;
        offlineFile.lastModifiedDate = fileItem.lastModifiedDate;
        offlineFile.lastModifiedTime = fileItem.lastModifiedTime;
        [fileArray addObject:offlineFile];
    }];
    
      NSMutableArray *shareWithfileArray = [NSMutableArray array];
       NSPredicate *shareWithpredicate = [NSPredicate predicateWithFormat:@"project.projectId==%@ AND isOffline==%@", projectId,[NSNumber numberWithBool:YES]];
       NSFetchRequest *shareWithRequest = [NXSharedWithProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
       [shareWithRequest setIncludesPropertyValues:YES];
       [shareWithRequest setReturnsObjectsAsFaults:NO];
       [shareWithRequest setIncludesPendingChanges:YES];
       [shareWithRequest setPredicate:shareWithpredicate];
       NSArray *shareWithfetArray = [NXSharedWithProjectFileItem MR_executeFetchRequest:shareWithRequest inContext:[NSManagedObjectContext MR_defaultContext]];
    
    [shareWithfetArray enumerateObjectsUsingBlock:^(NXSharedWithProjectFileItem *fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
           NXOfflineFileItem *offlineFileItem = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileItem.fileKey] inContext:[NSManagedObjectContext MR_defaultContext]];
           NXOfflineFile *offlineFile = [[NXOfflineFile alloc]init];
           offlineFile.sourcePath = offlineFileItem.sourcePath;
           offlineFile.state = offlineFileItem.state.integerValue;
           offlineFile.fileKey = offlineFileItem.fileKey;
           offlineFile.duid = offlineFileItem.duid;
           offlineFile.markAsOfflineDate = offlineFileItem.markAsOfflineDate;
           offlineFile.isCenterPolicyEncrypted = offlineFileItem.isCenterPolicyEncrypted.boolValue;
           offlineFile.isOffline = YES;
           offlineFile.sorceType = NXFileBaseSorceTypeSharedWithProject;
           offlineFile.name = fileItem.name;
           offlineFile.fullServicePath = fileItem.transactionCode;
           offlineFile.size = fileItem.size.longLongValue;
           offlineFile.lastModifiedDate = fileItem.sharedDate;
           [shareWithfileArray addObject:offlineFile];
       }];
    
    if (shareWithfileArray.count > 0) {
        [fileArray addObjectsFromArray:shareWithfileArray];
    }
    
    return fileArray;
}
+(BOOL)hasConvertFailedOfflineFile
{
    BOOL hasConvertFailedOfflineFile = NO;
    NSArray *offlineFileItems = [NXOfflineFileItem MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    if (offlineFileItems.count > 0) {
        for (NXOfflineFileItem *offlineFileItem in offlineFileItems) {
            if (offlineFileItem.state.integerValue == NXFileStateOfflineFailed) {
                hasConvertFailedOfflineFile =  YES;
                break;
            }
        }
    }
    return hasConvertFailedOfflineFile;
}

@end
