//
//  NXWebFileCacher.h
//  nxrmc
//
//  Created by EShi on 2/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXRepositoryModel.h"

typedef NS_ENUM(NSInteger, NXWebFileCacherCacheType){
    NXWebFileCacherCacheTypeNone = 1,
    NXWebFileCacherCacheTypeNeedUpdate,
    NXWebFileCacherCacheTypeMemory,
    NXWebFileCacherCacheTypeDisk,
    
};
typedef void(^NXWebFileCacheQueryCacheCompletedBlock)(NXFileBase *cachedfile, NSData *fileData, NXWebFileCacherCacheType cahceType);
typedef void(^NXWebFileCacherStoreFileCompletedBlock)(NXFileBase *file, NSError *error);

@interface NXWebFileCacher : NSObject
- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory;
- (NSOperation *)queryCacheForFile:(NXFileBase *)file forKey:(NSString *)fileKey done:(NXWebFileCacheQueryCacheCompletedBlock) completed;
- (void)storeFileItem:(NXFileBase *) file fileData:(NSData *)fileData forKey:(NSString *)fileKey isForOffline:(BOOL)isForOffline withCompletion:(NXWebFileCacherStoreFileCompletedBlock)completed;

- (void)updateFileItem:(NXFileBase *)file fileData:(NSData *)fileData forKey:(NSString *)fileKey isForOffline:(BOOL)isForOffline withCompletion:(NXWebFileCacherStoreFileCompletedBlock)completed;
- (BOOL)isFileCached:(NSString *)fileKey;
//- (void)setMaxMemeoryCacheCost:(NSInteger) maxCost;
//- (void)cleanDisk;
- (void)cleanDiskForFile:(NSString *)fileKey;
- (void)cleanDiskForOfflineFile:(NXFileBase *)offlineFile withKey:(NSString *)key;
//- (NSUInteger)getDiskCacheSize;

- (NSNumber *)offlineFilesSizeForRepo:(NXRepositoryModel *)repo;
- (void)cleanOfflineFilesForRepo:(NXRepositoryModel *)repo;

- (NSNumber *)cacheFilesSizeForRepo:(NXRepositoryModel *)repo;
- (void)cleanCacheFilesForRepo:(NXRepositoryModel *)repo;

- (void)cleanAllDownloadedFilesForRepo:(NXRepositoryModel *)repo;
@end
