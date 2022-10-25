//
//  NXRepoFileSync.m
//  nxrmc
//
//  Created by EShi on 12/21/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRepoFileSync.h"
#import "NXFolder.h"
#import "NXRepositoryModel.h"
#import "NXRMCDef.h"
#import "NXMyVaultRepoFileListOpt.h"

@interface NXRepoFileSync()
@property(nonatomic, strong) NSOperationQueue *workQueue;
@property(nonatomic, strong) NSDictionary *folderRepoDict;
@property(nonatomic, strong) NSArray *parentFolders;
@property(nonatomic, strong) NSMutableDictionary *resultDict;
@property(nonatomic, strong) NSMutableDictionary *errorDict;
@property(nonatomic, strong) dispatch_queue_t serialQueue;

@property(nonatomic, strong) NSTimer *syncTimer;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, readwrite, assign) BOOL exited;
@property(nonatomic, assign) BOOL isOnce;
@end

@implementation NXRepoFileSync
#pragma mark - INIT/GETTER/SETTER
- (instancetype) init
{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.skydrm.rmcent.NXRepoFileSync", DISPATCH_QUEUE_SERIAL);
        _resultDict = [[NSMutableDictionary alloc] init];
        _errorDict = [[NSMutableDictionary alloc] init];
        _workQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)dealloc
{
    DLog(@"dealloc");
}

- (void)setFolderRepoDict:(NSDictionary *)folderRepoDict
{
    @synchronized (self) {
        _folderRepoDict = folderRepoDict;
        _parentFolders = [_folderRepoDict allValues];
    }
}

- (NSArray *)syncFolders
{
    @synchronized (self) {
        return [self.parentFolders copy];
    }
}
- (NSThread *) workThread
{
    if (_workThread == nil) {
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
    }
    return _workThread;
}

-(void) workThreadEntryPoint:(id)__unused object
{
    NSRunLoop* loop = [NSRunLoop currentRunLoop];
    do
    {
        @autoreleasepool
        {
            [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
            if (self.exited) {
                break;
            }
            
            [NSThread sleepForTimeInterval:1.0f];
        }
    }while (true);
}

#pragma mark - Public interface
- (void)startSyncFromRepoFolders:(NSDictionary *)repoFolderDict isOnceOperation:(BOOL)isOnce
{
    self.folderRepoDict = repoFolderDict;
    self.isOnce = isOnce;
    [self performSelector:@selector(startSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
}

- (void)startSyncTimer
{
    [self.syncTimer invalidate];
    self.syncTimer = nil;
    __weak typeof(self) weakSelf = self;
    if (self.exited) {  // it means alread called stop sync
        return;
    }
    self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:weakSelf selector:@selector(syncFilesinRepoFolderDict:) userInfo:weakSelf.folderRepoDict repeats:NO];
}
- (void)stopSync
{
    [self.workQueue cancelAllOperations];
    [self.syncTimer invalidate];
    self.syncTimer = nil;
    self.exited = YES;
    self.delegate = nil;
    [self.resultDict removeAllObjects];
}

#pragma mark - Private methods
- (void)syncFilesinRepoFolderDict:(NSTimer *)timer
{
    NSDictionary *repoFolderDict = (NSDictionary *)timer.userInfo;
    NSMutableArray *optArray = [[NSMutableArray alloc] init];
    __weak typeof(self) weakSelf = self;
    [repoFolderDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NXFileBase class]] && [key isKindOfClass:[NXRepositoryModel class]] ) {
            NXFileBase *folder = (NXFileBase *)obj;
            NXRepositoryModel *repo = (NXRepositoryModel *)key;
            NSOperation *opt = nil;
            opt = [[NXGetRepoFileInFolderOperation alloc] initWithParentFolder:folder repository:repo];
            ((NXGetRepoFileInFolderOperation *)opt).getFileCompletion = ^(NSArray *fileList, NXFileBase *optfolder, NXRepositoryModel* optRepo, NSError *error){
                if (weakSelf == nil) {
                    return ;
                }
                dispatch_async(weakSelf.serialQueue, ^{
                    if (!error) {
                        if (optfolder && fileList && optRepo) {
                              [weakSelf.resultDict setObject:@{optfolder:fileList} forKey:optRepo];
                        }
                    }else{
                        if (repo) {
                             [weakSelf.errorDict setObject:error forKey:repo];
                        }
                    }
                });
            };
                
       
            
            [optArray addObject:opt];
        }
    }];
    
    [self.workQueue addOperations:optArray waitUntilFinished:YES];
    
    // all operations done, return to delegate
    if(DELEGATE_HAS_METHOD(self.delegate, @selector(updateFiles:errors:fromRepoFileSync:)))
    {
        if(self.exited)
        {
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(self.serialQueue, ^{
            NSMutableDictionary *resultDictCopy = [NSMutableDictionary dictionaryWithDictionary:self.resultDict];
            NSDictionary *errorDictCopy = [NSDictionary dictionaryWithDictionary:self.errorDict];
            if (weakSelf.isOnce) {
                [weakSelf.delegate getFiles:resultDictCopy errors:errorDictCopy fromRepoFileSync:weakSelf];
            }else
            {
                [weakSelf.delegate updateFiles:resultDictCopy errors:errorDictCopy fromRepoFileSync:weakSelf];
            }
            // clear up
            [self.resultDict removeAllObjects];
            [self.errorDict removeAllObjects];
            if (self.isOnce) {
                [self stopSync];
            }else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self performSelector:@selector(startSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
                });
            }
        });
    }
}
@end
