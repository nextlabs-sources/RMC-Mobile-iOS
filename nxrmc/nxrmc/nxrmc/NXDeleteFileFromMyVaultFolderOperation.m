//
//  NXDeleteFileFromMyVaultFolderOperation.m
//  nxrmc
//
//  Created by nextlabs on 1/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDeleteFileFromMyVaultFolderOperation.h"

#import "NXMyVaultFileDeleteAPI.h"
#import "NXRMCDef.h"

typedef NS_ENUM(NSInteger, NXDeleteFileFromMyVaultFolderOperationState)
{
    NXDeleteFileFromMyVaultFolderOperationStateDeleteFile = 1,
    NXDeleteFileFromMyVaultFolderOperationStateDeleteFileFinished,
};

@interface NXDeleteFileFromMyVaultFolderOperation ()

@property(nonatomic, strong) NXMyVaultFile *file;
@property(nonatomic, assign) NXDeleteFileFromMyVaultFolderOperationState state;

@end

@implementation NXDeleteFileFromMyVaultFolderOperation
- (instancetype) initWithFile:(NXMyVaultFile *)file
{
    if (self = [super init]) {
        _file = file;
    }
    return self;
}

-(NXDeleteFileFromMyVaultFolderOperationState) state
{
    @synchronized (self) {
        return _state;
    }
}

-(void) state:(NXDeleteFileFromMyVaultFolderOperationState) newState
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
    return self.state == NXDeleteFileFromMyVaultFolderOperationStateDeleteFileFinished;
}

- (BOOL)isExecuting
{
    return self.state == NXDeleteFileFromMyVaultFolderOperationStateDeleteFile;
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
    
    NXMyVaultFileDeleteAPI *deleteRequest = [[NXMyVaultFileDeleteAPI alloc] init];
    WeakObj(self);
    [deleteRequest requestWithObject:self.file Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (error) {
            if (self.completion) {
                self.completion(self.file, error);
            }
            [self finish:NO];
            return;
        }
        NXSuperRESTAPIResponse *deleteResponse = (NXSuperRESTAPIResponse *)response;
        if (deleteResponse.rmsStatuCode == 200) {
            if (self.completion) {
                self.completion(self.file, nil);
            }
        } else {
            NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
            if (self.completion) {
                self.completion(self.file, restError);
            }
            [self finish:NO];
        }
    }];
    
    [self didChangeValueForKey:@"isExcuting"];
}

- (void)cancel
{
    [super  cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.state = NXDeleteFileFromMyVaultFolderOperationStateDeleteFileFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
    
}
#pragma mark - Private method
-(void)finish:(BOOL) isSuccessful
{
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    if (!isSuccessful) {
        [self cancel];
    }
    self.state = NXDeleteFileFromMyVaultFolderOperationStateDeleteFileFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
