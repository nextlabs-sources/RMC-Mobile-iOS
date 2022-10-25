//
//  NXMyVaultGetFileListOperation.m
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGetFileListInMyVaultFolderOperation.h"
#import "NXMyVaultFileListAPI.h"
#import "NXMyVaultFile.h"
#import "NXRMCDef.h"

typedef NS_ENUM(NSInteger, NXGetFileListInMyVaultFolderOperationState)
{
    NXGetFileListInMyVaultFolderOperationStateGettingFiles = 1,
    NXGetFileListInMyVaultFolderOperationStateGetFilesFinished,
};

@interface NXGetFileListInMyVaultFolderOperation()
@property(nonatomic, strong) NXFileBase *parentFolder;
@property(nonatomic, strong) NSArray *fileListArray;
@property(nonatomic, assign) NXGetFileListInMyVaultFolderOperationState state;
@property(nonatomic, strong) NXMyVaultListParModel *filterModel;
@end

@implementation NXGetFileListInMyVaultFolderOperation
- (instancetype)initWithParentFolder:(NXFileBase *)parentFolder filterModel:(NXMyVaultListParModel *)filterModel
{
    self = [super init];
    if (self) {
        _parentFolder = parentFolder;
        _filterModel = filterModel;
    }
    return self;
}

-(NXGetFileListInMyVaultFolderOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXGetFileListInMyVaultFolderOperationState) newState
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
    return self.state == NXGetFileListInMyVaultFolderOperationStateGetFilesFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXGetFileListInMyVaultFolderOperationStateGettingFiles;
}

- (void)cancel
{
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
        self.state = NXGetFileListInMyVaultFolderOperationStateGetFilesFinished;
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
    
    [self willChangeValueForKey:@"isExcuting"];
    NXMyVaultFileListAPIRequest *request = [[NXMyVaultFileListAPIRequest alloc] init];
    self.state =NXGetFileListInMyVaultFolderOperationStateGettingFiles;

    __weak typeof(self) weakSelf = self;
    [request requestWithObject:self.filterModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXMyVaultFileListAPIResponse *myVaultFileListResponse = (NXMyVaultFileListAPIResponse *)response;
            if (myVaultFileListResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) { // success
               
                if (weakSelf.completion) {
                    for (NXMyVaultFile *file in myVaultFileListResponse.fileList) {
                        file.sorceType = NXFileBaseSorceTypeMyVaultFile;
                    }
                    weakSelf.completion(myVaultFileListResponse.fileList, weakSelf.parentFolder, weakSelf.filterModel, nil);
                }
                [weakSelf finish:YES];
            }else{
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                if (weakSelf.completion) {
                    weakSelf.completion(nil, weakSelf.parentFolder, weakSelf.filterModel, restError);

                }
                [weakSelf finish:NO];
            }
        }else{
            if (weakSelf.completion) {
                weakSelf.completion(nil, weakSelf.parentFolder, weakSelf.filterModel, error);
            }
            [weakSelf finish:NO];
        }
    }];
    [self didChangeValueForKey:@"isExcuting"];
}

#pragma mark - Private method
-(void)finish:(BOOL) isSuccessful
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (!isSuccessful) {
        [self cancel];
    }
    self.state = NXGetFileListInMyVaultFolderOperationStateGetFilesFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
