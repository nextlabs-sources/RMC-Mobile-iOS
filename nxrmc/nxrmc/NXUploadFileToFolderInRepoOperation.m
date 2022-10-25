//
//  NXUploadFileToFolderInOperation.m
//  nxrmc
//
//  Created by EShi on 1/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXUploadFileToFolderInRepoOperation.h"
#import "NXServiceOperation.h"
#import "NXCommonUtils.h"
typedef NS_ENUM(NSInteger, NXUploadFileToFolderInRepoOperationState)
{
    NXUploadFileToFolderInRepoOperationStateUploadingFile = 1,
    NXUploadFileToFolderInRepoOperationStateUploadFinished,
};
@interface NXUploadFileToFolderInRepoOperation()<NXServiceOperationDelegate>
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NXFileBase *parentFolder;
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, strong) id<NXServiceOperation> serviceOpt;
@property(nonatomic, assign) BOOL isOverwrite;
@property(nonatomic, assign) NXUploadFileToFolderInRepoOperationState state;
@property(nonatomic, strong) NSThread *workThread; // the repo sdk need call thread not exist before callback, so need work thread keep live here
@end

@implementation NXUploadFileToFolderInRepoOperation

-(instancetype) initWithUploadFile:(NSString *)fileName andIsOverwrite:(BOOL)isOverwrite fromPath:(NSString *)filePath parentFolder:(NXFileBase *) parentFolder repository:(NXRepositoryModel *)repo 
{
    self = [super init];
    if (self) {
        _fileName = fileName;
        _filePath = filePath;
        _parentFolder = parentFolder;
        _repo = repo;
        _isOverwrite = isOverwrite;
        _serviceOpt = [NXCommonUtils getServiceOperationFromRepoItem:repo];
        [_serviceOpt setDelegate:self];
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
        
    }
    return self;
}

- (void)uploadProgress:(NSProgress *)uploadProgress
{
    _uploadProgress = uploadProgress;
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:_filePath]){
        
        _uploadProgress.totalUnitCount = [[manager attributesOfItemAtPath:_filePath error:nil] fileSize];
    }
}
-(NXUploadFileToFolderInRepoOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXUploadFileToFolderInRepoOperationState) newState
{
    @synchronized (self) {
        _state = newState;
    }
}

-(void) dealloc
{
    NSLog(@"I am dea %s", __FUNCTION__);
}
#pragma mark - overwrite
#pragma mark - NSOperation Methods
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.state == NXUploadFileToFolderInRepoOperationStateUploadFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXUploadFileToFolderInRepoOperationStateUploadingFile;
}

- (void)cancel
{
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
        [self cancelWork];
        self.state = NXUploadFileToFolderInRepoOperationStateUploadFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
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
    self.state = NXUploadFileToFolderInRepoOperationStateUploadingFile;
    NXUploadType uploadType = NXUploadTypeNormal;
    if (self.isOverwrite) {
        uploadType = NXUploadTypeOverWrite;
    }
    BOOL res = [_serviceOpt uploadFile:self.fileName toPath:self.parentFolder fromPath:self.filePath uploadType:uploadType overWriteFile:nil];
    [self didChangeValueForKey:@"isExecuting"];
    if (res == NO) {
        [self finish:NO];
    }
}

- (void)cancelWork
{
    [self.serviceOpt cancelUploadFile:self.fileName toPath:self.parentFolder];
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
        if (self.uploadFileCompletion) {
            NSString *localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", nil)];
            NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey:localStr};
            NSError *error = [NSError errorWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_UPLOAD_ERROR userInfo:userInfoDict];
            self.uploadFileCompletion(nil, self.parentFolder, self.repo, error);
        }
    }
    self.state = NXUploadFileToFolderInRepoOperationStateUploadFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NXServiceOperationDelegate
- (void)uploadFileFinished:(NXFileBase *)fileItem fromLocalPath:(NSString *)localCachePath error:(NSError *)error
{
    if(self.uploadFileCompletion)
    {
        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
        fileItem.repoId = [self.repo.service_id copy];
        fileItem.serviceAlias = [self.repo.service_alias copy];
        self.uploadFileCompletion(fileItem, self.parentFolder, self.repo, error);
    }
    
    [self finish:YES];
}

-(void)uploadFileProgress:(CGFloat)progress forFile:(NSString*)servicePath fromPath:(NSString*)localCachePath
{
    self.uploadProgress.completedUnitCount = (self.uploadProgress.totalUnitCount * progress);
}

@end
