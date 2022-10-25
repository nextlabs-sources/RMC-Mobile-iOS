//
//  NXWebFileManager.h
//  nxrmc
//
//  Created by EShi on 2/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXWebFileCacher.h"
#import "NXWebFileDownloader.h"
#import "NXWebFileOperation.h"
#import "NXFileBase.h"
typedef void(^NXWebFileManagerDownloadCompletedBlock)(NXFileBase *file, NSData *fileData, NSError *error);
typedef void(^NXWebFileManagerDownloadMultipleFilesCompletedBlock)(NSArray *downloadFileArray, NSError *error);
typedef void(^NXWebFileManagerNoParamsBlock)();

typedef void(^queryLastModifiedDateCompBlock)(NSDate *lastModifiedDate,NSError *error);
@protocol NXWebFileDownloadItemProtocol <NSObject>
@required
- (void)queryLastModifiedDate:(queryLastModifiedDateCompBlock)compBlock;
@end

// Just cheap copy of SDWebImageManager
@interface NXWebFileManager : NSObject

@property(nonatomic, strong,readonly) NXWebFileCacher *fileItemCacher;
@property(nonatomic, strong,readonly) NXWebFileDownloader *fileDownloader;

+ (instancetype)sharedInstance;

- (NSString *)downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)file
              withProgress:(NXWebFileDownloaderProgressBlock)progressBlock
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock;

- (NSString *)downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)file
              withProgress:(NXWebFileDownloaderProgressBlock)progressBlock
                 isOffline:(BOOL)isOffline
                forOffline:(BOOL)isForOffline  // add this params to control server record offline download log when download for offline file/update offline file
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock;
- (NSString *)saveAsFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)file
                    toDownloadType:(NSInteger)type
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock;
- (NSString *)downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)file
                    toSize:(NSUInteger)size
                 completed:(NXWebFileManagerDownloadCompletedBlock)completedBlock;
- (void)downloadMultipleFiles:(NSArray *)fileArray completed:(NXWebFileManagerDownloadMultipleFilesCompletedBlock)completedBlock;
- (void)cancelDownload:(NSString *)downloadIdentify;
- (void)cancelDownloadOfflineFileItem:(NXFileBase *)fileItem;
- (void)cancelAll;
- (BOOL)isFileCached:(NXFileBase *)fileItem;
- (BOOL)isFileDownloading:(NXFileBase *)fileItem;
- (void)cleanDiskForFile:(NSString *)fileKey;
- (void)cleanDiskForOfflineFile:(NXFileBase *)offlineFile withKey:(NSString *)key;

#pragma mark - For offline mark 
- (void)markFileAsOffline:(NXFileBase *)fileItem;
- (void)unmarkFileAsOffine:(NXFileBase *)fileItem;
- (NSNumber *)offlineFileSizeForRepository:(NXRepositoryModel *)repo;
- (void)cleanOfflineFilesForRepository:(NXRepositoryModel *)repo;
- (NSNumber *)cachedFileSizeForRepository:(NXRepositoryModel *)repo;
- (void)cleanCachedFileSizeForRepository:(NXRepositoryModel *)repo;

- (void)cleanAllDownloadFileForRepository:(NXRepositoryModel *)repo;
@end
