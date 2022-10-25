//
//  NXDeleteRepoFileItemOperation.m
//  nxrmc
//
//  Created by EShi on 12/27/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXDeleteRepoFileItemOperation.h"
#import "NXServiceOperation.h"
#import "NXCommonUtils.h"
typedef NS_ENUM(NSInteger, NXDeleteRepoFileItemOperationState)
{
    NXDeleteRepoFileItemOperationStateDelettingFile = 1,
    NXDeleteRepoFileItemOperationStateDeleteFileFinished,
};

@interface NXDeleteRepoFileItemOperation()<NXServiceOperationDelegate>
@property(nonatomic, strong) NXFileBase *delFileItem;
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, strong) id<NXServiceOperation> serviceOpt;
@property(nonatomic, assign) NXDeleteRepoFileItemOperationState state;
@property(nonatomic, strong) NSThread *workThread; // the repo sdk need call thread not exist before callback, so need work thread keep live here
@end

@implementation NXDeleteRepoFileItemOperation
-(instancetype) initWithDeleteFileItem:(NXFileBase *) fileItem repository:(NXRepositoryModel *)repo
{
    self = [super init];
    if (self) {
        _serviceOpt = [NXCommonUtils getServiceOperationFromRepoItem:repo];
        [_serviceOpt setDelegate:self];
        _delFileItem = fileItem;
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

-(NXDeleteRepoFileItemOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXDeleteRepoFileItemOperationState) newState
{
    @synchronized (self) {
        _state = newState;
    }
}

-(void) dealloc
{
    NSLog(@"I am dea");
}

#pragma mark - overwrite
#pragma mark - NSOperation Methods
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.state == NXDeleteRepoFileItemOperationStateDeleteFileFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXDeleteRepoFileItemOperationStateDelettingFile;
}

- (void)cancel
{
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
        self.state = NXDeleteRepoFileItemOperationStateDeleteFileFinished;
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
    self.state = NXDeleteRepoFileItemOperationStateDelettingFile;
    BOOL res = [_serviceOpt deleteFileItem:_delFileItem];
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
    self.state = NXDeleteRepoFileItemOperationStateDeleteFileFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NXServiceOperationDelegate
-(void) deleteItemFinished:(NSError *)error
{
    if (self.delFileCompletion) {
        self.delFileCompletion(_delFileItem, _repo, error);
    }
    [self finish:YES];
    
}


@end
