//
//  NXCacheFileStorage.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/21/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXCommonUtils.h"

@interface NXCacheFileStorage : NSObject
+ (void)storeCacheFileIntoCoreData: (NXFileBase *)fileBase cachePath :(NSString*) cPath;
+ (void)storeCacheFileIntoCoreData: (NXFileBase *)fileBase forFileKey :(NSString*) fileKey;
+ (void)updateCacheFileInCoreData:(NXFileBase *)fileBase forFileKey:(NSString *)fileKey;
+ (NXCacheFile*) getCacheFile: (NXFileBase *) file;
+ (NXCacheFile *)queryCacheFileForFileKey:(NSString *)fileKey;
+ (void) deleteCacheFileFromCoreData: (NXCacheFile*) cacheFile;
+ (void) deleteCacheFilesFromCoreDataForRepo: (NXRepositoryModel*) repo;
+ (void) deleteAllCacheFilesFromCoreData;
@end
