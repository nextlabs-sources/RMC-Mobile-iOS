//
//  NXBoxGetUserInfoAPI.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/12/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXBoxGetUserInfoRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXBoxGetUserInfoResponse : NX3rdRepoRESTAPIResponse
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *login;
@property(nonatomic, strong) NSNumber *space_amount;
@property(nonatomic, strong) NSNumber *space_used;

@end
