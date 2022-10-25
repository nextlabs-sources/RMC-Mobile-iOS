//
//  NXMetadataMyVaultFileOperation.m
//  nxrmc
//
//  Created by nextlabs on 1/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMetadataMyVaultFileOperation.h"

#import "NXMyVaultMetadataAPI.h"

#import "NXRMCDef.h"

typedef NS_ENUM(NSInteger, NXMetadataMyVaultFileOperationState) {
    NXMetaDataMyVaultFileState = 1,
    NXMetaDataMyVaultFileStateFinished,
};

@interface NXMetadataMyVaultFileOperation ()

@property(nonatomic, strong) NXMyVaultFile *file;
@property(nonatomic, assign) NXMetadataMyVaultFileOperationState state;

@end

@implementation NXMetadataMyVaultFileOperation
- (instancetype)initWithFile:(NXMyVaultFile *)file {
    if (self = [super init]) {
        _file = file;
    }
    return self;
}

- (NXMetadataMyVaultFileOperationState)state {
    @synchronized (self) {
        return _state;
    }
}

- (void)state:(NXMetadataMyVaultFileOperationState)newState {
    @synchronized (self) {
        _state = newState;
    }
}

-(void)dealloc {
    NSLog(@"I am dea");
}

#pragma mark - overwrite
#pragma mark - NSOperation Methods
- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished {
    return self.state == NXMetaDataMyVaultFileStateFinished;
}

- (BOOL)isExecuting {
    return self.state == NXMetaDataMyVaultFileState;
}

- (void)start {
    BOOL isDepenedCancel = NO;
    for (NSOperation * opt in self.dependencies) {
        if (opt.isCancelled) {
            isDepenedCancel = YES;
            break;
        }
    }
    
    if(self.isCancelled || isDepenedCancel) {[self finish:NO]; return;};
    
    [self willChangeValueForKey:@"isExcuting"];
    
    NXMyVaultMetadataRequest *metadataRequest = [[NXMyVaultMetadataRequest alloc] init];
    WeakObj(self);
    [metadataRequest requestWithObject:self.file Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (error) {
            if (self.completion) {
                self.completion(self.file, error);
            }
            [self finish:NO];
            return;
        }
        NXMyVaultMetadataResponse *metadataResponse = (NXMyVaultMetadataResponse *)response;
        if (metadataResponse.rmsStatuCode == 200) {
            self.file.protectedOn = metadataResponse.protectedOn;
            self.file.fileLink = metadataResponse.fileLink;
            self.file.rights = metadataResponse.rights;
            self.file.recipients = metadataResponse.recipients;
            self.file.validateFileModel = metadataResponse.validateDateModel;
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
    [super cancel];
    [self willChangeValueForKey:@"isExcuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.state = NXMetaDataMyVaultFileStateFinished;
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
    self.state = NXMetaDataMyVaultFileStateFinished;
    [self didChangeValueForKey:@"isExcuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
