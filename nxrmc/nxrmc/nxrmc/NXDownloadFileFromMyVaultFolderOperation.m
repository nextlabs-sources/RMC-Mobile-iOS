//
//  NXDownloadFileFromMyVaultFolderOperation.m
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXDownloadFileFromMyVaultFolderOperation.h"
#import "NXMyVaultFileDownloadAPI.h"
#import "NXRMCDef.h"

typedef NS_ENUM(NSInteger, NXDownloadFileFromMyVaultFolderOperationState)
{
    NXDownloadFileFromMyVaultFolderOperationStateDownloadingFile = 1,
    NXDownloadFileFromMyVaultFolderOperationStateDownloadFileFinished,
};
@interface NXDownloadFileFromMyVaultFolderOperation()
@property(nonatomic, strong) NXMyVaultFile *destFile;
@property(nonatomic, assign) NXDownloadFileFromMyVaultFolderOperationState state;
@property(nonatomic, copy) NXWebFileDownloadOperationCompletionBlock webFileDownloadCompletion;
@property(nonatomic, strong) NXMyVaultFileDownloadAPIRequest *downloadRequest;
@property(nonatomic, assign) NSUInteger downloadSize;
@property(nonatomic, strong) NSNumber *downloadType;
@end

@implementation NXDownloadFileFromMyVaultFolderOperation
- (instancetype)initWithFile:(NXMyVaultFile *)file size:(NSUInteger)size downloadType:(NSInteger)downloadType
{
    self = [super init];
    if (self) {
        _destFile = file;
        _downloadSize = size;
        _downloadType = [NSNumber numberWithInteger:downloadType];
    }
    return self;
}

-(NXDownloadFileFromMyVaultFolderOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXDownloadFileFromMyVaultFolderOperationState) newState
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
    return self.state == NXDownloadFileFromMyVaultFolderOperationStateDownloadFileFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXDownloadFileFromMyVaultFolderOperationStateDownloadingFile;
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
    
    [self willChangeValueForKey:@"isExcuting"];
    self.downloadRequest = [[NXMyVaultFileDownloadAPIRequest alloc] init];
    NSNumber *downloadNum = nil;
    if (self.downloadSize == 0) {
        downloadNum = [NSNumber numberWithLongLong:self.destFile.size];
    }else{
        downloadNum = [NSNumber numberWithUnsignedInteger:self.downloadSize];
    }
    NSDictionary *modelDict = @{PATH:self.destFile.fullServicePath, START:@0, LENGTH:downloadNum, DOWNLOAD_TYPE:self.downloadType};
//    __weak typeof(self) weakSelf = self;
    WeakObj(self);
    [self.downloadRequest requestWithObject:modelDict withUploadProgress:nil downloadProgress:self.downloadProgress Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error) {
            NXMyVaultFileDownloadAPIResponse *downloadResponse = (NXMyVaultFileDownloadAPIResponse*)response;
            if (downloadResponse.rmsStatuCode == 200) {
                 [self finish:YES];
                if (self.completion) {
                    self.completion(self.destFile, downloadResponse.fileName, downloadResponse.fileData, nil);
                }
                
                if(self.webFileDownloadCompletion && !self.isCancelled){
                    self.webFileDownloadCompletion(self.destFile, downloadResponse.fileData, nil);
                }
               
            }else
            {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                if (self.completion) {
                    self.completion(self.destFile, nil, nil, restError);
                }
                
                if(self.webFileDownloadCompletion && !self.isCancelled){
                    self.webFileDownloadCompletion(self.destFile, nil, restError);
                }
                [self finish:NO];
                
            }
        }else
        {
            if (self.completion) {
                self.completion(self.destFile, nil, nil, error);
            }
            
            if(self.webFileDownloadCompletion && !self.isCancelled){
                self.webFileDownloadCompletion(self.destFile, nil, error);
            }
            [self finish:NO];
        }
    }];
    [self didChangeValueForKey:@"isExcuting"];
}

#pragma mark - Private method
-(void)finish:(BOOL) isSuccessful
{
        [self willChangeValueForKey:@"isExcuting"];
        [self willChangeValueForKey:@"isFinished"];
        if (!isSuccessful && !self.isCancelled) {
            [self cancel]; 
        }
        self.state = NXDownloadFileFromMyVaultFolderOperationStateDownloadFileFinished;
        [self didChangeValueForKey:@"isExcuting"];
        [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NXWebFileDownloadOperation
- (void)prepareDownloadFile:(NXFileBase *)file withProgress:(NSProgress *)progress completion:(NXWebFileDownloadOperationCompletionBlock)completion
{
    self.destFile = (NXMyVaultFile *)file;
    self.downloadProgress = progress;
    self.webFileDownloadCompletion = completion;
    
}

- (void)cancelDownload
{
    [self cancel];
    [self.downloadRequest cancelRequest];
    if (self.isExecuting) {
        [self willChangeValueForKey:@"isExcuting"];
        [self willChangeValueForKey:@"isFinished"];
        self.state = NXDownloadFileFromMyVaultFolderOperationStateDownloadFileFinished;
        [self didChangeValueForKey:@"isExcuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
}

@end
