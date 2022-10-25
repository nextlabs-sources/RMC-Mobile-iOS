//
//  NXGetRepoFileInFolderOperation.m
//  nxrmc
//
//  Created by EShi on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGetRepoFileInFolderOperation.h"
#import "NXServiceOperation.h"
#import "NXCommonUtils.h"
#import "NXSharePointFolder.h"

typedef NS_ENUM(NSInteger, NXGetRepoFileInFolderOperationState)
{
    NXGetRepoFileInFolderOperationStateGettingFiles = 1,
    NXGetRepoFileInFolderOperationStateGetFilesFinished,
};
@interface NXGetRepoFileInFolderOperation()<NXServiceOperationDelegate>
@property(nonatomic, strong) NXFileBase *parentFolder;
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, strong) id<NXServiceOperation> serviceOpt;
@property(nonatomic, assign) NXGetRepoFileInFolderOperationState state;
@property(nonatomic, strong) NSThread *workThread; // the repo sdk need call thread not exist before callback, so need work thread keep live here
@property(nonatomic, strong) NSArray *resultArray;
@end

@implementation NXGetRepoFileInFolderOperation
-(instancetype) initWithParentFolder:(NXFileBase *) parentFolder repository:(NXRepositoryModel *)repo
{
    self = [super init];
    if (self) {
        
        _serviceOpt = [NXCommonUtils getServiceOperationFromRepoItem:repo];
        [_serviceOpt setDelegate:self];
        _parentFolder = parentFolder;
        _repo = repo;
        
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
    }
    return self;
}

-(NXGetRepoFileInFolderOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXGetRepoFileInFolderOperationState) newState
{
    @synchronized (self) {
        _state = newState;
    }
}

-(void) dealloc
{
    NSLog(@"I am dea repo Name %@", self.repo.service_alias);
}
#pragma mark - overwrite
#pragma mark - NSOperation Methods
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.state == NXGetRepoFileInFolderOperationStateGetFilesFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXGetRepoFileInFolderOperationStateGettingFiles;
}

- (void)cancel
{
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
        self.state = NXGetRepoFileInFolderOperationStateGetFilesFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
    [self performSelector:@selector(cancelWork) onThread:_workThread withObject:nil waitUntilDone:NO];
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
    
    if(self.isCancelled || isDepenedCancel){
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_REPO_FILE_SYS_MANAGER_CANCELLED userInfo:nil];
        [self finish:error]; return;
    }
    
    [self performSelector:@selector(work) onThread:_workThread withObject:nil waitUntilDone:NO];
}

- (void) work
{
    [self willChangeValueForKey:@"isExecuting"];
    // NOTE: There use _file.strongRefParent not _file.parent for parent is weak ref, will release after getAllfiles from folder
    self.state = NXGetRepoFileInFolderOperationStateGettingFiles;
    BOOL res = [_serviceOpt getFiles:_parentFolder];
    [self didChangeValueForKey:@"isExecuting"];
    if (res == NO) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_REPO_FILE_SYS_MANAGER_GET_FILE_ERROR userInfo:nil];
        [self finish:error];
    }
}

- (void)cancelWork
{
    [self.serviceOpt cancelGetFiles:self.parentFolder];
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

#pragma mark - Private method
-(void)finish:(NSError *) error
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (error) {
        [self cancel];
        
    }
    if (self.getFileCompletion) {
        self.getFileCompletion(self.resultArray, self.parentFolder, self.repo, error);
    }
    self.state = NXGetRepoFileInFolderOperationStateGetFilesFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NXServiceOperationDelegate
-(void) getFilesFinished:(NSArray*) files error: (NSError*)err
{
    // Add repoId ,alians
    for(NXFileBase *file in files)
    {
        file.repoId = self.repo.service_id;
        if (file.serviceType && file.serviceType.integerValue < kServiceOneDriveApplication) {
            file.sorceType = NXFileBaseSorceTypeRepoFile;
        }
        file.serviceAlias = [self.repo.service_alias copy];
        file.serviceAccountId = [self.repo.service_account_id copy];
        file.serviceType = self.repo.service_type;
        if ([file isKindOfClass:[NXFolder class]] || [file isKindOfClass:[NXSharePointFolder class]]) {
            file.size = 0; // do not show size for folder fix bug 39866
//            file.lastModifiedDate = nil;
//            file.lastModifiedTime = nil;
        }
    }
    self.resultArray = files;
    [self finish:err];
    
}

@end
