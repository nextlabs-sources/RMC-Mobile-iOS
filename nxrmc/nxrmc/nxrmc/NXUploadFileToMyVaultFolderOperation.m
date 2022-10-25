//
//  NXUploadFileToMyVaultFolderOperation.m
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXUploadFileToMyVaultFolderOperation.h"
#import "NXMyVaultFileUploadAPI.h"
#import "NXMyVaultFile.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

typedef NS_ENUM(NSInteger, NXUploadFileToMyVaultFolderOperationState)
{
    NXUploadFileToMyVaultFolderOperationStateUploadingFiles = 1,
    NXUploadFileToMyVaultFolderOperationStateUploadFileFinished,
};

@interface NXUploadFileToMyVaultFolderOperation()
@property(nonatomic, strong) NXFileBase *destFolder;
@property(nonatomic, strong) NXFileBase *currentFileItem;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSData *fileData;
@property(nonatomic, assign) NXUploadFileToMyVaultFolderOperationState state;
@property(nonatomic, strong) NXMyVaultFileUploadAPIRequest *uploadRequest;

@end

@implementation NXUploadFileToMyVaultFolderOperation

- (instancetype)initWithParentFolder:(NXFileBase *)destFolder fileName:(NSString *)fileName fileItem:(NXFileBase *)fileItem fileData:(NSData *)fileData
{
    self = [super init];
    if (self) {
        _destFolder = destFolder;
        _fileName = fileName;
        _fileData = fileData;
        _currentFileItem = fileItem;
    }
    return self;
}

- (NXUploadFileToMyVaultFolderOperationState)state
{
    @synchronized (self) {
        return _state;
    }
}

- (void)state:(NXUploadFileToMyVaultFolderOperationState)newState
{
    @synchronized (self) {
        _state = newState;
    }
    
}

- (void)cancel
{
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
        self.state = NXUploadFileToMyVaultFolderOperationStateUploadFileFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    [self.uploadRequest cancelRequest];
    self.uploadRequest = nil;
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
    return self.state == NXUploadFileToMyVaultFolderOperationStateUploadFileFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXUploadFileToMyVaultFolderOperationStateUploadingFiles;
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
    
    NXMyVaultFileUploadAPIRequest *uploadRequest = [[NXMyVaultFileUploadAPIRequest alloc] init];
    self.uploadRequest = uploadRequest;
    
    NSString *srcRepoType;
  
    if (self.currentFileItem.sorceType == NXFileBaseSorceTypeLocal || self.currentFileItem.sorceType == NXFileBaseSorceType3rdOpenIn)
    {
        srcRepoType = [NSString stringWithFormat:@"local"];
    }
    else if (self.currentFileItem.sorceType == NXFileBaseSorceTypeLocalFiles)
    {
        srcRepoType = [NSString stringWithFormat:@"Files"];
    }
    else
    {
        srcRepoType = [NXCommonUtils rmcToRMSRepoType:self.currentFileItem.serviceType];
    }
    
    NSString *srcFilePathId = self.currentFileItem.fullServicePath;
    NSString *srcFilePathDisplay = self.currentFileItem.fullPath;
    NSString *srcRepoId = self.currentFileItem.repoId;
    NSString *srcRepoName = self.currentFileItem.serviceAlias;
    
    NSDictionary *parametersDic = @{@"parameters":@{@"srcPathId":srcFilePathId,@"srcPathDisplay":srcFilePathDisplay,@"srcRepoId":srcRepoId,@"srcRepoName":srcRepoName,@"srcRepoType":srcRepoType,@"userConfirmedFileOverwrite":@"true"}};
    NSDictionary *model = @{@"fileName":self.fileName, @"fileData":self.fileData,@"parameters":parametersDic};
    __weak typeof(self) weakSelf = self;
    
    [uploadRequest requestWithObject:model withUploadProgress:self.progress downloadProgress:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXMyVaultFileUploadAPIResponse *uploadResponse = (NXMyVaultFileUploadAPIResponse *)response;
            if (uploadResponse.rmsStatuCode == 200 || uploadResponse.rmsStatuCode == NXRMS_MYVAULT_UPLOAD_FILL_EXISTED) {
                if (weakSelf.completion) {
                    weakSelf.completion(uploadResponse.fileItem, weakSelf.destFolder, nil);
                    [weakSelf finish:YES];
                }
            }else if (uploadResponse.rmsStatuCode == NXRMS_MYVAULT_UPLOAD_VAULT_EXCEEDED) {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_MY_VAULT_DOMAIN code:NXRMC_ERROR_CODE_VAULT_FILE_SYS_MANAGER_VAULT_EXCEEDED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_VAULT_STORAGE_EXCEEDED", nil)}];
                weakSelf.completion(nil, weakSelf.destFolder, restError);
                [weakSelf finish:NO];
            }
            else
            {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                weakSelf.completion(nil, weakSelf.destFolder, restError);
                [weakSelf finish:NO];
            }
        }else{
        
            weakSelf.completion(nil, weakSelf.destFolder, error);
            [weakSelf finish:NO];
        }
    }];
    [self didChangeValueForKey:@"isExcuting"];
    
}

#pragma mark - private method
-(void)finish:(BOOL) isSuccessful
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (!isSuccessful) {
        [self cancel];
    }
    self.state = NXUploadFileToMyVaultFolderOperationStateUploadFileFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}
@end
