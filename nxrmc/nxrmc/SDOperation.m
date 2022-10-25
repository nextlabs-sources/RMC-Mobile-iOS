//
//  SDOperation.m
//  nxrmc
//
//  Created by nextlabs on 10/25/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "SDOperation.h"

@implementation SDOperation

- (instancetype)initWithPath:(NSString *)path method:(SDMethodType)method api:(NXSuperRESTAPIRequest *)api {
    if (self = [super init]) {
        self.path = path;
        self.method = method;
        self.restAPI = api;
    }
    return self;
}

@end
