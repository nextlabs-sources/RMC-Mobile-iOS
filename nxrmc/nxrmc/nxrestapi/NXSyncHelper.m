//
//  NXSyncHelper.m
//  nxrmc
//
//  Created by EShi on 7/8/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "NXRMCDef.h"
#import "NXRMCStruct.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXRemoveRepositoryAPI.h"
#import "NXSyncREPOOperation.h"
@interface NXSyncHelper()
@property(nonatomic, readwrite, strong) dispatch_queue_t uploadPerviousFailedRESTQueue;
@property(nonatomic, strong) NSOperationQueue *syncRESTOperationQueue;
@end

@implementation NXSyncHelper
+(instancetype) sharedInstance
{
    static NXSyncHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self  alloc] init];
    });
    return instance;
}

-(instancetype) init
{
    self = [super init];
    if (self) {
        NSString *queueName = [NSString stringWithFormat:@"com.nextlabs.rightsmanagementclient.%@", NSStringFromClass([self class])];
        _uploadPerviousFailedRESTQueue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_SERIAL);
        _syncRESTOperationQueue = [NSOperationQueue new];
        _syncRESTOperationQueue.name = @"com.skydrm.rmc.NXSyncHelper";
    }
    return self;
}


- (void)cacheRESTAPI:(NXSuperRESTAPIRequest *) restAPI cacheURL:(NSURL *) cacheURL
{
    dispatch_async(_uploadPerviousFailedRESTQueue, ^{
        [NXCacheManager cacheRESTReq:restAPI cacheURL:cacheURL];
    });
}

- (void)cacheRESTAPI:(NXSuperRESTAPIRequest *)restAPI directlyURL:(NSURL *)cacheURL
{
    dispatch_async(_uploadPerviousFailedRESTQueue, ^{
        [NXCacheManager cacheRESTReq:restAPI directlyCacheURL:cacheURL];
    });
}

- (void)removeCachedRESTAPI:(NXSuperRESTAPIRequest *)restAPI cacheURL:(NSURL *)cacheURL
{
    dispatch_async(_uploadPerviousFailedRESTQueue, ^{
        [NXCacheManager deleteCachedRESTReq:restAPI cacheURL:cacheURL];
    });
}

- (void)removeCachedRESTAPI:(NXSuperRESTAPIRequest *)restAPI directlyCacheURL:(NSURL *)cacheURL
{
    dispatch_async(_uploadPerviousFailedRESTQueue, ^{
        [NXCacheManager deleteCachedRESTByURL:cacheURL];
    });
}

- (void)syncCacheRESTAPI:(NXSuperRESTAPIRequest *) restAPI cacheURL:(NSURL *) cacheURL
{
    dispatch_sync(_uploadPerviousFailedRESTQueue, ^{
        [NXCacheManager cacheRESTReq:restAPI cacheURL:cacheURL];
    });
}

-(void)uploadPreviousFailedRESTRequestWithCachedURL:(NSURL *) cachedURL mustAllSuccess:(BOOL) mustAllSuccess Complection:(UploadFailedRESTRequestComplection) complectionBlock
{
    dispatch_async(_uploadPerviousFailedRESTQueue, ^{
        
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *fileList = [fileManager contentsOfDirectoryAtURL:cachedURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
        fileList = [fileList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.absoluteString ENDSWITH '%@'", NXREST_CACHE_EXTENSION]]];
        
        if (fileList.count == 0) {
            complectionBlock(nil, nil);
            return;
        }
        
        if (error) {
            complectionBlock(nil, error);
            return;
        }
        
        __block BOOL errOccured = NO;
        NSMutableArray *optArray = [NSMutableArray new];
        for (NSURL *cacheURL in fileList) {
            NXSyncREPOOperation *syncRESTOPt = [[NXSyncREPOOperation alloc] initWithRESTAPICacheURL:cacheURL];
            syncRESTOPt.complete = ^(NSError *error) {
                if (error) {
                    errOccured = YES;
                }
            };
            [optArray addObject:syncRESTOPt];
        }
        [self.syncRESTOperationQueue addOperations:optArray waitUntilFinished:YES];

        // Only all rest api finished, we do next thing
        if (errOccured) {
            error = [NSError errorWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_REST_UPLOAD_FAILED userInfo:nil];
            if (complectionBlock) {
                complectionBlock(nil, error);
                
            }
        }else
        {
            if (complectionBlock) {
                complectionBlock(nil, nil);
            }
        }
    });
}

@end
