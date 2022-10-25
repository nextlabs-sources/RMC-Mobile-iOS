//
//  NXWebFileCacher.m
//  nxrmc
//
//  Created by EShi on 2/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NXWebFileCacher.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXAutoPurgeCache.h"
#import "NXNetworkHelper.h"

#define checkLastModifiedDateAndOutofDateReturn(A,B)   if ((A != B )||\
 ![self.fileManager fileExistsAtPath:fileMetaData.cache_path]) {\
    dispatch_main_async_safe(^{\
        completed(nil, nil, NXWebFileCacherCacheTypeNeedUpdate);\
    });\
    return;\
    }

typedef void(^getFileMetaDataCompletionBlock)(NXCacheFile *fileMetaData);
typedef void(^queryFileInDiskCompletinBlock)(NSString *localPath, NSError *error);

@interface NXWebFileCacher()
@property(nonatomic, strong) NXAutoPurgeCache *memCache;
@property (nonatomic, strong) NSString *diskCachePath;
@property(nonatomic, strong) NSString *offlineCachePath;
@property(nonatomic, strong) dispatch_queue_t ioQueue;
@property(nonatomic, strong) NSFileManager *fileManager;
@end


@implementation NXWebFileCacher
- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory
{
    if(self = [super init]){
        NSString *fullNamespace = [@"com.skydrm.rmcent.NXWebFileCacher." stringByAppendingString:ns];
        _memCache = [[NXAutoPurgeCache alloc] init];
        _memCache.name = fullNamespace;
        
        // Init the disk cache
        if (directory != nil) {
            _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
            _offlineCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:ns];
            _diskCachePath = path;
            
            NSString *offlinePath = [self makeOfflineCachePath:ns];
            _offlineCachePath = offlinePath;
        }
        
        _ioQueue = dispatch_queue_create("com.skydrm.rmcent.NXWebFileCacher", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_ioQueue, ^{
            _fileManager = [NSFileManager new];
        });

    }
    return self;
}

- (NSOperation *)queryCacheForFile:(NXFileBase *)file forKey:(NSString *)fileKey done:(NXWebFileCacheQueryCacheCompletedBlock) completed
{
//    NXFileBase *copyFile = [file copy];
    NSOperation *cacheOperation = [[NSOperation alloc] init];
    WeakObj(self);
    // step1. Query file meta-data, to adjust whether cache is out of date
    [self queryCacheMetaDateForFileKey:fileKey withCompletion:^(NXCacheFile *fileMetaData) {
        StrongObj(self);
        if (cacheOperation.cancelled) {
            return;
        }
        if (self) {
            if (fileMetaData) {
                if (file.lastModifiedDate) {
                    if ([[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
                        // should query file newest lastModified date from server
                        
                        //<=====query file last modified date start=====>
                        [file queryLastModifiedDate:^(NSDate *lastModifiedDate, NSError *error) {
                            if (!error && lastModifiedDate) {
                                // update file lastModifiedDate
                                file.lastModifiedDate = lastModifiedDate;
                                checkLastModifiedDateAndOutofDateReturn([fileMetaData.access_time timeIntervalSince1970], [lastModifiedDate timeIntervalSince1970])
                            }else if (error){
                                // have error, try to get file again
                                completed(nil, nil, NXWebFileCacherCacheTypeNeedUpdate);
                                return;
                            }
                            // return complete
                            file.localPath = fileMetaData.cache_path;
                            dispatch_main_async_safe(^{
                                completed(file, nil, NXWebFileCacherCacheTypeDisk);
                            });
                        }];
                        return;
                    }
                     //<==============query file last modified date end============>
                    // without network open old offline file from cache
                    if (!([fileMetaData.access_time timeIntervalSince1970] == [file.lastModifiedDate timeIntervalSince1970]) && [self.fileManager fileExistsAtPath:fileMetaData.cache_path]) {
                        dispatch_main_async_safe(^{
                            file.localPath = fileMetaData.cache_path;
                            completed(file, nil, NXWebFileCacherCacheTypeDisk);
                        });
                        return;
                    }
                }else{ // file base have no last modify time
                    file.lastModifiedDate = [fileMetaData.access_time copy];
                    if (![self.fileManager fileExistsAtPath:fileMetaData.cache_path]) {
                        dispatch_main_async_safe(^{
                            completed(nil, nil, NXWebFileCacherCacheTypeNeedUpdate);
                        });
                        return;
                    }

                }
            }
            if (!fileMetaData ) {
                dispatch_main_async_safe(^{
                    completed(nil, nil, NXWebFileCacherCacheTypeNone);
                });
                return;
            }
            
            // return complete
            file.localPath = fileMetaData.cache_path;
            dispatch_main_async_safe(^{
                completed(file, nil, NXWebFileCacherCacheTypeDisk);
            });
            return;
        }
    }];
   
    return cacheOperation;
}
#pragma mark - store/update local cache
- (void)storeFileItem:(NXFileBase *) file fileData:(NSData *)fileData forKey:(NSString *)fileKey isForOffline:(BOOL)isForOffline withCompletion:(NXWebFileCacherStoreFileCompletedBlock)completed
{
    if (fileData) {
        WeakObj(self);
        dispatch_async(self.ioQueue, ^{
            StrongObj(self);
            if (self) {
                NSString *cachePath = isForOffline?[self defaultOfflineFolderForFile:file Key:fileKey]:[self defautlCacheFolderForFile:file Key:fileKey];
            
                if (![self.fileManager fileExistsAtPath:cachePath]) {
                    [self.fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *fileCachePath = [cachePath stringByAppendingPathComponent:file.name];
                BOOL res = [self.fileManager createFileAtPath:fileCachePath contents:fileData attributes:nil];
                if (res) {
                    NXFileBase *retFile = [file copy];
                    retFile.localPath = fileCachePath;
                    [NXCacheFileStorage storeCacheFileIntoCoreData:retFile forFileKey:fileKey];
                    completed(retFile, nil);
                }else{
                    completed(nil, [[NSError alloc] initWithDomain:NX_ERROR_WEBFILEMANAGER_DOMAIN code:NXRMC_ERROR_CODE_NXWEBFILEMANAGER_CACHE_FILE_FAILED userInfo:nil]);
                }
            }
        });
    }else{
         completed(nil, [[NSError alloc] initWithDomain:NX_ERROR_WEBFILEMANAGER_DOMAIN code:NXRMC_ERROR_CODE_NXWEBFILEMANAGER_CACHE_FILE_FAILED userInfo:nil]);
    }
}
- (void)updateFileItem:(NXFileBase *)file fileData:(NSData *)fileData forKey:(NSString *)fileKey isForOffline:(BOOL)isForOffline withCompletion:(NXWebFileCacherStoreFileCompletedBlock)completed
{
    if (fileData) {
        WeakObj(self);
        dispatch_async(self.ioQueue, ^{
            StrongObj(self);
            if (self) {
                NSString *cachePath =  isForOffline?[self defaultOfflineFolderForFile:file Key:fileKey]:[self defautlCacheFolderForFile:file Key:fileKey];
                if (![self.fileManager fileExistsAtPath:cachePath]) {
                    [self.fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *fileCachePath = [cachePath stringByAppendingPathComponent:file.name];
                BOOL res = [self.fileManager createFileAtPath:fileCachePath contents:fileData attributes:nil];
                if (res) {
                    NXFileBase *retFile = [file copy];
                    retFile.localPath = fileCachePath;
                    [NXCacheFileStorage updateCacheFileInCoreData:retFile forFileKey:fileKey];
                    completed(retFile, nil);
                }else{
                    completed(nil, [[NSError alloc] initWithDomain:NX_ERROR_WEBFILEMANAGER_DOMAIN code:NXRMC_ERROR_CODE_NXWEBFILEMANAGER_CACHE_FILE_FAILED userInfo:nil]);
                }
            }
        });
    }

}

- (BOOL)isFileCached:(NSString *)fileKey
{
    __block BOOL ret = NO;
    dispatch_sync(self.ioQueue, ^{
        NXCacheFile *cacheFile = [NXCacheFileStorage queryCacheFileForFileKey:fileKey];
        if (cacheFile) {
            if ([self.fileManager fileExistsAtPath:cacheFile.cache_path]) {
                ret = YES;
            }else{
                [NXCacheFileStorage deleteCacheFileFromCoreData:cacheFile];
                ret = NO;
            }
        }else{
            ret = NO;
        }
    });
    return ret;
}
- (void)queryCacheMetaDateForFileKey:(NSString *)fileKey withCompletion:(getFileMetaDataCompletionBlock)completion
{
    dispatch_async(self.ioQueue, ^{
        NXCacheFile *cacheFile = [NXCacheFileStorage queryCacheFileForFileKey:fileKey];
        completion(cacheFile);
    });
}

#pragma mark - memory cache
- (NSString *)queryCacheInMemoryForFile:(NXFileBase *)fileItem  withKey:(NSString *)fileKey
{
    NSString *localFilePath = [self.memCache objectForKey:fileKey];  // NSCache is auto thread-safe, do not need lock here
    return localFilePath;
}

- (void)maxMemeoryCacheCost:(NSInteger) maxCost
{
    self.memCache.totalCostLimit = maxCost;
}


#pragma mark - disk cache
- (NSString *)queryCacheInDiskForFile:(NXFileBase *)fileItem withKey:(NSString *)fileKey
{
    // 1. step1. search DB about the cache info
    
    return nil;
}
#pragma mark - file path generate
- (NSString *)makeOfflineCachePath:(NSString *)namespace
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:namespace];
}

- (NSString *)makeDiskCachePath:(NSString *)namespace
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:namespace];
}
- (NSString *)defautlCacheFolderForFile:(NXFileBase *)file Key:(NSString *)fileKey
{
    NSString *cacheFolderPath = nil;
    if(file.sorceType == NXFileBaseSorceTypeRepoFile){
        cacheFolderPath = [[self.diskCachePath stringByAppendingPathComponent:file.repoId] stringByAppendingPathComponent:fileKey];
    }else{
        cacheFolderPath = [self.diskCachePath stringByAppendingPathComponent:fileKey];
    }
    return cacheFolderPath;
}

- (NSString *)defaultOfflineFolderForFile:(NXFileBase *)file Key:(NSString *)fileKey
{
    NSString *cacheFolderPath = nil;
    if(file.sorceType == NXFileBaseSorceTypeRepoFile){
        cacheFolderPath = [[self.offlineCachePath stringByAppendingPathComponent:file.repoId] stringByAppendingPathComponent:fileKey];
    }else{
        cacheFolderPath = [self.offlineCachePath stringByAppendingPathComponent:fileKey];
    }
    return cacheFolderPath;
}

#pragma mark - clean up
- (void)cleanDiskForFile:(NSString *)fileKey
{
    dispatch_sync(self.ioQueue, ^{
        NXCacheFile *cacheFile = [NXCacheFileStorage queryCacheFileForFileKey:fileKey];
        if (cacheFile) { // there the file may not cached yet 
            NSString *filePath = cacheFile.cache_path;
            filePath = [filePath stringByDeletingLastPathComponent]; // also remove the file store folder
            [self.fileManager removeItemAtPath:filePath error:nil];
            [NXCacheFileStorage deleteCacheFileFromCoreData:cacheFile];
        }
        
    });
}

- (void)cleanDiskForOfflineFile:(NXFileBase *)offlineFile withKey:(NSString *)key;
{
    dispatch_async(self.ioQueue, ^{
            NSString *offlineFilePath = [self.offlineCachePath stringByAppendingPathComponent:key];
            NSString *fileCachePath = [offlineFilePath stringByAppendingPathComponent:offlineFile.name];
            [self.fileManager removeItemAtPath:fileCachePath error:nil];
    });
}

#pragma mark - Offline files
- (NSNumber *)offlineFilesSizeForRepo:(NXRepositoryModel *)repo
{
    NSString *offlineFilePath = [self.offlineCachePath stringByAppendingPathComponent:repo.service_id];
    NSNumber *folderSize = [NXCommonUtils calculateCachedFileSizeAtPath:offlineFilePath];
    return folderSize;
}

- (void)cleanOfflineFilesForRepo:(NXRepositoryModel *)repo
{
    dispatch_sync(self.ioQueue, ^{
        NSString *offlineFilePath = [self.offlineCachePath stringByAppendingPathComponent:repo.service_id];
        [self.fileManager removeItemAtPath:offlineFilePath error:nil];
    });
}

- (NSNumber *)cacheFilesSizeForRepo:(NXRepositoryModel *)repo
{
    NSString *cacheFilePath = [self.diskCachePath stringByAppendingPathComponent:repo.service_id];
    NSNumber *folderSize = [NXCommonUtils calculateCachedFileSizeAtPath:cacheFilePath];
    return folderSize;
}
- (void)cleanCacheFilesForRepo:(NXRepositoryModel *)repo
{
    dispatch_sync(self.ioQueue, ^{
        NSString *offlineFilePath = [self.diskCachePath stringByAppendingPathComponent:repo.service_id];
        [self.fileManager removeItemAtPath:offlineFilePath error:nil];
    });
}

- (void)cleanAllDownloadedFilesForRepo:(NXRepositoryModel *)repo
{
    [self cleanOfflineFilesForRepo:repo];
    [self cleanCacheFilesForRepo:repo];
}
@end
