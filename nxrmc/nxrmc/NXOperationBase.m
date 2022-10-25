//
//  NXTaskOperationBase.m
//  nxrmc
//
//  Created by EShi on 1/22/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXRMCDef.h"

typedef NS_ENUM(NSInteger, NXOperationBaseState){
    NXOperationBaseStateTaskExecuting = 1, 
    NXOperationBaseStateTaskFinished,
};

@interface NXOperationBase()
@property(nonatomic, assign) NXOperationBaseState state;
@property(nonatomic, strong) NSThread *workThread;
@end

@implementation NXOperationBase
- (instancetype) init
{
    self = [super init];
    if (self) {
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
    }
    return self;
}
- (NXOperationBaseState) state
{
    @synchronized (self) {
        return _state;
    }
}

- (void) state:(NXOperationBaseState) newState
{
    @synchronized (self) {
        _state = newState;
    }
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

#pragma mark - overwrite
#pragma mark - NSOperation Methods
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.state == NXOperationBaseStateTaskFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXOperationBaseStateTaskExecuting;
}

- (void)cancel
{
    [super cancel];
    
    if (self.isExecuting) {
        [self willChangeValueForKey:@"isExcuting"];
        [self willChangeValueForKey:@"isFinished"];
        self.state = NXOperationBaseStateTaskFinished;
        [self didChangeValueForKey:@"isExcuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"The task cancelled", nil)};
    NSError *cancelError = [[NSError alloc] initWithDomain:NX_ERROR_NXOPERATION_DOMAIN code:NXRMC_ERROR_CODE_NXOPERATION_CANCELLED userInfo:userInfo];
    [self performSelector:@selector(cancelWork:) onThread:_workThread withObject:cancelError waitUntilDone:NO];
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
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXOPERATION_DOMAIN code:NXRMC_ERROR_CODE_NXOPERATION_CANCELLED userInfo:nil];
        [self finish:error]; return;
    }
    
    [self performSelector:@selector(work) onThread:_workThread withObject:nil waitUntilDone:NO];
}

- (void) work
{
    [self willChangeValueForKey:@"isExecuting"];
    // NOTE: There use _file.strongRefParent not _file.parent for parent is weak ref, will release after getAllfiles from folder
    self.state = NXOperationBaseStateTaskExecuting;
    NSError *error = nil;
    [self executeTask:&error];
    [self didChangeValueForKey:@"isExecuting"];
    if (error) {
        [self finish:error];
    }
}


#pragma mark - called by subclass when finished work
-(void)finish:(NSError *) error
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (error && !self.isCancelled) {
        [super cancel];
    }
    
    [self workFinished:error];
    self.state = NXOperationBaseStateTaskFinished;
    self.workThread = nil;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
  
}

#pragma mark - must overwirte by subclass
- (void)executeTask:(NSError **)error
{
    NSAssert(NO, @"Must overwirte NXOperationBase::executeTask!");
}
- (void)workFinished:(NSError *)error
{
    NSAssert(NO, @"Must overwirte NXOperationBase::workFinished!");
}
- (void)cancelWork:(NSError *)cancelError
{
    NSAssert(NO, @"Must overwirte NXOperationBase::cancelWork!");
}

@end
