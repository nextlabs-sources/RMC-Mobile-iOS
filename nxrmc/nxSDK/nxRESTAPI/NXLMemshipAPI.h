//
//  NXMemshipAPI.h
//  nxrmc
//
//  Created by nextlabs on 6/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLSuperRESTAPI.h"

@interface NXLMemshipAPIRequestModel : NSObject

@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *tickect;
@property(nonatomic, strong) NSString *membership;
@property(nonatomic, strong) NSString *publicKey;

- (instancetype)initWithUserId:(NSString *)userid ticket:(NSString *)ticket membership:(NSString *)membership publickey:(NSString *)publicKey;

- (NSData *)generateBodyData;

@end

@interface NXLMemshipAPIResponse : NXLSuperRESTAPIResponse

@property(nonatomic, strong) NSMutableDictionary *results;

@end

@interface NXLMemshipAPI : NXLSuperRESTAPIRequest

- (instancetype)initWithRequest:(NXLMemshipAPIRequestModel *)requestModel;

@end
