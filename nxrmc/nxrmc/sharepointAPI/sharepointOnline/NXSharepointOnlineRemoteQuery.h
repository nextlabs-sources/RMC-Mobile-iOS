//
//  NXSharepointOnlineRemoteQuery.h
//  NXsharepointonline
//
//  Created by nextlabs on 5/28/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSharePointQueryBase.h"

@interface NXSharepointOnlineRemoteQuery : NXSharePointRemoteQueryBase

@property (nonatomic, strong) NSString* requestMethod;
@property (nonatomic, strong) NSString* repoId;

- (instancetype) initWithURL:(NSString*)url cookies:(NSArray*)cookies;
- (instancetype) initWithURL:(NSString*)url repoId:(NSString *)repoId;

@end


