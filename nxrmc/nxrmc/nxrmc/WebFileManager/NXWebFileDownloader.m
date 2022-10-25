//
//  NXWebFileDownloader.m
//  nxrmc
//
//  Created by EShi on 2/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXWebFileDownloader.h"
#import "NXRMCDef.h"
#import "NXWebFileDownloadOperation.h"
#import "NXDownloadRepoFileOperation.h"
#import "NXDownloadFileFromMyVaultFolderOperation.h"
#import "NXProjectDownloadFileOperation.h"
#import "NXSharedWithMeDownloadFileOperation.h"
#import "NXLoginUser.h"
#import "NXFileDownloadOperationFactory.h"

static NSString *const kProgressCallbackKey = @"kProgressCallbackKey";
static NSString *const kCompletedCallbackKey = @"kCompletedCallbackKey";
static NSString *const kProgressFileItemKey = @"kProgressFileItemKey";


typedef void(^NXWebFileDownloaderCreateNewDownBlock)(NSProgress *downloadProgress);
@interface NXWebFileDownloader()
@property(nonatomic, strong) NSMutableDictionary *downloadingCallBackBlocks;
@property(nonatomic, strong) NSMutableDictionary *downloadingOperations;
@property(nonatomic, strong) NSMutableDictionary *downloadProgresses;
@property(nonatomic, strong) dispatch_queue_t barrierQueue;
@property(nonatomic, strong) NSOperationQueue *downloadQueue;
@end

@implementation NXWebFileDownloader
+ (instancetype)sharedInstance
{
    static NXWebFileDownloader *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[NXWebFileDownloader alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _downloadingCallBackBlocks = [[NSMutableDictionary alloc] init];
        _downloadingOperations = [[NSMutableDictionary alloc] init];
        _downloadProgresses = [[NSMutableDictionary alloc] init];
        _barrierQueue = dispatch_queue_create("com.skydrm.rmcent.NXWebFileDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}

- (void)downloadFile:(NXFileBase *)fileItem toSize:(NSUInteger)size withProgressBlock:(NXWebFileDownloaderProgressBlock)progressBlock forKey:(NSString *)fileKey downloadType:(NSInteger)downloadType completion:(NXWebFileDownloaderCompletedBlock)completedBlock
{
    WeakObj(self);
    [self addProgressBlock:progressBlock completedBlock:completedBlock forFileKey:fileKey createCallBack:^(NSProgress *downloadProgress){
        StrongObj(self);
        id<NXWebFileDownloadOperation> downloadOperation = [self webFileDownloadOperationForFile:fileItem size:size downloadType:downloadType];
        [downloadOperation prepareDownloadFile:fileItem withProgress:downloadProgress completion:^(NXFileBase *fileBase, NSData *fileData, NSError *error) {
            dispatch_barrier_sync(self.barrierQueue, ^{
                NSArray *callBacks = self.downloadingCallBackBlocks[fileKey];
                if (callBacks) {
                    for (NSDictionary *callBack in callBacks) {
                        NXWebFileDownloaderCompletedBlock completedCallback = callBack[kCompletedCallbackKey];
                        if (completedCallback) {
                            completedCallback(fileBase, fileData, error);
                        }
                    }
                }
                [self.downloadingCallBackBlocks removeObjectForKey:fileKey];
                NSProgress *downloadProgress1 = self.downloadProgresses[fileKey];
                if (downloadProgress1) {
                    [downloadProgress1 removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                }
                [self.downloadProgresses removeObjectForKey:fileKey];
                [self.downloadingOperations removeObjectForKey:fileKey];
            });
        }];
        
        // add to operation queue, start work
        [self.downloadingOperations setObject:downloadOperation forKey:fileKey];
        [self.downloadQueue addOperation:downloadOperation];
    }];
}

- (void)cancelDownloadOperation:(NSString *)fileKey
{
    if(fileKey){
        WeakObj(self);
        dispatch_barrier_sync(self.barrierQueue, ^{
            StrongObj(self);
            [self.downloadingCallBackBlocks removeObjectForKey:fileKey];
            id<NXWebFileDownloadOperation> downloadOpt = self.downloadingOperations[fileKey];
            [downloadOpt cancelDownload];
            [self.downloadingOperations removeObjectForKey:fileKey];
            NSProgress *downloadProgress = self.downloadProgresses[fileKey];
            if (downloadProgress) {
                [downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
            }
            [self.downloadProgresses removeObjectForKey:fileKey];
        });
    }
}

#pragma mark - Private method
- (void)addProgressBlock:(NXWebFileDownloaderProgressBlock)progressBlock completedBlock:(NXWebFileDownloaderCompletedBlock)completedBlock forFileKey:(NSString *)fileKey createCallBack:(NXWebFileDownloaderCreateNewDownBlock)createdCallBack
{
    WeakObj(self);
    dispatch_barrier_sync(self.barrierQueue, ^{
        StrongObj(self);
        BOOL firstAdd = NO;
        if (!self.downloadingCallBackBlocks[fileKey]) {
            firstAdd = YES;
            self.downloadingCallBackBlocks[fileKey] = [[NSMutableArray alloc] init];
        }
        
        NSMutableArray *callBack = self.downloadingCallBackBlocks[fileKey];
        NSMutableDictionary *callBackBlocks = [[NSMutableDictionary alloc] init];
        if (progressBlock) {
            callBackBlocks[kProgressCallbackKey] = [progressBlock copy];
        }
        if (completedBlock) {
            callBackBlocks[kCompletedCallbackKey] = [completedBlock copy];
        }
        [callBack addObject:callBackBlocks];
        self.downloadingCallBackBlocks[fileKey] = callBack;
        
        // if progressBlock, create one NSProgress Object to report progress
        NSProgress *downloadProgress = nil;
        if (progressBlock) {
            downloadProgress = [[NSProgress alloc] init];
            [downloadProgress setUserInfoObject:fileKey forKey:kProgressFileItemKey];
            [downloadProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:nil];
            [self.downloadProgresses setObject:downloadProgress forKey:fileKey];
        }

         // Handle single download of simultaneous download request for the same fileKey
        if (firstAdd) {
            createdCallBack(downloadProgress);
        }
    });
}

#pragma mark - Private method
// This method is coupling with concrete class, any ideas?
- (id<NXWebFileDownloadOperation>)webFileDownloadOperationForFile:(NXFileBase *)file size:(NSUInteger)size downloadType:(NSInteger)downloadType
{
    id<NXWebFileDownloadOperation> downloadOperation = [NXFileDownloadOperationFactory createWithFile:file size:size downloadType:downloadType];
    return downloadOperation;
}

- (void)dealloc
{
    [self.downloadQueue cancelAllOperations];
}
#pragma mark - KVO for download progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSString *fileKey = progress.userInfo[kProgressFileItemKey];
        if (fileKey) {
            dispatch_sync(self.barrierQueue, ^{
                NSArray *callBackArray = self.downloadingCallBackBlocks[fileKey];
                for (NSDictionary *callBack in callBackArray) {
                    NXWebFileDownloaderProgressBlock progressBlock = [callBack[kProgressCallbackKey] copy];
                    if (progressBlock) {
                        dispatch_main_async_safe(^{
                             progressBlock(progress.completedUnitCount, progress.totalUnitCount, progress.fractionCompleted);
                        });
                    }
                }
            });
        }
    }
}
@end
