//
//  NXNetworkHelper.m
//  nxrmc
//
//  Created by helpdesk on 11/6/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "NXNetworkHelper.h"


static NXNetworkHelper* sharedObj = nil;

@interface NXNetworkHelper()

@end

@implementation NXNetworkHelper

+ (NXNetworkHelper*) sharedInstance
{
    @synchronized(self)
    {
        if (sharedObj == nil) {
            sharedObj = [[super allocWithZone:nil] init];
        }
    }

    return sharedObj;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return nil;
}

- (id) init
{
    if (self = [super init]) {
    }
    
    return self;
}

- (BOOL)isNetworkAvailable
{
//    return [AFNetworkReachabilityManager sharedManager].isReachable;
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return NO;
    }
    return YES;
}

- (BOOL)isWWANEnabled
{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}

- (BOOL)isWifiEnabled
{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}

- (AFNetworkReachabilityStatus)getNetworkStatus
{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

- (void)startNotifier
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
- (void)stopNotifier
{

    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

@end
