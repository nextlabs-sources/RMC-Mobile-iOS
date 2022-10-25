//
//  NXCreateFolderInRepoOperation.m
//  nxrmc
//
//  Created by EShi on 12/27/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXCreateFolderInRepoOperation.h"
#import "NXServiceOperation.h"
#import "NXCommonUtils.h"
typedef NS_ENUM(NSInteger, NXCreateFolderInRepoOperationState)
{
    NXCreateFolderInRepoOperationStateCreatingFolder = 1,
    NXCreateFolderInRepoOperationStateCreateFolderFinished,
};

@interface NXCreateFolderInRepoOperation()<NXServiceOperationDelegate>
@property(nonatomic, strong) NSString *folderName;
@property(nonatomic, strong) NXFileBase *parentFolder;
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, strong) id<NXServiceOperation> serviceOpt;
@property(nonatomic, assign) NXCreateFolderInRepoOperationState state;
@property(nonatomic, strong) NSThread *workThread; // the repo sdk need call thread not exist before callback, so need work thread keep live here
@end

@implementation NXCreateFolderInRepoOperation
- (instancetype)initWithFolderName:(NSString *)folderName underFolder:(NXFileBase *)parentFolder repository:(NXRepositoryModel *)repo
{
    self = [super init];
    if (self) {
        _serviceOpt = [NXCommonUtils getServiceOperationFromRepoItem:repo];
        [_serviceOpt setDelegate:self];
        _folderName = folderName;
        _parentFolder = parentFolder;
        _repo = repo;
        
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
        
    }
    return self;
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

-(NXCreateFolderInRepoOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXCreateFolderInRepoOperationState) newState
{
    @synchronized (self) {
        _state = newState;
    }
}

-(void) dealloc
{
    NSLog(@"I am %s", __FUNCTION__);
}

#pragma mark - overwrite
#pragma mark - NSOperation Methods
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.state == NXCreateFolderInRepoOperationStateCreateFolderFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXCreateFolderInRepoOperationStateCreatingFolder;
}

- (void)cancel
{
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
        self.state = NXCreateFolderInRepoOperationStateCreateFolderFinished;
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
    
    if(self.isCancelled || isDepenedCancel) {[self finish:NO]; return;};
    
    [self performSelector:@selector(work) onThread:_workThread withObject:nil waitUntilDone:NO];
}

#pragma mark - operation
- (void) work
{
    [self willChangeValueForKey:@"isExecuting"];
    // NOTE: There use _file.strongRefParent not _file.parent for parent is weak ref, will release after getAllfiles from folder
    self.state = NXCreateFolderInRepoOperationStateCreatingFolder;
    BOOL res = [_serviceOpt addFolder:_folderName toPath:_parentFolder];
    [self didChangeValueForKey:@"isExecuting"];
    if (res == NO) {
        [self finish:NO];
    }
}

- (void)cancelWork
{
    
}

-(void)finish:(BOOL) isSuccessful
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (!isSuccessful) {
        [self cancel];
    }
    self.state = NXCreateFolderInRepoOperationStateCreateFolderFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NXServiceOperationDelegate
-(void) addFolderFinished:(NXFileBase *)fileItem error:(NSError *)error
{
    if (self.createFolderComp) {
        fileItem.serviceAlias = self.repo.service_alias;
        fileItem.repoId = [self.repo.service_id copy];
        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
        fileItem.serviceAccountId = [self.repo.service_account_id copy];
        fileItem.serviceType = self.repo.service_type;
        fileItem.lastModifiedDate = nil;
        fileItem.lastModifiedTime = nil;
        self.createFolderComp(fileItem, _repo, error);
    }
    [self finish:YES];
}

@end
