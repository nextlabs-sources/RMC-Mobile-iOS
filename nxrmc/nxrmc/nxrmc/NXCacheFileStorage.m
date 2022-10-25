//
//  NXCacheFileStorage.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/21/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXCacheFileStorage.h"
#import "MagicalRecord.h"
#import "NXCacheManager.h"
#import "NXLProfile.h"
@implementation NXCacheFileStorage
+ (void)storeCacheFileIntoCoreData: (NXFileBase *)fileBase cachePath :(NSString*) cPath
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:fileBase.repoId];
    NSURL* url = [NSURL fileURLWithPath:cPath];
    NSNumber* fileSize = nil;
    NSError* err = nil;
    [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&err];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXCacheFile *cachedFile = [NXCacheFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user_id = %@ AND service_id = %@ AND cache_path= %@", [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId], NXREST_UUID(repoModel), cPath] inContext:localContext];
        if (cachedFile) {
            cachedFile.cached_time = [NSDate date];
            cachedFile.access_time = [NSDate date];
            cachedFile.cache_size = fileSize;
            cachedFile.offline_flag = [NSNumber numberWithBool:fileBase.isOffline];
            cachedFile.favorite_flag = [NSNumber numberWithBool:fileBase.isFavorite];
            cachedFile.cache_path = cPath;
        }else{
            NXCacheFile *newCacheFile = [NXCacheFile MR_createEntityInContext:localContext];
            newCacheFile.user_id = [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId];
            newCacheFile.service_id = NXREST_UUID(repoModel);
            newCacheFile.source_path = fileBase.fullServicePath;
            newCacheFile.cache_path = cPath;
            newCacheFile.cached_time = [NSDate date];
            newCacheFile.access_time = [NSDate date];
            newCacheFile.cache_size = fileSize;
            newCacheFile.offline_flag = [NSNumber numberWithBool:fileBase.isOffline];
            newCacheFile.favorite_flag = [NSNumber numberWithBool:fileBase.isFavorite];
            newCacheFile.safe_path = @"";
        }
    }];
    
    //when file is offline flag change, when should move file from folder to anther folder.
    [NXCacheManager cacheFile:fileBase localPath:cPath];
}

+ (void)storeCacheFileIntoCoreData: (NXFileBase *)fileBase forFileKey :(NSString*) fileKey
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXCacheFile *newCacheFile = [NXCacheFile MR_createEntityInContext:localContext];
        newCacheFile.cache_path = fileBase.localPath;
        newCacheFile.access_time = fileBase.lastModifiedDate;
        newCacheFile.safe_path = fileKey;
    }];
}

+ (void)updateCacheFileInCoreData:(NXFileBase *)fileBase forFileKey:(NSString *)fileKey
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXCacheFile *cacheFile = [NXCacheFile MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"safe_path = %@", fileKey] inContext:localContext];
        if (cacheFile) {
            cacheFile.access_time = fileBase.lastModifiedDate;
            cacheFile.cache_path = fileBase.localPath;
        }else{
            [self storeCacheFileIntoCoreData:fileBase cachePath:fileKey];
        }
    }];
}
+ (NXCacheFile*) getCacheFile: (NXFileBase *) file
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NXRepositoryModel *service = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:file];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id=%@ AND service_id=%@ AND source_path=%@", [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId], NXREST_UUID(service), file.fullServicePath];
   
    NXCacheFile *cachedFile = [NXCacheFile MR_findFirstWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    if (cachedFile) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachedFile.cache_path]) {
            // cache file doesn't exist, maybe deleted by ios. then need to delete record in cache table.
            [self deleteCacheFileFromCoreData:cachedFile];
            return nil;
        }
    }
    return cachedFile;
}

+ (NXCacheFile *)queryCacheFileForFileKey:(NSString *)fileKey
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"safe_path=%@", fileKey];
    NXCacheFile *cacheFile = [NXCacheFile MR_findFirstWithPredicate:predicate];
    return cacheFile;
}

+ (void) deleteCacheFileFromCoreData: (NXCacheFile*) cacheFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    if (cacheFile) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            NXCacheFile *localCacheFile = [cacheFile MR_inContext:localContext];
            [localCacheFile MR_deleteEntityInContext:localContext];
        }];
    }
}

+ (void) deleteCacheFilesFromCoreDataForRepo: (NXRepositoryModel*) repo
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    if (repo) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NSArray* objects = [NXCacheFile MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"user_id=%@ AND service_id=%@", repo.user_id, NXREST_UUID(repo)] inContext:localContext];
                for (NXCacheFile* file in objects) {
                    if (![file.offline_flag boolValue]) {
                        [file MR_deleteEntity];
                    }
                }
            }];
        }];
    }
}
+ (void) deleteAllCacheFilesFromCoreData
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSArray *boundServices = [[NXLoginUser sharedInstance].myRepoSystem allReposiories];
    for (NXRepositoryModel *service in boundServices) {
        [self deleteCacheFilesFromCoreDataForRepo:service];
    }
}
@end
