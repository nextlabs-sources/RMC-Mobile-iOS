//
//  NXSharedWithProjectStorage.m
//  nxrmc
//
//  Created by 时滕 on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFileStorage.h"
#import "NXLoginUser.h"
#import "MagicalRecord.h"
#import "NXCommonUtils.h"
#import "NXSharedWithProjectFileItem+CoreDataClass.h"
#import "NXProjectItem+CoreDataClass.h"
#import "NXOfflineFileItem+CoreDataClass.h"

@implementation NXSharedWithProjectFileStorage
+ (void)insertSharedFiles:(NSArray<NXSharedWithProjectFile *> *)fileList intoProject:(NXProjectModel *)project {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        for (NXSharedWithProjectFile *sharedWithProjectFile in fileList) {
            NSString *fileKey = [NXCommonUtils fileKeyForFile:sharedWithProjectFile];
            
            NXSharedWithProjectFileItem *sharedWithFileItem = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
            
            if (!sharedWithFileItem) {
                sharedWithFileItem = [NXSharedWithProjectFileItem  MR_createEntityInContext:localContext];
            }
            sharedWithFileItem.duid = sharedWithProjectFile.duid;
            sharedWithFileItem.transactionId = sharedWithProjectFile.transactionId;
            sharedWithFileItem.name = sharedWithProjectFile.name;
            sharedWithFileItem.fileType = sharedWithProjectFile.fileType;
            sharedWithFileItem.size = [NSNumber numberWithLongLong:sharedWithProjectFile.size];
            sharedWithFileItem.sharedDate = [NSDate dateWithTimeIntervalSince1970: sharedWithProjectFile.sharedDate];
            sharedWithFileItem.sharedByProject = sharedWithProjectFile.sharedByProject;
            sharedWithFileItem.sharedBy = sharedWithProjectFile.sharedBy;
            sharedWithFileItem.transactionId = sharedWithProjectFile.transactionId;
            sharedWithFileItem.transactionCode = sharedWithProjectFile.transactionCode;
            sharedWithFileItem.sharedLink = sharedWithProjectFile.sharedLink;
            sharedWithFileItem.rights = [NSJSONSerialization dataWithJSONObject:sharedWithProjectFile.rights options:NSJSONWritingPrettyPrinted error:nil];
            sharedWithFileItem.comment = sharedWithProjectFile.reshareComment;
            sharedWithFileItem.isOwner = [NSNumber numberWithBool:sharedWithProjectFile.isOwner];
            sharedWithFileItem.spaceId = sharedWithProjectFile.spaceId;
            sharedWithFileItem.fileKey = fileKey;
            sharedWithFileItem.lastModified = sharedWithProjectFile.lastModified;
            
            // make connection between project and shared file
            NXProjectItem *projectItem = [NXProjectItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId=%@", project.projectId] inContext:localContext];
            sharedWithFileItem.project = projectItem;
            [projectItem addSharedFilesObject:sharedWithFileItem];
            
            // check if myVault file is off
              NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
              if (offlineFile) {
                  sharedWithFileItem.isOffline = [NSNumber numberWithBool:YES];
                  offlineFile.shareWithProjectFileParter = sharedWithFileItem;
                  sharedWithFileItem.offlineFilePartner = offlineFile;
              }
        }
    }];
}

+ (NSArray<NXSharedWithProjectFile *> *)querySharedFileListFromProject:(NXProjectModel *)project {
    if (![NXLoginUser sharedInstance].isLogInState) {
         return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"project.projectId==%@", project.projectId] ;
    NSFetchRequest *request = [NXSharedWithProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    [request setIncludesPropertyValues:YES];
    [request setReturnsObjectsAsFaults:NO];
    [request setIncludesPendingChanges:YES];
    [request setPredicate:predicate];
    NSArray *fetchResult = [NXSharedWithProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *sharedWithProjectFileArray = [[NSMutableArray alloc] init];
    for (NXSharedWithProjectFileItem *shareWithProjectFileItem in fetchResult) {
        @autoreleasepool {
            NXSharedWithProjectFile *sharedWithProjectFile = [self convertStorageDataToSharedWithProjectFile:shareWithProjectFileItem inProject:project];
            [sharedWithProjectFileArray addObject:sharedWithProjectFile];
        }
    }
     return sharedWithProjectFileArray;
}

+ (NXSharedWithProjectFile *)querySharedFileProjectFileByFileKey:(NSString *)fileKey{
    if (![NXLoginUser sharedInstance].isLogInState) {
            return nil;
       }
      __block NXSharedWithProjectFile *shareWithProjectFile = nil;
         [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
             NXSharedWithProjectFileItem *shareWithProjectFileItem = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
             if (shareWithProjectFileItem) {
                 shareWithProjectFile.name = shareWithProjectFileItem.name;
                 shareWithProjectFile.size = shareWithProjectFileItem.size.longLongValue;
                 shareWithProjectFile.duid = shareWithProjectFileItem.duid;
                 shareWithProjectFile.isOwner = shareWithProjectFileItem.isOwner;
                 shareWithProjectFile.sharedBy = shareWithProjectFileItem.sharedBy;
                 shareWithProjectFile.sharedDate = [shareWithProjectFileItem.sharedDate timeIntervalSince1970];
                 shareWithProjectFile.sharedLink = shareWithProjectFileItem.sharedLink;
                 shareWithProjectFile.transactionId = shareWithProjectFileItem.transactionId;
                 shareWithProjectFile.transactionCode = shareWithProjectFileItem.transactionCode;
                 shareWithProjectFile.sharedByProject = shareWithProjectFileItem.sharedByProject;
                 shareWithProjectFile.spaceId = shareWithProjectFileItem.spaceId;
                 shareWithProjectFile.fullServicePath = shareWithProjectFileItem.transactionCode;
                 shareWithProjectFile.lastModified = shareWithProjectFileItem.lastModified;
             }
         }];
         return shareWithProjectFile;
}

+ (void)deleteSharedWithProjectFile:(NXSharedWithProjectFile *)fileItem {
    if (![NXLoginUser sharedInstance].isLogInState) {
            return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NXSharedWithProjectFileItem *sharedWithProjectFileItem = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
        
        if (sharedWithProjectFileItem) {
            [sharedWithProjectFileItem MR_deleteEntityInContext:localContext];
        }
    }];
}

#pragma -mark - CONVERT METHOD
+ (NXSharedWithProjectFile *)convertStorageDataToSharedWithProjectFile:(NXSharedWithProjectFileItem *)storageSharedWithProjectFileItem inProject:(NXProjectModel *)project
{
    NXSharedWithProjectFile *sharedWithProjectFile = [[NXSharedWithProjectFile alloc] init];
    sharedWithProjectFile.duid = storageSharedWithProjectFileItem.duid;
    sharedWithProjectFile.name = storageSharedWithProjectFileItem.name;
    sharedWithProjectFile.fileType = storageSharedWithProjectFileItem.fileType;
    sharedWithProjectFile.size = storageSharedWithProjectFileItem.size.longLongValue;
    sharedWithProjectFile.sharedDate = [storageSharedWithProjectFileItem.sharedDate timeIntervalSince1970];
    sharedWithProjectFile.sharedBy = storageSharedWithProjectFileItem.sharedBy;
    sharedWithProjectFile.sharedByProject = storageSharedWithProjectFileItem.sharedByProject;
    sharedWithProjectFile.transactionId = storageSharedWithProjectFileItem.transactionId;
    sharedWithProjectFile.transactionCode = storageSharedWithProjectFileItem.transactionCode;
    sharedWithProjectFile.rights = [NSKeyedUnarchiver unarchiveObjectWithData:storageSharedWithProjectFileItem.rights];
    sharedWithProjectFile.comment = storageSharedWithProjectFileItem.comment;
    sharedWithProjectFile.isOwner = storageSharedWithProjectFileItem.isOwner.boolValue;
    sharedWithProjectFile.sorceType = NXFileBaseSorceTypeSharedWithProject;
    sharedWithProjectFile.fullServicePath = storageSharedWithProjectFileItem.transactionCode;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:storageSharedWithProjectFileItem.sharedDate];
    sharedWithProjectFile.lastModifiedTime = strDate;
    sharedWithProjectFile.lastModifiedDate = storageSharedWithProjectFileItem.sharedDate;
    sharedWithProjectFile.sharedProject = project;
   // sharedWithProjectFile.spaceId = project.projectId.stringValue;
    sharedWithProjectFile.spaceId = storageSharedWithProjectFileItem.spaceId;
    sharedWithProjectFile.lastModified = storageSharedWithProjectFileItem.lastModified;
    if (sharedWithProjectFile.lastModified) {
        long long lastModified =  sharedWithProjectFile.lastModified.longLongValue/1000;
        sharedWithProjectFile.lastModifiedTime = [NSString stringWithFormat:@"%0lld", lastModified];
        sharedWithProjectFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:lastModified];
    }else {
        sharedWithProjectFile.lastModifiedTime = [NSString stringWithFormat:@"%f",sharedWithProjectFile.sharedDate];
        sharedWithProjectFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:sharedWithProjectFile.sharedDate];
    }
    
    return sharedWithProjectFile;
}
+ (void)updateSharedWithProjectFile:(NXSharedWithProjectFile *)file {
    if (![NXLoginUser sharedInstance].isLogInState) {
            return;
    }
     NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXSharedWithProjectFileItem *fileItem = [NXSharedWithProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@",fileKey] inContext:localContext];
        if (fileItem) {
            fileItem.sharedDate = [NSDate dateWithTimeIntervalSince1970: file.sharedDate];
        }
    }];
 
}
@end
