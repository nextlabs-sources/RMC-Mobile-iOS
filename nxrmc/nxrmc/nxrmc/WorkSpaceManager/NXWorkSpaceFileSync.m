//
//  NXWorkSpaceFileSync.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceFileSync.h"
#import "NXRMCDef.h"
#import "NXWorkSpaceFileListOperation.h"
@interface NXWorkSpaceFileSync ()
@property(nonatomic, strong) NSOperation *workOperation;
@property(nonatomic, strong) NSTimer *syncTimer;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, readwrite, assign) BOOL exited;
@property(nonatomic, strong) NXFileBase *syncFolder;
@end
@implementation NXWorkSpaceFileSync
#pragma mark - INIT/GETTER/SETTER
-(void)dealloc
{
    DLog(@"dealloc");
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
- (void)startSyncFromWorkSpaceFolder:(NXFileBase *)workSpaceFolder
{
    self.syncFolder = workSpaceFolder;
    
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
    self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:WORKSPACE_FILE_SYNC_INTERVAL target:weakSelf selector:@selector(syncFilesinWorkSpaceUnderFolder:) userInfo:nil repeats:NO];
}

- (void)syncFilesinWorkSpaceUnderFolder:(NSTimer *)timer
{
    NXWorkSpaceFileListOperation *getFileOpt = [[NXWorkSpaceFileListOperation alloc]initWithWorkSpaceFolder:(NXWorkSpaceFolder *)self.syncFolder];
    __weak typeof(self) weakSelf = self;
    getFileOpt.getWorkSPaceFileListCompletion = ^(NSArray *workSpaceFileList, NXWorkSpaceFolder *workSpaceFolder, NSError *error) {
        if (weakSelf.exited) {
            return;
        }
        if (DELEGATE_HAS_METHOD(weakSelf.delegate, @selector(updateFiles:parentFolder:error:fromWorkSpaceFileSync:))) {
            [weakSelf.delegate updateFiles:workSpaceFileList parentFolder:(NXFileBase *)workSpaceFolder error:error fromWorkSpaceFileSync:weakSelf];
        }
         [weakSelf performSelector:@selector(startSyncTimer) onThread:weakSelf.workThread withObject:nil waitUntilDone:NO];
    };
    self.workOperation = getFileOpt;
    [self.workOperation start];
}

- (void)stopSync
{
    [self.syncTimer invalidate];
    [self.workOperation cancel];
    self.syncTimer = nil;
    self.exited = YES;
}

@end
