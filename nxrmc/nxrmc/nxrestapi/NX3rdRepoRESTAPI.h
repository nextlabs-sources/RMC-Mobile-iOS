//
//  NX3rdRepoRESTAPIRequest.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/10/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NX3rdRepoRESTAPIRequest : NXSuperRESTAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo accessTokenKeyword:(NSString *)accessTokenKeyword;

@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, strong) NSString *accessTokenKeyword;
@end

@interface NX3rdRepoRESTAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, assign) BOOL isAccessTokenExpireError;
@end
