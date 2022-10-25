//
//  NXWorkSpaceStorage.m
//  nxrmc
//
//  Created by Eren on 2019/9/26.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceStorage.h"
#import "MagicalRecord.h"
#import "NXWorkSpaceFileItem+CoreDataClass.h"
#import "NXWorkSpaceFileUploader+CoreDataClass.h"
#import "NXWorkSpaceFileLastModifiedUser+CoreDataClass.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXOfflineFileItem+CoreDataClass.h"

@implementation NXWorkSpaceStorage
+ (void)insertWorkSpaceFiles:(NSArray *)files toFolder:(NXFolder *)parentFolder {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NXFileBase *fileItem in files) {
            NSAssert([fileItem isKindOfClass:[NXWorkSpaceFolder class]] || [fileItem isKindOfClass:[NXWorkSpaceFile class]], @"NXWorkSpaceStorage param error");
            NXWorkSpaceFileItem *workSpaceFileItem = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fullServicePath==%@", fileItem.fullServicePath] inContext:localContext];
            if (!workSpaceFileItem) {
                workSpaceFileItem = [NXWorkSpaceFileItem MR_createEntityInContext:localContext];
            }
            workSpaceFileItem.fileKey = [NXCommonUtils fileKeyForFile:fileItem];
            workSpaceFileItem.name = fileItem.name;
            workSpaceFileItem.fullPath = fileItem.fullPath;
            workSpaceFileItem.fullServicePath = fileItem.fullServicePath;
            workSpaceFileItem.creationTime = fileItem.creationDate;
            workSpaceFileItem.lastModified = fileItem.lastModifiedDate;
            workSpaceFileItem.size = [NSNumber numberWithLongLong:fileItem.size];
            if (!workSpaceFileItem.uploader) {
                workSpaceFileItem.uploader = [NXWorkSpaceFileUploader MR_createEntityInContext:localContext];
            }
            
            if ([fileItem isKindOfClass:[NXWorkSpaceFolder class]]) {
                workSpaceFileItem.folder = [NSNumber numberWithBool:YES];
                NXWorkSpaceFolder *workSpaceFolder = (NXWorkSpaceFolder *)fileItem;
                workSpaceFileItem.uploader.dispalyName = workSpaceFolder.fileUploader.displayName;
                workSpaceFileItem.uploader.userId = [NSNumber numberWithInteger:workSpaceFolder.fileUploader.userId];
                workSpaceFileItem.uploader.email = workSpaceFolder.fileUploader.email;
                workSpaceFileItem.uploader.workSpaceFile = workSpaceFileItem;
            }else if([fileItem isKindOfClass:[NXWorkSpaceFile class]]) {
                workSpaceFileItem.folder = [NSNumber numberWithBool:NO];
                NXWorkSpaceFile *workSpaceFile = (NXWorkSpaceFile *)fileItem;
                workSpaceFileItem.uploader.dispalyName = workSpaceFile.fileUploader.displayName;
                workSpaceFileItem.uploader.userId = [NSNumber numberWithInteger:workSpaceFile.fileUploader.userId];
                workSpaceFileItem.uploader.email = workSpaceFile.fileUploader.email;
                workSpaceFileItem.uploader.workSpaceFile = workSpaceFileItem;
                if (!workSpaceFileItem.lastModifedUser) {
                    workSpaceFileItem.lastModifedUser = [NXWorkSpaceFileLastModifiedUser MR_createEntityInContext:localContext];
                }
                workSpaceFileItem.lastModifedUser.displayName = workSpaceFile.fileModifiedUser.displayName;
                workSpaceFileItem.lastModifedUser.userId = [NSNumber numberWithInteger:workSpaceFile.fileModifiedUser.userId];
                workSpaceFileItem.lastModifedUser.email = workSpaceFile.fileModifiedUser.email;
                workSpaceFileItem.lastModifedUser.workSpaceFile = workSpaceFileItem;
                workSpaceFileItem.duid = workSpaceFile.duid;
            }
            
            // create parent and child relationship
            if (!parentFolder.isRoot) {
                NXWorkSpaceFileItem *parentFileItem = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fullServicePath=%@", parentFolder.fullServicePath] inContext:localContext];
                [parentFileItem addChildFileItemObject:workSpaceFileItem];
                [workSpaceFileItem setParentFileItem:parentFileItem];
            }
            
            // check if workSpace file is off
               NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:localContext];
               if (offlineFile) {
                   fileItem.isOffline = [NSNumber numberWithBool:YES];
                   offlineFile.workSpaceFilePartner = workSpaceFileItem;
                   workSpaceFileItem.offlineFilePartner = offlineFile;
                   workSpaceFileItem.isOfflineLine = [NSNumber numberWithBool:YES];
               }
        }
    }];
}
+ (void)insertWorkSpaceFileItem:(NXFileBase *)fileItem toParentFolder:(NXFolder *)parentFolder {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSArray *itemArray = @[fileItem];
    [NXWorkSpaceStorage insertWorkSpaceFiles:itemArray toFolder:parentFolder];
}

+(NXFileBase *)parentFolderForFileItem:(NXFileBase *)fileItem {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NXWorkSpaceFileItem *workSpaceFileItem = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", [NXCommonUtils fileKeyForFile:fileItem]] inContext:[NSManagedObjectContext MR_defaultContext]];
    __block NXFileBase *parentFileItem = nil;
    dispatch_main_sync_safe(^{
        if (workSpaceFileItem) {
            parentFileItem = (NXFileBase *)workSpaceFileItem.parentFileItem;
            if (parentFileItem) {
                NXWorkSpaceFileItemUploader *uploader = [[NXWorkSpaceFileItemUploader alloc] init];
                uploader.displayName = workSpaceFileItem.uploader.dispalyName;
                uploader.userId = workSpaceFileItem.uploader.userId.integerValue;
                uploader.email = workSpaceFileItem.uploader.email;
                parentFileItem = [[NXWorkSpaceFolder alloc] init];
                ((NXWorkSpaceFolder *)parentFileItem).fileUploader = uploader;
                parentFileItem.lastModifiedDate = workSpaceFileItem.lastModified;
                parentFileItem.creationDate = workSpaceFileItem.creationTime;
                parentFileItem.fullPath = workSpaceFileItem.fullPath;
                parentFileItem.fullServicePath = workSpaceFileItem.fullServicePath;
                parentFileItem.size = workSpaceFileItem.size.longLongValue;
            }else{ // means root folder
                parentFileItem = [[NXLoginUser sharedInstance].workSpaceManager rootFolderForWorkSpace];
            }
        }
    });
    return parentFileItem;
}

#pragma mark -----> Delete file form workspace
+ (void)deleteWorkSpaceFileItem:(NXFileBase *)fileItem {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
     NSAssert([fileItem isKindOfClass:[NXWorkSpaceFolder class]] || [fileItem isKindOfClass:[NXWorkSpaceFile class]], @"NXWorkSpaceStorage param error");
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        [NXWorkSpaceFileItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"fullServicePath==%@", fileItem.fullServicePath] inContext:localContext];
    }];
}

#pragma mark ----->Query project file for workspace
+ (NSMutableArray *)queryWorkSpaceFilesUnderFolder:(NXFolder *)parentFolder {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    NSPredicate *predicate = nil;
    if (parentFolder.isRoot) {
        predicate = [NSPredicate predicateWithFormat:@"parentFileItem==nil"];
    }else {
        predicate = [NSPredicate predicateWithFormat:@"parentFileItem.fullServicePath==%@", ((NXWorkSpaceFolder *)parentFolder).fullServicePath];
    }
    NSArray *fileListArray = [NXWorkSpaceFileItem MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXWorkSpaceFileItem *workSpaceFileItem in fileListArray) {
        NXFileBase *fileItem = nil;
        
        NXWorkSpaceFileItemUploader *uploader = [[NXWorkSpaceFileItemUploader alloc] init];
        uploader.displayName = workSpaceFileItem.uploader.dispalyName;
        uploader.userId = workSpaceFileItem.uploader.userId.integerValue;
        uploader.email = workSpaceFileItem.uploader.email;
        
        if (workSpaceFileItem.folder.boolValue) {
            fileItem = [[NXWorkSpaceFolder alloc] init];
            ((NXWorkSpaceFolder *)fileItem).fileUploader = uploader;
            
        }else {
            fileItem = [[NXWorkSpaceFile alloc] init];
            ((NXWorkSpaceFile *)fileItem).fileUploader = uploader;
            ((NXWorkSpaceFile *)fileItem).duid = workSpaceFileItem.duid;
            NXWorkSpaceFileItemLastModifiedUser *modifiedUser = [[NXWorkSpaceFileItemLastModifiedUser alloc] init];
            modifiedUser.displayName = workSpaceFileItem.lastModifedUser.displayName;
            modifiedUser.userId = workSpaceFileItem.lastModifedUser.userId.integerValue;
            modifiedUser.email = workSpaceFileItem.lastModifedUser.email;
            fileItem.isOffline = workSpaceFileItem.isOfflineLine.boolValue;
        }
        fileItem.name = workSpaceFileItem.name;
        fileItem.lastModifiedDate = workSpaceFileItem.lastModified;
        fileItem.creationDate = workSpaceFileItem.creationTime;
        fileItem.fullPath = workSpaceFileItem.fullPath;
        fileItem.fullServicePath = workSpaceFileItem.fullServicePath;
        fileItem.size = workSpaceFileItem.size.longLongValue;
        [resultArray addObject:fileItem];
    }
    return resultArray;
}

+ (NXWorkSpaceFile *)queryWorkSpaceFileByFileKey:(NSString *)fileKey {
    if (![NXLoginUser sharedInstance].isLogInState) {
           return nil;
    }
    __block NXWorkSpaceFile *workSpaceFile = nil;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXWorkSpaceFileItem *workSpaceFileItem = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
        if (workSpaceFileItem) {
            workSpaceFile = [[NXWorkSpaceFile alloc] init];
            NXWorkSpaceFileItemUploader *uploader = [[NXWorkSpaceFileItemUploader alloc] init];
            uploader.displayName = workSpaceFileItem.uploader.dispalyName;
            uploader.userId = workSpaceFileItem.uploader.userId.integerValue;
            uploader.email = workSpaceFileItem.uploader.email;
            workSpaceFile.fileUploader = uploader;
            
            NXWorkSpaceFileItemLastModifiedUser *modifiedUser = [[NXWorkSpaceFileItemLastModifiedUser alloc] init];
            modifiedUser.displayName = workSpaceFileItem.lastModifedUser.displayName;
            modifiedUser.userId = workSpaceFileItem.lastModifedUser.userId.integerValue;
            modifiedUser.email = workSpaceFileItem.lastModifedUser.email;
            workSpaceFile.fileModifiedUser = modifiedUser;
            
            workSpaceFile.isOffline = workSpaceFileItem.isOfflineLine.boolValue;
            
            workSpaceFile.name = workSpaceFileItem.name;
            workSpaceFile.lastModifiedDate = workSpaceFileItem.lastModified;
            workSpaceFile.creationDate = workSpaceFileItem.creationTime;
            workSpaceFile.fullPath = workSpaceFileItem.fullPath;
            workSpaceFile.fullServicePath = workSpaceFileItem.fullServicePath;
            workSpaceFile.size = workSpaceFileItem.size.longLongValue;
            workSpaceFile.duid = workSpaceFileItem.duid;
        }
    }];
    return workSpaceFile;
}

#pragma mark ----->update projectFileItem in coredata
+(void)updateWorkSpaceFileItem:(NXFileBase *)fileItem {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSAssert([fileItem isKindOfClass:[NXWorkSpaceFolder class]] || [fileItem isKindOfClass:[NXWorkSpaceFile class]], @"NXWorkSpaceStorage param error");
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXWorkSpaceFileItem *workSpaceFileItem = [NXWorkSpaceFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fullServicePath==%@", fileItem.fullServicePath] inContext:localContext];
        if (workSpaceFileItem) {
            workSpaceFileItem.name = fileItem.name;
            workSpaceFileItem.fullPath = fileItem.fullPath;
            workSpaceFileItem.fullServicePath = fileItem.fullServicePath;
            workSpaceFileItem.creationTime = fileItem.creationDate;
            workSpaceFileItem.lastModified = fileItem.lastModifiedDate;
            
            // do not need update duid, because NXWorkSpaceFileMetaDataAPI didn't reutrn duid
//            if ([fileItem isKindOfClass:[NXWorkSpaceFile class]]) {
//                workSpaceFileItem.duid = ((NXWorkSpaceFile *)fileItem).duid;
//            }
            
            if ([fileItem isKindOfClass:[NXWorkSpaceFile class]] && ((NXWorkSpaceFile *)fileItem).fileUploader) {
                if (workSpaceFileItem.uploader == nil) {
                    NXWorkSpaceFileUploader *uploader = [NXWorkSpaceFileUploader MR_createEntityInContext:localContext];
                    uploader.userId = [NSNumber numberWithInteger:((NXWorkSpaceFile *)fileItem).fileUploader.userId];
                    uploader.dispalyName = ((NXWorkSpaceFile *)fileItem).fileUploader.displayName;
                    uploader.email = ((NXWorkSpaceFile *)fileItem).fileUploader.email;
                    workSpaceFileItem.uploader = uploader;
                    uploader.workSpaceFile = workSpaceFileItem;
                }
            }
            if ([fileItem isKindOfClass:[NXWorkSpaceFile class]] && ((NXWorkSpaceFile *)fileItem).fileModifiedUser) {
                if (workSpaceFileItem.lastModifedUser == nil) {
                    NXWorkSpaceFileLastModifiedUser *lastModifiedUser = [NXWorkSpaceFileLastModifiedUser MR_createEntityInContext:localContext];
                    lastModifiedUser.userId = [NSNumber numberWithInteger:((NXWorkSpaceFile *)fileItem).fileModifiedUser.userId];
                    lastModifiedUser.displayName = ((NXWorkSpaceFile *)fileItem).fileModifiedUser.displayName;
                    lastModifiedUser.email = ((NXWorkSpaceFile *)fileItem).fileModifiedUser.email;
                    workSpaceFileItem.lastModifedUser = lastModifiedUser;
                    lastModifiedUser.workSpaceFile = workSpaceFileItem;
                }
                
                if (workSpaceFileItem.lastModifedUser && workSpaceFileItem.lastModifedUser.userId.integerValue != ((NXWorkSpaceFile *)fileItem).fileModifiedUser.userId) {
                    workSpaceFileItem.lastModifedUser.userId = [NSNumber numberWithInteger:((NXWorkSpaceFile *)fileItem).fileModifiedUser.userId];
                    workSpaceFileItem.lastModifedUser.displayName = ((NXWorkSpaceFile *)fileItem).fileModifiedUser.displayName;
                    workSpaceFileItem.lastModifedUser.email = ((NXWorkSpaceFile *)fileItem).fileModifiedUser.email;
                }
            }
            
            if ([fileItem isKindOfClass:[NXWorkSpaceFolder class]] && ((NXWorkSpaceFolder *)fileItem).fileUploader) {
                if (workSpaceFileItem.uploader == nil) {
                    NXWorkSpaceFileUploader *uploader = [NXWorkSpaceFileUploader MR_createEntityInContext:localContext];
                    uploader.userId = [NSNumber numberWithInteger:((NXWorkSpaceFolder *)fileItem).fileUploader.userId];
                    uploader.dispalyName = ((NXWorkSpaceFolder *)fileItem).fileUploader.displayName;
                    uploader.email = ((NXWorkSpaceFolder *)fileItem).fileUploader.email;
                    workSpaceFileItem.uploader = uploader;
                    uploader.workSpaceFile = workSpaceFileItem;
                }
            }
            
        }
    }];
}
@end
