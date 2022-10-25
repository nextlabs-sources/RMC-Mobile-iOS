//
//  NXWebFileManager.m
//  nxrmc
//
//  Created by EShi on 2/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXWebFileManager.h"
#import "NXLoginUser.h"
#import "NSString+Codec.h"
#import "NXCommonUtils.h"
#import "NXNetworkHelper.h"
#import "AppDelegate.h"
#import "NXLProfile.h"
@interface NXWebFileCombinedOperation : NSObject <NXWebFileOperation>
@property(assign, nonatomic, getter=isCancelled) BOOL cancelled;
@property(strong, nonatomic) NSOperation *cacheOperation;
@property(copy, nonatomic) NXWebFileManagerNoParamsBlock cancleBlock;
@end

@implementation NXWebFileCombinedOperation

- (void)cancel{
    self.cancelled = YES;
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    
    if (self.cancleBlock) {
        self.cancleBlock();
        // following SDWebImageCombinedOperation, if use self.cancelBlock =nil, will crash. Why? don't know.
        _cancleBlock = nil;
    }
}

- (void)setCancleBlock:(NXWebFileManagerNoParamsBlock)cancleBlock
{
    if (self.isCancelled) {
        if (cancleBlock) {
            cancleBlock();
        }
        _cancleBlock = nil;
    }else{
        _cancleBlock = [cancleBlock copy];
    }
}


@end


@interface NXWebFileManager()
@property(nonatomic, strong) NSMutableDictionary *runningOperations;
@property(nonatomic, strong) NXWebFileCacher *fileItemCacher;
@property(nonatomic, strong) NXWebFileDownloader *fileDownloader;
@property(nonatomic, strong) NSMutableDictionary *downloadingFileOperationIdMap;
@end

@implementation NXWebFileManager
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static NXWebFileManager *instance = nil;
    dispatch_once(&once, ^{
        instance = [[NXWebFileManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if(self = [super init]){
        _runningOperations =[[NSMutableDictionary alloc] init];
        _fileItemCacher = [[NXWebFileCacher alloc] initWithNamespace:[[NSString alloc] initWithFormat:@"%@_%@", [NXLoginUser sharedInstance].profile.individualMembership.tenantId, [NXLoginUser sharedInstance].profile.userId] diskCacheDirectory:nil];
        _fileDownloader = [[NXWebFileDownloader alloc] init];
        _downloadingFileOperationIdMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)downloadFile:(NXFileBase *)file
              withProgress:(NXWebFileDownloaderProgressBlock)progressBlock
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock
{
    return [self downloadFile:file withProgress:progressBlock isOffline:NO forOffline:NO toSize:0 completed:completedBlock];
}
- (void)downloadMultipleFiles:(NSArray *)fileArray completed:(NXWebFileManagerDownloadMultipleFilesCompletedBlock)completedBlock{
    NSMutableArray *downloadArray = [NSMutableArray array];
    for (NXFile *fileItem in fileArray) {
        [self downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
            if (!error) {
                [downloadArray addObject:file];
                if (downloadArray.count == fileArray.count) {
                    if (completedBlock) {
                        completedBlock(downloadArray,nil);
                    }
                }
            }else{
                if (completedBlock) {
                    completedBlock(downloadArray,error);
                }
            }
        }];
    }
}
- (NSString *)downloadFile:(NXFileBase *)file
                    toSize:(NSUInteger)size
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock
{
    return [self downloadFile:file withProgress:nil isOffline:NO forOffline:NO toSize:size completed:completedBlock];
}
- (NSString *)saveAsFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)file
                    toDownloadType:(NSInteger)type
               completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock {
    return [self saveAsFile:file withProgress:nil toDownloadType:type toSize:0 completed:completedBlock];
    
}
- (NSString *)saveAsFile:(NXFileBase *)file
              withProgress:(NXWebFileDownloaderProgressBlock)progressBlock
          toDownloadType:(NSInteger)type
                    toSize:(NSUInteger)size
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock
{
    // if is local file, just return
    if (file.sorceType == NXFileBaseSorceType3rdOpenIn || file.sorceType == NXFileBaseSorceTypeLocal || file.sorceType == NXFileBaseSorceTypeLocalFiles) {
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(file, nil, nil);
            });
        }
        return nil;
    }
    
    NSString *operatonIdentify = [[NSUUID UUID] UUIDString];
    // step1. Generate one NXWebFileCombinedOperation stand for this task and key for the file item
    NXWebFileCombinedOperation *combinedOperation = [[NXWebFileCombinedOperation alloc] init];
    @synchronized (self.runningOperations) {
        [self.runningOperations setObject:combinedOperation forKey:operatonIdentify];
    }
    
    // Generate cachekey for the file
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    
    // !!!!!!!!!!!!!!!!!!!!Here special for size download!!!!!!!!!!!!!!!!!!!!!!!!!
    if(size != 0){
        NSString *appendSizeKey = [NSString stringWithFormat:@"%lu%lu", (unsigned long)size,type];
        fileKey = [fileKey stringByAppendingString:appendSizeKey];
    }
    [self.fileDownloader downloadFile:file toSize:size withProgressBlock:progressBlock forKey:fileKey downloadType:type completion:^(NXFileBase *fileItem, NSData *fileData, NSError *error) {
        if (!error) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *filePath = [self.localTmpPath stringByAppendingPathComponent:file.name];
            if ([fileManager createFileAtPath:filePath contents:fileData attributes:nil]){
                if (!combinedOperation.isCancelled && completedBlock) {
                    fileItem.localPath = filePath;
                    dispatch_main_async_safe(^{
                        completedBlock(fileItem, fileData, error);
                    });
                   
                }
            }
        }else{
            dispatch_main_async_safe(^{
                completedBlock(file,nil,error);
            });
        }
        
    }];
    
//    // cache the fileKey - operationIdentify map
//    @synchronized (self.downloadingFileOperationIdMap) {
//        [self.downloadingFileOperationIdMap setObject:operatonIdentify forKey:fileKey];
//    }
//    
//    
//    WeakObj(self);
//    WeakObj(combinedOperation);
//    // step2. Get file item from cache
//    combinedOperation.cacheOperation = [self.fileItemCacher queryCacheForFile:file forKey:fileKey done:^(NXFileBase *cachedFile, NSData *fileData, NXWebFileCacherCacheType cahceType) {
//        StrongObj(self);
//        if (combinedOperation.isCancelled) {
//            @synchronized (self.downloadingFileOperationIdMap) {
//                [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//            }
//            
//            @synchronized (self.runningOperations) {
//                [self.runningOperations removeObjectForKey:operatonIdentify];
//            }
//            return;
//        }
//        if (cachedFile && completedBlock) {
//            dispatch_main_async_safe(^{
//                completedBlock(cachedFile, nil, nil);
//            });
//            @synchronized (self.runningOperations) {
//                [self.runningOperations removeObjectForKey:operatonIdentify];
//            }
//            
//            @synchronized (self.downloadingFileOperationIdMap) {
//                [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//            }
//        }else{  // step3. cache do not hit, get it from net work
//            // if network disconnection
//            
//            if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
//                dispatch_main_async_safe(^{
//                    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)}];
//                    if (completedBlock) {
//                        completedBlock(file, nil,error);
//                    }
//                });
//                @synchronized (self.runningOperations) {
//                    [self.runningOperations removeObjectForKey:operatonIdentify];
//                }
//                
//                @synchronized (self.downloadingFileOperationIdMap) {
//                    [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//                }
//                
//                return ;
//            }
//            [self.fileDownloader downloadFile:file toSize:size withProgressBlock:progressBlock forKey:fileKey downloadType:type completion:^(NXFileBase *file, NSData *fileData, NSError *error) {
//                StrongObj(combinedOperation);
//                if (combinedOperation) {
//                    if (combinedOperation.isCancelled) {
//                        @synchronized (self.downloadingFileOperationIdMap) {
//                            [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//                        }
//                        
//                        @synchronized (self.runningOperations) {
//                            [self.runningOperations removeObjectForKey:operatonIdentify];
//                        }
//                        return;
//                    }else{
//                        if (!error) {
//                            // download success do cache
//                            if(cahceType == NXWebFileCacherCacheTypeNone){
//                                
//                                [self.fileItemCacher storeFileItem:file fileData:fileData forKey:fileKey isForOffline:NO withCompletion:^(NXFileBase *cachedfile, NSError *error) {
//                                    if (!combinedOperation.isCancelled && completedBlock) {
//                                        dispatch_main_async_safe(^{
//                                            completedBlock(cachedfile, fileData, error);
//                                        });
//                                       
//                                    }
//                                    [self.fileItemCacher cleanDiskForFile:fileKey];
//                                    @synchronized (self.runningOperations) {
//                                        [self.runningOperations removeObjectForKey:operatonIdentify];
//                                    }
//                                    
//                                    @synchronized (self.downloadingFileOperationIdMap) {
//                                        [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//                                    }
//                                    
//                                }];
//                            }else if(cahceType == NXWebFileCacherCacheTypeNeedUpdate){
//                                [self.fileItemCacher updateFileItem:file fileData:fileData forKey:fileKey isForOffline:NO withCompletion:^(NXFileBase *file, NSError *error) {
//                                    if (!combinedOperation.isCancelled && completedBlock) {
//                                        dispatch_main_async_safe(^{
//                                            completedBlock(file, fileData, error);
//                                        });
//                                    }
//                                    @synchronized (self.runningOperations) {
//                                        [self.runningOperations removeObjectForKey:operatonIdentify];
//                                    }
//                                    
//                                    @synchronized (self.downloadingFileOperationIdMap) {
//                                        [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//                                    }
//                                }];
//                            }
//                        }else{ // error occure when download file
//                            if (!combinedOperation.isCancelled && completedBlock) {
//                                dispatch_main_async_safe(^{
//                                    completedBlock(file, nil, error);
//                                });
//                            }
//                            
//                            @synchronized (self.runningOperations) {
//                                [self.runningOperations removeObjectForKey:operatonIdentify];
//                            }
//                            
//                            @synchronized (self.downloadingFileOperationIdMap) {
//                                [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//                            }
//                            
//                        }
//                    }
//                }
//            }];
//            
//            combinedOperation.cancleBlock = ^{
//                [self.fileDownloader cancelDownloadOperation:fileKey];
//                
//                @synchronized (self.runningOperations) {
//                    [self.runningOperations removeObjectForKey:operatonIdentify];
//                }
//                
//                @synchronized (self.downloadingFileOperationIdMap) {
//                    [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
//                }
//            };
//        }
//    }];
    return operatonIdentify;
}
- (NSString *)downloadFile:(NXFileBase *)file
              withProgress:(NXWebFileDownloaderProgressBlock)progressBlock
                 isOffline:(BOOL)isOffline
                forOffline:(BOOL)isForOffline
                    toSize:(NSUInteger)size
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock
{
    // if is local file, just return
    if (file.sorceType == NXFileBaseSorceType3rdOpenIn || file.sorceType == NXFileBaseSorceTypeLocal || file.sorceType == NXFileBaseSorceTypeLocalFiles) {
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(file, nil, nil);
            });
        }
        return nil;
    }
    
    NSString *operatonIdentify = [[NSUUID UUID] UUIDString];
    // step1. Generate one NXWebFileCombinedOperation stand for this task and key for the file item
    NXWebFileCombinedOperation *combinedOperation = [[NXWebFileCombinedOperation alloc] init];
    @synchronized (self.runningOperations) {
        [self.runningOperations setObject:combinedOperation forKey:operatonIdentify];
    }
    
    // Generate cachekey for the file
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    if (isOffline) {
        // FIX ME: offline file fileKeyPath should add OFFLINE_DOWNLOAD_SUFFIX when using downloadingFileOperationIdMap.
        // This is because when open file and mark file as offline, will use the same fileKey according to [NXCommonUtils fileKeyForFile:fileItem].
        // In order to identify offline download and normal open file download, so add OFFLINE_DOWNLOAD_SUFFIX in offline download filekey
        fileKey = [fileKey stringByAppendingString:OFFLINE_DOWNLOAD_SUFFIX];
    }
    // !!!!!!!!!!!!!!!!!!!!Here special for size download!!!!!!!!!!!!!!!!!!!!!!!!!
    if(size != 0){
        NSString *appendSizeKey = [NSString stringWithFormat:@"%lu", (unsigned long)size];
        fileKey = [fileKey stringByAppendingString:appendSizeKey];
    }
    
    // cache the fileKey - operationIdentify map
    @synchronized (self.downloadingFileOperationIdMap) {
        [self.downloadingFileOperationIdMap setObject:operatonIdentify forKey:fileKey];
    }
    
    
    WeakObj(self);
    WeakObj(combinedOperation);
    // step2. Get file item from cache
    combinedOperation.cacheOperation = [self.fileItemCacher queryCacheForFile:file forKey:fileKey done:^(NXFileBase *cachedFile, NSData *fileData, NXWebFileCacherCacheType cahceType) {
        StrongObj(self);
        if (combinedOperation.isCancelled) {
            @synchronized (self.downloadingFileOperationIdMap) {
                [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
            }
            
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObjectForKey:operatonIdentify];
            }
            return;
        }
        if (cachedFile && completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(cachedFile, nil, nil);
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObjectForKey:operatonIdentify];
            }
            
            @synchronized (self.downloadingFileOperationIdMap) {
                [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
            }
        }else{  // step3. cache do not hit, get it from net work
            // if network disconnection
            
            if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
                dispatch_main_async_safe(^{
                    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)}];
                    if (completedBlock) {
                        completedBlock(file, nil,error);
                    }
                });
                @synchronized (self.runningOperations) {
                    [self.runningOperations removeObjectForKey:operatonIdentify];
                }
                
                @synchronized (self.downloadingFileOperationIdMap) {
                    [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
                }
                
                return ;
            }
            [self.fileDownloader downloadFile:file toSize:size withProgressBlock:progressBlock forKey:fileKey downloadType:isForOffline?2:1 completion:^(NXFileBase *file, NSData *fileData, NSError *error) {
                StrongObj(combinedOperation);
                if (combinedOperation) {
                    if (combinedOperation.isCancelled) {
                        @synchronized (self.downloadingFileOperationIdMap) {
                            [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
                        }
                        
                        @synchronized (self.runningOperations) {
                            [self.runningOperations removeObjectForKey:operatonIdentify];
                        }
                        return;
                    }else{
                        if (!error) {
                            // download success do cache
                            if(cahceType == NXWebFileCacherCacheTypeNone){
                                
                                [self.fileItemCacher storeFileItem:file fileData:fileData forKey:fileKey isForOffline:isOffline withCompletion:^(NXFileBase *cachedfile, NSError *error) {
                                    if (!combinedOperation.isCancelled && completedBlock) {
                                        dispatch_main_async_safe(^{
                                            completedBlock(cachedfile, fileData, error);
                                        });
                                    }
                                    
                                    @synchronized (self.runningOperations) {
                                        [self.runningOperations removeObjectForKey:operatonIdentify];
                                    }
                                    
                                    @synchronized (self.downloadingFileOperationIdMap) {
                                        [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
                                    }
                                    
                                }];
                            }else if(cahceType == NXWebFileCacherCacheTypeNeedUpdate){
                                [self.fileItemCacher updateFileItem:file fileData:fileData forKey:fileKey isForOffline:isOffline withCompletion:^(NXFileBase *file, NSError *error) {
                                    if (!combinedOperation.isCancelled && completedBlock) {
                                        dispatch_main_async_safe(^{
                                            completedBlock(file, fileData, error);
                                        });
                                    }
                                    @synchronized (self.runningOperations) {
                                        [self.runningOperations removeObjectForKey:operatonIdentify];
                                    }
                                    
                                    @synchronized (self.downloadingFileOperationIdMap) {
                                        [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
                                    }
                                }];
                            }
                        }else{ // error occure when download file
                            if (!combinedOperation.isCancelled && completedBlock) {
                                dispatch_main_async_safe(^{
                                    completedBlock(file, nil, error);
                                });
                            }
                            
                            @synchronized (self.runningOperations) {
                                [self.runningOperations removeObjectForKey:operatonIdentify];
                            }
                            
                            @synchronized (self.downloadingFileOperationIdMap) {
                                [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
                            }
                            
                        }
                    }
                }
            }];
            
            combinedOperation.cancleBlock = ^{
                [self.fileDownloader cancelDownloadOperation:fileKey];
                
                @synchronized (self.runningOperations) {
                    [self.runningOperations removeObjectForKey:operatonIdentify];
                }
                
                @synchronized (self.downloadingFileOperationIdMap) {
                    [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
                }
            };
        }
    }];
    return operatonIdentify;
}

- (NSString *)downloadFile:(NXFileBase *)file
              withProgress:(NXWebFileDownloaderProgressBlock)progressBlock
                 isOffline:(BOOL)isOffline
                forOffline:(BOOL)isForOffline
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock
{
    return [self downloadFile:file withProgress:progressBlock isOffline:isOffline forOffline:isForOffline toSize:0 completed:completedBlock];
}

- (void)cancelDownload:(NSString *)downloadIdentify
{
    if(!downloadIdentify) return;
    
    @synchronized (self.runningOperations) {
        NXWebFileCombinedOperation *operation = [self.runningOperations objectForKey:downloadIdentify];
        [operation cancel];
    }
    
    @synchronized (self.downloadingFileOperationIdMap) {
        __block NSString *fileKey = nil;
        [self.downloadingFileOperationIdMap enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull mapedFileKey, NSString *  _Nonnull optID, BOOL * _Nonnull stop) {
            if ([optID isEqualToString:downloadIdentify]) {
                fileKey = mapedFileKey;
            }
        }];
        
        if (fileKey) {
            [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
        }
    }
}

- (void)cancelDownloadOfflineFileItem:(NXFileBase *)fileItem
{
    @synchronized (self.downloadingFileOperationIdMap) {
        NSString *fileKey = [NXCommonUtils fileKeyForFile:fileItem];
        fileKey = [fileKey stringByAppendingString:OFFLINE_DOWNLOAD_SUFFIX];
        // FIX ME: offline file fileKeyPath should add OFFLINE_DOWNLOAD_SUFFIX when using downloadingFileOperationIdMap.
        // This is because when open file and mark file as offline, will use the same fileKey according to [NXCommonUtils fileKeyForFile:fileItem].
        // In order to identify offline download and normal open file download, so add OFFLINE_DOWNLOAD_SUFFIX in offline download filekey
        if (fileKey) {
            NSString *operationIdentify = self.downloadingFileOperationIdMap[fileKey];
            [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
            if(operationIdentify){
                [self cancelDownload:operationIdentify];
            }
        }
    }
}
- (void)cancelAll
{
    @synchronized (self.runningOperations) {
        NSArray *operations = [self.runningOperations allValues];
        [operations makeObjectsPerformSelector:@selector(cancel)]; // 这里会调用两次 @synchronized (self.runningOperations)，但是由于@synchronized 底层实现是递归锁，因此同一线程内不会死锁
        [self.runningOperations removeAllObjects];
    }
}

- (BOOL)isFileCached:(NXFileBase *)fileItem
{
    NSString *fileKey = [NXCommonUtils fileKeyForFile:fileItem];
    BOOL ret = [self.fileItemCacher isFileCached:fileKey];
    if (ret == NO) {
        fileKey = [fileKey stringByAppendingString:OFFLINE_DOWNLOAD_SUFFIX];
        ret = [self.fileItemCacher isFileCached:fileKey];
    }
    return ret;
}

- (BOOL)isFileDownloading:(NXFileBase *)fileItem
{
    NSString *fileKey = [NXCommonUtils fileKeyForFile:fileItem];
    BOOL ret = NO;
    if (fileKey) {
        @synchronized (self.downloadingFileOperationIdMap) {
            ret = self.downloadingFileOperationIdMap[fileKey]?YES:NO;
            if (ret == NO) {  // also check offline download task
                fileKey = [fileKey stringByAppendingString:OFFLINE_DOWNLOAD_SUFFIX];
                ret = self.downloadingFileOperationIdMap[fileKey]?YES:NO;
            }
        }
    }
    return ret;
}
- (NSString *)localTmpPath{
    NSString *docPath =  NSTemporaryDirectory();
    NSString *tmpPath = [docPath stringByAppendingPathComponent:@"DownloadTemp"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return tmpPath;
}
- (void)cleanDiskForFile:(NSString *)fileKey
{
    [self.fileItemCacher cleanDiskForFile:fileKey];
}

- (void)cleanDiskForOfflineFile:(NXFileBase *)file withKey:(NSString *)key;
{
     key = [key stringByAppendingString:OFFLINE_DOWNLOAD_SUFFIX];
     [self.fileItemCacher cleanDiskForOfflineFile:file withKey:key];
     file.localPath = nil;
}

#pragma mark - Private method


#pragma mark - For Offline Mark
- (void)markFileAsOffline:(NXFileBase *)fileItem
{
    [self downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil isOffline:YES forOffline:YES completed:nil];
}
- (void)unmarkFileAsOffine:(NXFileBase *)fileItem
{
    NSString *fileKey = [NXCommonUtils fileKeyForFile:fileItem];
    
    // step1. stop download
    [self cancelDownloadOfflineFileItem:fileItem];
    // step2. remove the fileKey-OperationIdentify key
    [self.downloadingFileOperationIdMap removeObjectForKey:fileKey];
    // step3. clean up offline local file
    [self.fileItemCacher cleanDiskForFile:fileKey];
}

- (NSNumber *)offlineFileSizeForRepository:(NXRepositoryModel *)repo
{
    return [self.fileItemCacher offlineFilesSizeForRepo:repo];
}
- (void)cleanOfflineFilesForRepository:(NXRepositoryModel *)repo
{
    [self.fileItemCacher cleanOfflineFilesForRepo:repo];
}

- (NSNumber *)cachedFileSizeForRepository:(NXRepositoryModel *)repo
{
    return [self.fileItemCacher cacheFilesSizeForRepo:repo];
}
- (void)cleanCachedFileSizeForRepository:(NXRepositoryModel *)repo
{
    [self.fileItemCacher cleanCacheFilesForRepo:repo];
}

- (void)cleanAllDownloadFileForRepository:(NXRepositoryModel *)repo
{
    [self.fileItemCacher cleanAllDownloadedFilesForRepo:repo];
}

@end
