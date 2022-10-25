//
//  NXTenant.m
//  nxSDK
//
//  Created by EShi on 8/31/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLTenant.h"
#import "NXLRouterLoginPageURL.h"
#import "NXLoginPageViewController.h"

static NXLTenant * __tenant = nil;

@interface NXLTenant ()

@property(nonatomic, copy) NSString *tenantID;
@property(nonatomic, strong) NSString *rmsServerAddress;

@end
@implementation NXLTenant

- (instancetype)initPrave
{
    self = [super init];
    if (self) {
    }
    return self;
}
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __tenant= [[NXLTenant alloc]initPrave];
    });
    return __tenant;
}
- (instancetype)init {
    return [[self class] sharedInstance];
}
+ (void)setCurrentTenantWithID:(NSString *)tenantID {
    
    __tenant = [[NXLTenant alloc]init];
    __tenant.tenantID = tenantID;
}

+ (void) setCurrentTenantWithID:(NSString *)tenantID rmsServer:(NSString *) rmsServerAddress
{
    __tenant = [[NXLTenant alloc]init];
    __tenant.tenantID = tenantID;
    __tenant.rmsServerAddress = rmsServerAddress;
}
+ (NXLTenant *)currentTenant {
    if (__tenant) {
        return __tenant;
    }
    return nil;
}

+ (void)logInClientWithCompletion:(NXLClientLogInCompletion) completion {
   
     NXLoginPageViewController * discoveryViewController = [[NXLoginPageViewController alloc]init];
    discoveryViewController.completion=completion;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:navController animated:YES completion:nil];
    
}
#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_tenantID forKey:@"tenantID"];
    [aCoder encodeObject:_rmsServerAddress forKey:@"rmsServerAddress"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _tenantID = [aDecoder decodeObjectForKey:@"tenantID"];
        _rmsServerAddress = [aDecoder decodeObjectForKey:@"rmsServerAddress"];
    }
    return self;
}

@end
