//
//  NX3rdRepoRESTAPIRequest.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/10/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NX3rdRepoRESTAPI.h"

@implementation NX3rdRepoRESTAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo accessTokenKeyword:(NSString *)accessTokenKeyword {
    if (self = [super init]) {
        _repo = repo;
        _accessTokenKeyword = accessTokenKeyword;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"use initWithRepo:accessTokenKeyword: to init");
    return nil;
}

- (NXRepositoryModel *)repo {
    return _repo;
}

- (NSString *)accessTokenKeyword {
    return _accessTokenKeyword;
}
@end

@implementation NX3rdRepoRESTAPIResponse
@end
