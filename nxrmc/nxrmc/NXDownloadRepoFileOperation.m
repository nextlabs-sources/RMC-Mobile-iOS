//
//  NXDownloadRepoFileOperation.m
//  nxrmc
//
//  Created by EShi on 1/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDownloadRepoFileOperation.h"
#import "NXServiceOperation.h"
#import "NXCommonUtils.h"
typedef NS_ENUM(NSInteger, NXDownloadRepoFileOperationState)
{
    NXDownloadRepoFileOperationStateDownloadingFile = 1,
    NXDownloadRepoFileOperationStateDownloadFileFinished,
};
@interface NXDownloadRepoFileOperation()<NXServiceOperationDelegate>
@property(nonatomic, assign) NXDownloadRepoFileOperationState downloadOptState;
@property(nonatomic, strong) NXFileBase *destFile;
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, strong) id<NXServiceOperation> serviceOpt;
@property(nonatomic, strong) NSString *tempCachedPath;
@property(nonatomic, strong) NSThread *workThread; // the repo sdk need keep caller thread alive before callback, so need work thread keep live here
@property(nonatomic, copy) NXWebFileDownloadOperationCompletionBlock webFileDownloadCompletion;
@property(nonatomic, assign) NSUInteger downloadSize;
@property(nonatomic, assign) NSInteger downloadType;
@end

@implementation NXDownloadRepoFileOperation
- (instancetype) initWithDestFile:(NXFileBase *) destFile repository:(NXRepositoryModel *)repo
{
    return [self initWithDestFile:destFile toSize:0 repository:repo];
}

- (instancetype) initWithDestFile:(NXFileBase *) destFile toSize:(NSUInteger)size repository:(NXRepositoryModel *)repo
{
    self = [super init];
    if (self) {
        _destFile = [destFile copy];
        _repo = [repo copy];
        _serviceOpt = [NXCommonUtils getServiceOperationFromRepoItem:repo];
        [_serviceOpt setDelegate:self];
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
        _downloadSize = size;
    }
    return self;

}
- (instancetype) initWithDestFile:(NXFileBase *) destFile toSize:(NSUInteger)size repository:(NXRepositoryModel *)repo downType:(NSInteger)downType {
    self = [super init];
    if (self) {
        _destFile = [destFile copy];
        _repo = [repo copy];
        _serviceOpt = [NXCommonUtils getServiceOperationFromRepoItem:repo];
        [_serviceOpt setDelegate:self];
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
        _downloadSize = size;
        _downloadType = downType;
    }
    return self;

   
}
- (void)setDownloadProgress:(NSProgress *)downloadProgress
{
    _downloadProgress = downloadProgress;
    _downloadProgress.totalUnitCount = self.destFile.size;
}

-(void) workThreadEntryPoint:(id)__unused object
{
    NSRunLoop* loop = [NSRunLoop currentRunLoop];
    do
    {
        @autoreleasepool
        {
            [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
            if (self.isFinished) {
                break;
            }
            
            [NSThread sleepForTimeInterval:1.0f];
        }
    }while (true);
}

-(NXDownloadRepoFileOperationState) state
{
    @synchronized (self) {
        return _downloadOptState;
    }
}

-(void) state:(NXDownloadRepoFileOperationState) newState
{
    @synchronized (self) {
        _downloadOptState = newState;
    }
}

-(void) dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - overwrite
#pragma mark - NSOperation Methods
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.downloadOptState == NXDownloadRepoFileOperationStateDownloadFileFinished;
}

- (BOOL)isExecuting
{
    return self.downloadOptState == NXDownloadRepoFileOperationStateDownloadingFile;
}

- (void)cancel
{
    [super cancel];
    if (self.isExecuting) {
        [self willChangeValueForKey:@"isExcuting"];
        [self willChangeValueForKey:@"isFinished"];
        self.downloadOptState = NXDownloadRepoFileOperationStateDownloadFileFinished;
        [self didChangeValueForKey:@"isExcuting"];
        [self didChangeValueForKey:@"isFinished"];
        [self performSelector:@selector(cancelWork) onThread:_workThread withObject:nil waitUntilDone:NO];
    }
}

- (void)cancelWork
{
    [self.serviceOpt cancelDownloadFile:self.destFile];
}

- (void)start
{
    BOOL isDepenedCancel = NO;
    for (NSOperation * opt in self.dependencies) {
        if (opt.isCancelled) {
            isDepenedCancel = YES;
            break;
        }
    }
    
    if(self.isCancelled || isDepenedCancel) {[self finish:NO]; return;};
    
    [self performSelector:@selector(work) onThread:_workThread withObject:nil waitUntilDone:NO];
}

#pragma mark - work
- (void) work
{
    [self willChangeValueForKey:@"isExecuting"];
    // NOTE: There use _file.strongRefParent not _file.parent for parent is weak ref, will release after getAllfiles from folder
    self.downloadOptState = NXDownloadRepoFileOperationStateDownloadingFile;
    BOOL res;
    if ([self.repo.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", NULL)]) {
       res = [_serviceOpt downloadFile:self.destFile size:self.downloadSize downloadType:self.downloadType];
    }else{
       res = [_serviceOpt downloadFile:self.destFile size:self.downloadSize];
    }
  
    [self didChangeValueForKey:@"isExecuting"];
    if (res == NO) {
        [self finish:NO];
    }
}

-(void)finish:(BOOL) isSuccessful
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (!isSuccessful && !self.isCancelled) {
        [self cancel];
    }
    self.downloadOptState = NXDownloadRepoFileOperationStateDownloadFileFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NXServiceOperationDelegate
 -(void)downloadFileFinished:(NSString*) servicePath intoPath:(NSString*)localCachePath error:(NSError*)err
{
    if (!err) {
        self.tempCachedPath = localCachePath;
    }
}

-(void)downloadFileProgress:(CGFloat) progress forFile:(NSString*)servicePath
{
    if(self.downloadProgress){
        self.downloadProgress.completedUnitCount = (self.destFile.size * progress);
    }
}

-(void)downloadFileFinished:(NXFileBase *)file fileData:(NSData *)fileData error:(NSError *)error
{
    if (self.webFileDownloadCompletion) {
        self.webFileDownloadCompletion(self.destFile, fileData, error);
        if (error) {
            [self finish:NO];
        }else{
            [self finish:YES];
        }
        
        if (self.tempCachedPath) {
            [[NSFileManager defaultManager] removeItemAtPath:self.tempCachedPath error:nil];
        }
    }
}

#pragma mark - NXWebFileDownloadOperation
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion
{
    self.destFile = file;
    self.downloadProgress = progress;
    self.webFileDownloadCompletion = completion;
}
- (void)cancelDownload
{
    [self cancel];
}
@end
