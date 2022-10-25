//
//  NXHeartbeatManager.m
//  nxrmc
//
//  Created by nextlabs on 7/15/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXHeartbeatManager.h"
#import "NXHeartbeatAPI.h"
#import "NXOverlayTextInfo.h"
#import "NXCacheManager.h"
#import "NSData+Encryption.h"
#import "NSString+Utility.h"

#import "NXLoginUser.h"
#import "NXLProfile.h"

static NSLock* gLock = nil;

static NXHeartbeatManager *instance = nil;

@interface NXHeartbeatManager ()

@property(nonatomic, strong) NSTimer *heartbeatTimer;
@property(nonatomic, assign) BOOL needExit;
@property(nonatomic, assign) BOOL heartBeatStarted;

@end

@implementation NXHeartbeatManager

+ (instancetype)sharedInstance {
    static NXHeartbeatManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self  alloc] init];
        gLock = [[NSLock alloc] init];
    });
    return instance;
}

- (void)stop {
    _needExit = YES;
}

- (void)start {
    if (_heartBeatStarted) {
        return;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            _needExit = NO;
            _heartBeatStarted = YES;
            _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:6000 target:self selector:@selector(getPolicyTimer:) userInfo:nil repeats:YES];
            [_heartbeatTimer fire];
            NSRunLoop* loop = [NSRunLoop currentRunLoop];
            do
            {
                @autoreleasepool
                {
                    [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
                    if (_needExit) {
                        [_heartbeatTimer invalidate];
                        break;
                    }
                    
                    [NSThread sleepForTimeInterval:1.0f];
                }
            }while (true);
            NSLog(@"HeartBeart thread quite");
            _heartBeatStarted = NO;
        }
    });
}

- (void)getPolicyTimer : (NSTimer*) timer {
    NXHeartbeatAPI *api = [[NXHeartbeatAPI alloc] init];
    [api requestWithObject:[NXLoginUser sharedInstance].profile Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            NSLog(@"NXHeartbeatAPI error: %@", error);
        } else {
            if ([response isKindOfClass:[NXHeartbeatAPIResponse class]]) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:response];
                data = [data AES256ParmEncryptWithKey:[[NXLoginUser sharedInstance].profile.ticket lowercaseFirstChar]];
                [self saveFile:data documentURL:[NXCacheManager getHeartbeatCacheURL]];

            }
        }
    }];
}

- (NSData *)readFromFile {
    NSURL * documentURL = [[NXCacheManager getHeartbeatCacheURL] URLByAppendingPathComponent:@"cache.file" isDirectory:NO];
    [gLock lock];
    NSData *data = [NSData dataWithContentsOfURL:documentURL];
    data = [data AES256ParmDecryptWithKey:[[NXLoginUser sharedInstance].profile.ticket lowercaseFirstChar]];
    [gLock unlock];
    return data;
}
- (void)saveFile:(NSData*)data documentURL:(NSURL*)documentURL
{
    if (documentURL == nil || data == nil) {
        return;
    }
    documentURL = [documentURL URLByAppendingPathComponent:@"cache.file" isDirectory:NO];
    [gLock lock];
    NSError *error;
    BOOL bret = [data writeToURL:documentURL options:NSDataWritingFileProtectionNone error:&error];
    [gLock unlock];
    if(bret) {
        NSLog(@"restAPIResponse, saved to local disk successfully");
    } else {
        NSLog(@"restAPIResponse, saved to local disk fail");
    }
}
#pragma mark - Public interface
- (NXOverlayTextInfo *)getOverlayTextInfo {
    NSData *data = [self readFromFile];
    if (data) {
        NXHeartbeatAPIResponse *response = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NXOverlayTextInfo *info = [[NXOverlayTextInfo alloc] initWithObligation:response];
        return info;
    }else
    {
        return nil;
    }
    
}
@end

