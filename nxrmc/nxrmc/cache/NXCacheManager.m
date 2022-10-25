//
//  NXCacheManager.m
//  nxrmc
//
//  Created by Kevin on 15/5/14.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXCacheManager.h"


#import "NXLoginUser.h"

#import "NXCommonUtils.h"
#import "NXGoogleDrive.h"
#import "NXLProfile.h"
@implementation NXCacheManager



+ (NSURL *) cacheRESTReq:(NXSuperRESTAPIRequest *) restAPI cacheURL:(NSURL *) cacheURL
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:restAPI];
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
    NSString *fileName = [[restAPI.reqFlag componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    cacheURL = [cacheURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileName, NXREST_CACHE_EXTENSION]];
    [data writeToURL:cacheURL atomically:YES];
    return cacheURL;
}

+ (void) deleteCachedRESTReq:(NXSuperRESTAPIRequest *)restAPI cacheURL:(NSURL *)cacheURL
{
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
    NSString *fileName = [[restAPI.reqFlag componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    cacheURL = [cacheURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileName, NXREST_CACHE_EXTENSION]];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:&error];
}

+ (void) cacheRESTReq:(NXSuperRESTAPIRequest *)restAPI directlyCacheURL:(NSURL *)cacheURL
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:restAPI];
    [data writeToURL:cacheURL atomically:YES];
}

+ (void) deleteCachedRESTByURL:(NSURL *)cacheURL
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:&error];
}

+(NSURL *) getLogCacheURL
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // cache format
    // document/rms service/user sid/rest cache/LogRest/
    cacheUrl = [[[[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId] URLByAppendingPathComponent:@"restCache"] URLByAppendingPathComponent:@"LogRest"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    return cacheUrl;
}

+ (NSURL *) getFavOfflineRESTCacheURL
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    cacheUrl = [[[[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId] URLByAppendingPathComponent:@"restCache"] URLByAppendingPathComponent:@"FavOfflineRest"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    return cacheUrl;
}

+ (NSURL *) getProjectMembersRESTCacheURL
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    if ([NXLoginUser sharedInstance].profile) {
       cacheUrl = [[[[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId] URLByAppendingPathComponent:@"restCache"] URLByAppendingPathComponent:@"ProjectMemberREST"]; 
    }
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    return cacheUrl;
}

+ (NSURL *) getProjectPendingMembersRESTCacheURL
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    if ([NXLoginUser sharedInstance].profile) {
    cacheUrl = [[[[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId] URLByAppendingPathComponent:@"restCache"] URLByAppendingPathComponent:@"ProjectPendingMemberREST"];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    return cacheUrl;
}

+(NSURL *) getRESTCacheURL
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // cache format
    // document/rms service/user sid/rest cache
    cacheUrl = [[[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId] URLByAppendingPathComponent:@"restCache"];
    
//    cacheUrl = [[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.sid];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }

    return cacheUrl;
}

+ (NSURL *) getSharingRESTCacheURL
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // cache format
    // document/rms service/user sid/rest cache/SharingREST/
    cacheUrl = [[[[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId] URLByAppendingPathComponent:@"restCache"] URLByAppendingPathComponent:@"SharingREST"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    
    return cacheUrl;

}

+ (NSURL *) getHeartbeatCacheURL {
    if ([NXLoginUser sharedInstance].profile.rmserver && [NXLoginUser sharedInstance].profile.userId) {
        NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        // cache format
        // document/rms service/user sid/rest cache/SharingREST/
        cacheUrl = [[[cacheUrl URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.rmserver] URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId] URLByAppendingPathComponent:@"heartbeat"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
            NSError* error = nil;
            BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
            if (!rt) {
                NSLog(@"create folder failed, %@, %@", cacheUrl, error);
                return nil;
            }
        }
        return cacheUrl;
    }else
    {
        return nil;
    }
   
}

+ (void) cacheDirectory:(ServiceType)type serviceAccountId:(NSString*)sid directory:(NXFileBase *)directory
{

    NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:directory];
    NSURL* url = [self getSafeLocalUrlForServiceCache:repoModel];
    if (!url) {
        return;
    }
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:directory];
    
    
    BOOL result = [data writeToURL:[url URLByAppendingPathComponent:CACHEDIRECTORY] atomically:YES];
    if (result) {
        NSLog(@"Cache file system tree OK!");
    }else
    {
        NSLog(@"Cache file system tree failed!");
    }
    
}

+ (void)cacheFileSystemTree:(NXFileBase *) rootFolder forRepository:(NXRepositoryModel *)repo
{
    NSURL* cacheUrl = [NXCacheManager repoFileSystemCacheURL:repo];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:rootFolder];
    BOOL result = [data writeToURL:cacheUrl atomically:YES];
    if (result) {
        NSLog(@"Cache file system tree OK!");
    }else
    {
        NSLog(@"Cache file system tree failed!");
    }
}

+ (NSURL *)repoFileSystemCacheURL:(NXRepositoryModel *)repo
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:CACHEFILESYSFOLDER isDirectory:YES];
    NSString* uid = [NSString stringWithFormat:@"%@@%@", [NXLoginUser sharedInstance].profile.individualMembership.tenantId, [NXLoginUser sharedInstance].profile.userId];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:uid isDirectory:YES];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:repo.service_id isDirectory:YES];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl.path, error);
            return nil;
        }
    }
    cacheUrl = [cacheUrl URLByAppendingPathComponent:CACHEDIRECTORY isDirectory:NO];
    return cacheUrl;
}
+ (void)deleteCachedRepositoryFileSystemTree:(NXRepositoryModel *)repo
{
    NSURL *cacheURL = [self repoFileSystemCacheURL:repo];
    [NXCommonUtils deleteFilesAtPath:cacheURL.path];
}

+ (NXFolder *)getRepositoryFileSystemRootFolder:(NXRepositoryModel *)repo
{
    NSURL *fileSystemURL = [self repoFileSystemCacheURL:repo];
    NSData* data = [NSData dataWithContentsOfURL:fileSystemURL];
    NXFolder *rootFolder = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [NXCommonUtils unUnarchiverCacheDirectoryData:rootFolder];
    return rootFolder;

}


+ (NSURL *) getCacheUrlForOpenedInFile:(NSURL *) openedInFileUrl
{
    // The opened In File Url is
    // ../ApplicationPath/Cache/OpendIn/fileName
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *openedInFileName = openedInFileUrl.lastPathComponent;
    
    cacheUrl = [cacheUrl URLByAppendingPathComponent:CACHEOPENEDIN isDirectory:YES];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }

    cacheUrl = [cacheUrl URLByAppendingPathComponent:openedInFileName isDirectory:NO];
    return cacheUrl;
}

+ (NSURL *) getMyVaultRootFolderCachePathWithUserProfile:(NXLProfile *)userProfile
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:CACHEMYVAULT isDirectory:YES];
    NSString *currentUserPath = [NSString stringWithFormat:@"%@-%@", userProfile.individualMembership.tenantId, userProfile.userId];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:currentUserPath isDirectory:YES];
     cacheUrl = [cacheUrl URLByAppendingPathComponent:CACHEMYVAULTROOTFOLDER isDirectory:YES];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    
    cacheUrl = [cacheUrl URLByAppendingPathComponent:@"myVaultRootFolder.cache" isDirectory:NO];
    return cacheUrl;
}

+ (NSURL *)getMyVaultDownloadFilePath:(NSString *)fileName userProfile:(NXLProfile *)userProfile
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:CACHEMYVAULT isDirectory:YES];
    NSString *currentUserPath = [NSString stringWithFormat:@"%@-%@", userProfile.individualMembership.tenantId, userProfile.userId];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:currentUserPath isDirectory:YES];
    cacheUrl = [cacheUrl URLByAppendingPathComponent:CACHEMYVAULTDOWNLOAD isDirectory:YES];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    return cacheUrl;
}



+ (NSURL *)cacheMyVaultDownloadFile:(NSString *)fileName fileData:(NSData *)fileData userProfile:(NXLProfile *)userProfile
{
    NSURL *cacheURL = [self getMyVaultDownloadFilePath:fileName userProfile:userProfile];
    if (!cacheURL) {
        return nil;
    }
    
    cacheURL = [cacheURL URLByAppendingPathComponent:fileName isDirectory:NO];
    [fileData writeToURL:cacheURL atomically:YES];
    return cacheURL;
}

+ (NSURL *)cacheMyVaultRootFolder:(NXFileBase *)rootFolder userProfile:(NXLProfile *)userProfile
{
    NSURL *cacheURL = [self getMyVaultRootFolderCachePathWithUserProfile:userProfile];
    if (!cacheURL) {
        return nil;
    }
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:rootFolder];
    [data writeToURL:cacheURL atomically:YES];
    return cacheURL;
}
+ (NXFolder *)getCachedMyVaultRootFolderWithUserProfile:(NXLProfile *)userProfile
{
    NSURL* url = [self getMyVaultRootFolderCachePathWithUserProfile:userProfile];
    if (!url) {
        return nil;
    }
    
    NSData* data = [NSData dataWithContentsOfURL:url];
    NXFolder *rootFolder = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [NXCommonUtils unUnarchiverCacheDirectoryData:rootFolder];
    return rootFolder;
}

+ (NSURL*) getLocalUrlForServiceCache:(NXRepositoryModel *)repoModel
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    return [self combinaFullLocalUrl:cacheUrl repository:repoModel];
}

+ (NSURL*) getSafeLocalUrlForServiceCache:(NXRepositoryModel *)repoModel; {
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [self combinaFullLocalUrl:cacheUrl repository:repoModel];
}

+ (void) cacheFile:(NXFileBase *)file localPath:(NSString *)localPath
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    
    NSURL *url;
    NXRepositoryModel *service = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:file];
    if (file.isOffline) {
        url = [NXCacheManager getSafeLocalUrlForServiceCache:service];
    } else {
        url = [NXCacheManager getLocalUrlForServiceCache:service];
    }
    
    url = [url URLByAppendingPathComponent:CACHEROOTDIR isDirectory:NO];

    if (file.fullPath) {
      url = [url URLByAppendingPathComponent:file.fullPath];  
    }
    if ([localPath isEqualToString:url.path]) {
        return;
    }
    
    NSString *cachePath = [url.path stringByDeletingLastPathComponent];
    if(![defaultManager fileExistsAtPath:cachePath isDirectory:nil])
    {
        [defaultManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSError *error;
    if ([defaultManager fileExistsAtPath:url.path isDirectory:nil]) {
        [NXCacheFileStorage storeCacheFileIntoCoreData:file cachePath:url.path];
        return;
    }
    
    BOOL ret = [defaultManager copyItemAtPath:localPath toPath:url.path error:&error];
    if (!ret) {
        NSLog(@"%@",error.description);
    } else {
        [NXCacheFileStorage storeCacheFileIntoCoreData:file cachePath:url.path];
        [defaultManager removeItemAtPath:localPath error:&error];
    }
}

+ (NSURL *) combinaFullLocalUrl:(NSURL *) cacheUrl repository:(NXRepositoryModel *)repoModel {
     NSString *uid = [[NSString alloc] initWithFormat:@"%@_%@", [NXLoginUser sharedInstance].profile.individualMembership.tenantId, [NXLoginUser sharedInstance].profile.userId];
    NSURL* url = [cacheUrl URLByAppendingPathComponent:uid isDirectory:YES];
    url =  [url URLByAppendingPathComponent:repoModel.service_id isDirectory:YES];
    if (!url) {
        return nil;
    }
   
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", url, error);
            return nil;
        }
    }
    
    return url;
}

+ (NSURL *)getProjectCachedFilePathWithFileName:(NSString *)fileName
{
    if (fileName.length > 0)
    {
        NSString *currentLoginUserId = [NXLoginUser sharedInstance].profile.userId;
        NSString *currentLoginUserTenantId = [NXLoginUser sharedInstance].profile.individualMembership.tenantId;
        NSURL *directryPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        directryPath = [directryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",currentLoginUserTenantId,currentLoginUserId] isDirectory:YES];
        directryPath = [directryPath URLByAppendingPathComponent:@"project" isDirectory:YES];
        directryPath = [directryPath URLByAppendingPathComponent:@"fileCaches" isDirectory:YES];
        
        NSURL *tempFileNamePath = [directryPath URLByAppendingPathComponent:fileName isDirectory:NO];
        
        if(![fileManager fileExistsAtPath:directryPath.path]){
            
            [fileManager createDirectoryAtPath:directryPath.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return tempFileNamePath;
    }
    return nil;
}

@end
