//
//  NXSyncREPOOperation.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 9/1/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSyncREPOOperation.h"
#import "NXSuperRESTAPI.h"
@interface NXSyncREPOOperation()
@property(nonatomic, strong) NSURL *cachedURL;
@property(nonatomic, strong) NXSuperRESTAPIRequest *request;
@end

@implementation NXSyncREPOOperation

- (instancetype)initWithRESTAPICacheURL:(NSURL *)cachedURL
{
    if (self = [super init]) {
        _cachedURL = cachedURL;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NSData *restReqData = [NSData dataWithContentsOfURL:self.cachedURL];
    if (restReqData) {
        
        NXSuperRESTAPIRequest *restAPI = [NSKeyedUnarchiver unarchiveObjectWithData:restReqData];
        self.request = restAPI;
        if (restAPI) {
            WeakObj(self);
            [restAPI requestWithObject:restAPI.reqBodyData Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                StrongObj(self);
                if (self) {
                    if ([response isKindOfClass:[NXSuperRESTAPIResponse class]]) {
                        // do nothing
                    }
                    
                    if (error){
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                        [self finish:error];
                    }else
                    {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        // no error occur, delete the cache file
                        [fileManager removeItemAtURL:self.cachedURL error:nil];
                        [self finish:nil];
                    }
                }
            }];
        }else{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            // no error occur, delete the cache file
            [fileManager removeItemAtURL:self.cachedURL error:nil];
            [self finish:nil];
        }
        
        
    }else{
        // if can't extract data, return with no error
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // no error occur, delete the cache file
        [fileManager removeItemAtURL:self.cachedURL error:nil];
        [self finish:nil];
    }
}

- (void)workFinished:(NSError *)error
{
    self.complete(error);
}


- (void)cancelWork:(NSError *)cancelError
{
    [self.request cancelRequest];
}

@end
