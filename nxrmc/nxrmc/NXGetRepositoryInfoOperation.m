//
//  NXGetRepositoryInfoOperation.m
//  nxrmc
//
//  Created by EShi on 1/18/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGetRepositoryInfoOperation.h"
#import "NXCommonUtils.h"

typedef NS_ENUM(NSInteger, NXGetRepositoryInfoOperationState)
{
    NXGetRepositoryInfoOperationStateQueryingRepoInfo = 1,
    NXGetRepositoryInfoOperationStateQueryRepoInfoFinished,
};

@interface NXGetRepositoryInfoOperation()<NXServiceOperationDelegate>
@property(nonatomic, assign) NXGetRepositoryInfoOperationState state;
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, strong) id<NXServiceOperation> serviceOpt;
@property(nonatomic, strong) NSThread *workThread; // the repo sdk need call thread not exist before callback, so need work thread keep live here
@end

@implementation NXGetRepositoryInfoOperation
- (instancetype)initWithRepository:(NXRepositoryModel *)repoModel
{
    self = [super init];
    if (self) {
        _repo = repoModel;
        _serviceOpt = [NXCommonUtils getServiceOperationFromRepoItem:repoModel];
        [_serviceOpt setDelegate:self];
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
    }
    return self;
}

-(NXGetRepositoryInfoOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXGetRepositoryInfoOperationState) newState
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
    return self.state == NXGetRepositoryInfoOperationStateQueryRepoInfoFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXGetRepositoryInfoOperationStateQueryingRepoInfo;
}

- (void)cancel
{
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
        self.state = NXGetRepositoryInfoOperationStateQueryRepoInfoFinished;
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

- (void) work
{
    [self willChangeValueForKey:@"isExecuting"];
    // NOTE: There use _file.strongRefParent not _file.parent for parent is weak ref, will release after getAllfiles from folder
    self.state = NXGetRepositoryInfoOperationStateQueryingRepoInfo;
    BOOL res = [_serviceOpt getUserInfo];
    [self didChangeValueForKey:@"isExecuting"];
    if (res == NO) {
        [self finish:NO];
    }
}

- (void)cancelWork
{
    [self.serviceOpt cancelGetUserInfo];
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
-(void)finish:(BOOL) isSuccessful
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (!isSuccessful) {
        [self cancel];
    }
    self.state = NXGetRepositoryInfoOperationStateQueryRepoInfoFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NXServiceOperationDelegate
-(void) getUserInfoFinished:(NSString *) userName userEmail:(NSString *) email totalQuota:(NSNumber *) totalQuota usedQuota:(NSNumber *) usedQuota error:(NSError *) error
{
    if (self.getRepoInfoCompletion) {
        self.getRepoInfoCompletion(self.repo, userName, email, totalQuota, usedQuota, error);
    }
}

@end
