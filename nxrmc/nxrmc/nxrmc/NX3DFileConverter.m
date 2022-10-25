//
//  NX3DFileConverter.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NX3DFileConverter.h"

#import <CommonCrypto/CommonDigest.h>

#import "NXFileBase.h"
#import "NXWebFileCacher.h"
#import "NXRMCDef.h"
#import "NSString+Codec.h"
#import "NXLoginUser.h"

#import "NX3DFileConvertOperation.h"

#import "NXAutoPurgeCache.h"
#import "NXCommonUtils.h"
#import "NXLProfile.h"
#define k3DConvertOperationPrefix @"k3DConvertOperationPrefix"

@interface NX3DFileConverter ()

@property(nonatomic, strong) NXWebFileCacher *fileCache;
@property(nonatomic, strong) NXAutoPurgeCache *memCache;

@property(nonatomic, strong) NSOperation *convertOperation;

@property(nonatomic, strong) NSMutableDictionary<NSString *, id> *complDic;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NX3DFileConvertOperation *> *operationsDic;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id> *progressDic;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *operationKeysDic; //fileBase is key, operationkey is value.
@end

@implementation NX3DFileConverter
- (NSString *)convertFile:(NXFileBase *)fileItem data:(NSData *)data progress:(void (^)(NSNumber *progress))progressBlock completion:(void (^)(NXFileBase *fileItem, NSData *data, NSError *error))completion {
    
    if (!fileItem.localPath) {
        return nil;
    }
    
    progressBlock = nil; // Temp code , do not support progress (otherewise will cause KVO crash)
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationIdentify = [[NSString alloc] initWithFormat:@"%@%@", k3DConvertOperationPrefix, uuid];
    
    __block NSData *cacheData;
    NSString *cacheKey = [self cachekeyOfFileItem:fileItem];
    // 1 nxl file only cached in memory.
    if ([self isNXLExtension:fileItem.name]) {
        cacheData = [self.memCache objectForKey:cacheKey];
        if (cacheData) {
            completion(fileItem, cacheData, nil);
            return nil;
        }
    }
    //2 not nxl, check cache from disk.
    if ([self.fileCache isFileCached:cacheKey]) {
        [self.fileCache queryCacheForFile:fileItem forKey:cacheKey done:^(NXFileBase *cachedfile, NSData *fileData, NXWebFileCacherCacheType cahceType) {
            if (cahceType == NXWebFileCacherCacheTypeNeedUpdate ||
                cahceType == NXWebFileCacherCacheTypeNone) {
                [self s_convertFile:fileItem data:data progress:progressBlock completion:completion withOperationKey:operationIdentify];
            } else {
                cacheData = [NSData dataWithContentsOfFile:cachedfile.localPath];
                dispatch_main_async_safe(^{
                    completion(fileItem, cacheData, nil);
                });
            }
        }];
    } else {
        operationIdentify = [self s_convertFile:fileItem data:data progress:progressBlock completion:completion withOperationKey:operationIdentify];
    }
    return operationIdentify;
}

- (void)cancelConvertFile:(NXFileBase *)fileItem {
    NSString *operationKey = [self cachekeyOfFileItem:fileItem];
    [self cancelOperation:operationKey];
}

- (void)cancelOperation:(NSString *)operationIdentify {
    if (operationIdentify ) {
        NX3DFileConvertOperation *operation = [self.operationsDic objectForKey:operationIdentify];
        [operation.progerss removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
        [operation cancel];
        
    }
}

- (void)quaryCachedFile:(NXFileBase *)fileItem completion:(void (^)(NXFileBase *, NSData *))completion {
    if (!fileItem.localPath) {
        return;
    }

    NSString *cacheKey = [self cachekeyOfFileItem:fileItem];
    if ([self.fileCache isFileCached:cacheKey]) {
        [self.fileCache queryCacheForFile:fileItem forKey:cacheKey done:^(NXFileBase *cachedfile, NSData *fileData, NXWebFileCacherCacheType cahceType) {
            if (cahceType == NXWebFileCacherCacheTypeNeedUpdate ||
                cahceType == NXWebFileCacherCacheTypeNone) {
                dispatch_main_async_safe(^{
                    completion(fileItem, nil);
                });
            } else {
                dispatch_main_async_safe(^{
                    completion(fileItem, fileData);
                });
            }
        }];
    }
}

- (NSString *)s_convertFile:(NXFileBase *)fileItem data:(NSData *)data progress:(void (^)(NSNumber *progress))progressBlock completion:(void (^)(NXFileBase *fileItem, NSData *data, NSError *error))completion withOperationKey:(NSString *)operationIdentify {
    
    NSString *cacheKey = [self cachekeyOfFileItem:fileItem];
    
//    NSProgress *progress = [[NSProgress alloc] init];
//    [progress setUserInfoObject:operationIdentify forKey:@"123"];
//    [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:nil];
    
    NSString *fileName = fileItem.name;
    if ([self isNXLExtension:fileItem.name]) {
        fileName = [fileItem.name stringByDeletingPathExtension];
    };
    
    NX3DFileConvertOperation *convertOperation = [[NX3DFileConvertOperation alloc] initWithFile:fileName data:data name:fileItem];
    convertOperation.progerss = nil;
    self.convertOperation = convertOperation;
    WeakObj(self);
    convertOperation.completion = ^(NXFileBase *fileItem, NSData *data, NSError *error) {
        StrongObj(self);
        if(self){
            if (error.code == NXRMC_ERROR_CODE_CANCEL) {
                return;
            }
         //   [progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
            if (!error) {
                //do cache, nxl file cached to memory.
                if ([self isNXLExtension:fileItem.name]) {
                    [self.memCache setObject:data forKey:cacheKey];
                }
                [self.fileCache storeFileItem:fileItem fileData:data forKey:cacheKey isForOffline:NO withCompletion:^(NXFileBase *file, NSError *error) {
                    if (error) {
                        DLog(@"%@", error.localizedDescription);
                    }
                }];
            }
            void (^comp)(NXFileBase *fileItem, NSData *data, NSError *error) = self.complDic[operationIdentify];
            dispatch_main_async_safe(^{
                if (comp) {
                    comp(fileItem, data, error);
                }
            });
            
            [self.complDic removeObjectForKey:operationIdentify];
            [self.operationsDic removeObjectForKey:operationIdentify];
            [self.progressDic removeObjectForKey:operationIdentify];
            
            [self.operationKeysDic removeObjectForKey:fileItem.fullServicePath];

        }
    };
    
    [self.operationKeysDic setObject:operationIdentify forKey:fileItem.fullServicePath];
    [self.complDic setObject:completion forKey:operationIdentify];
    [self.operationsDic setObject:convertOperation forKey:operationIdentify];
    if (progressBlock) {
        [self.progressDic setObject:progressBlock forKey:operationIdentify];

    }
    
    [convertOperation start];
    
    return operationIdentify;
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSString *operationKey = progress.userInfo[@"123"];
        if (operationKey) {
            void (^progressBlock)(NSNumber *progress) = [self.progressDic objectForKey:operationKey];
            if (progressBlock) {
                dispatch_main_async_safe(^{
                    progressBlock(@(progress.fractionCompleted));
                })
            }
        }
    }
}
#pragma mark - private method
- (NSString *)cachekeyOfFileItem:(NXFileBase *)fileItem {
    if (!fileItem.localPath) {
        return nil;
    }
    NSString *keyCacheStr = [NSString stringWithFormat:@"%@_%@_%@", fileItem.fullServicePath?:@"", fileItem.repoId?:@"", fileItem.serviceAlias?:@""];
    return [keyCacheStr MD5];
}

- (BOOL)isNXLExtension:(NSString *)fileName {
    NSString *extension = [fileName pathExtension];
    NSString *markExtension = [NSString stringWithFormat:@".%@", extension];
    if ([markExtension compare:NXLFILEEXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - getter setter
- (NSMutableDictionary<NSString *, id> *)complDic {
    @synchronized (self) {
        if (_complDic == nil) {
            _complDic = [[NSMutableDictionary alloc] init];
        }
        return _complDic;
    }
}

- (NSMutableDictionary<NSString *, id> *)progressDic {
    @synchronized (self) {
        if (_progressDic == nil) {
            _progressDic = [[NSMutableDictionary alloc]init];
        }
        return _progressDic;
    }
}

- (NSMutableDictionary<NSString *, NX3DFileConvertOperation *> *)operationsDic {
    @synchronized (self) {
        if (_operationsDic == nil) {
            _operationsDic = [[NSMutableDictionary alloc] init];
        }
        return _operationsDic;
    }
}

- (NSMutableDictionary<NSString *, NSString *> *)operationKeysDic {
    @synchronized (self) {
        if (_operationKeysDic == nil) {
            _operationKeysDic = [[NSMutableDictionary alloc] init];
        }
        return _operationKeysDic;
    }
}

- (NXWebFileCacher *)fileCache {
    if (!_fileCache) {
        NSString *nameSpace = [[NSString alloc] initWithFormat:@"%@_%@", [NXLoginUser sharedInstance].profile.individualMembership.tenantId, [NXLoginUser sharedInstance].profile.userId];
        _fileCache = [[NXWebFileCacher alloc]initWithNamespace:nameSpace diskCacheDirectory:nil];
    }
    return _fileCache;
}

- (NXAutoPurgeCache *)memCache {
    if (!_memCache) {
        _memCache = [[NXAutoPurgeCache alloc] init];
        _memCache.totalCostLimit = 1024*1024*20;
    }
    return _memCache;
}
@end
