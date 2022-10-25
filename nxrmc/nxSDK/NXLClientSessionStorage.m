//
//  NXClientSessionStorage.m
//  nxSDK
//
//  Created by EShi on 8/31/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLClientSessionStorage.h"

#import "NXLClient.h"
#import "NXLTenant.h"

#import "NXLKeyChain.h"

#define  kClientKeyChain @"NXLKeychainKey" //we store all client into keychine, this paramter used as key-value's key.

static NXLClientSessionStorage *sharedObj = nil;

@interface NXLClientSessionStorage ()

@property(nonatomic, strong) NSMutableDictionary *clients;

@end

@implementation NXLClientSessionStorage

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[NXLClientSessionStorage alloc]initPrivate];
    });
    return sharedObj;
}

//+ (instancetype)allocWithZone:(struct _NSZone *)zone {
//    return [[self class] sharedInstance];
//}
//
//- (instancetype)copyWithZone:(NSZone *)zone {
//    return [[self class] sharedInstance];
//}

- (instancetype)init {
    return [[self class] sharedInstance];
}

#pragma mark

- (instancetype)initPrivate {
    if (self = [super init]) {
        [self loadAllClients];
    }
    return self;
}

- (NSString *)generateKeyFromClient:(NXLClient *)client {
    return [self generateKey:client.userID tenant:client.userTenant];
}

- (NSString *)generateKey:(NSString *)userID tenant:(NXLTenant *)tenant {
    return [NSString stringWithFormat:@"%@_%@", userID, tenant.tenantID];
}

- (void)loadAllClients {
    @synchronized (self.clients) {
        self.clients = [NXLKeyChain load:kClientKeyChain];
        if (!self.clients) {
            self.clients = [NSMutableDictionary dictionary];
        }
    }
}

- (void)storeAllClients {
    @synchronized (self.clients) {
        [NXLKeyChain save:kClientKeyChain data:self.clients];
    }
}

#pragma mark - public method

- (NXLClient *)getClientWithTenant:(NXLTenant *)tenant userID:(NSString *)userID {
    NSString *key = [self generateKey:userID tenant:tenant];
    @synchronized (self.clients) {
        return [self.clients objectForKey:key];
    }
    return nil;
}

- (void)storeClient:(NXLClient *)client {
    if (client == nil) {
        return;
    }
    
    NSString *key = [self generateKeyFromClient:client];
    @synchronized (self.clients) {
        if (![self.clients objectForKey:key]) {
            [self.clients setObject:client forKey:key];
        } else {
            return;
        }
    }
    
    [self storeAllClients];
}

- (void)delClient:(NXLClient *)client {
    if (client == nil) {
        return;
    }
    
    NSString *key = [self generateKeyFromClient:client];
    @synchronized (self.clients) {
        if ([self.clients objectForKey:key]) {
            [self.clients removeObjectForKey:key];
        } else {
            return;
        }
    }
    
    [self storeAllClients];
}

@end
