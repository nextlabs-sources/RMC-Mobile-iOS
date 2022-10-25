//
//  NXMyVaultSync.m
//  nxrmc
//
//  Created by EShi on 12/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultFileSync.h"
#import "NXRMCDef.h"
#import "NXGetFileListInMyVaultFolderOperation.h"

@interface NXMyVaultFileSync()
@property(nonatomic, strong) NSOperation *workOperation;
@property(nonatomic, strong) NSTimer *syncTimer;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, readwrite, assign) BOOL exited;
@property(nonatomic, strong) NXFileBase *syncFolder;
@end

@implementation NXMyVaultFileSync
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
- (void)startSyncFromMyVaultFolder:(NXFileBase *)myVaultFolder
{
    self.syncFolder = myVaultFolder;
    
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
   self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:REPO_FILE_SYNC_INTERVAL target:weakSelf selector:@selector(syncFilesinMyVaultUnderFolder:) userInfo:nil repeats:NO];
}

- (void)syncFilesinMyVaultUnderFolder:(NSTimer *)timer
{
    NXMyVaultListParModel *model = [[NXMyVaultListParModel alloc] init];
    NXGetFileListInMyVaultFolderOperation *getFileOpt = [[NXGetFileListInMyVaultFolderOperation alloc] initWithParentFolder:self.syncFolder filterModel:model];
    __weak typeof(self) weakSelf = self;
    getFileOpt.completion = ^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error){
        if (weakSelf.exited) {
            return;
        }
        if (DELEGATE_HAS_METHOD(weakSelf.delegate , @selector(updateFiles:parentFolder:error:fromMyVaultFileSync:))) {
            [weakSelf.delegate updateFiles:fileList parentFolder:parentFolder error:error fromMyVaultFileSync:weakSelf];
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
