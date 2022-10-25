//
//  NXUpdateProfileAPI.h
//  nxrmc
//
//  Created by nextlabs on 12/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXUpdateProfileAPIRequestModel : NSObject

@property(nonatomic, strong) NSString *displayname;
@property(nonatomic, strong) NSString *avatorimage;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *ticket;
@property(nonatomic, assign) BOOL isChangeImage;
- (instancetype)initWithDisplayName:(NSString *)name isChangeImage:(BOOL)isChangeImage avatorData:(NSString *)base64Str userid:(NSString *)userid ticket:(NSString *)ticket;
- (NSData *)generateBodyData;

@end

@interface NXUpdateProfileAPI : NXSuperRESTAPIRequest

- (instancetype)initWIthModel:(NXUpdateProfileAPIRequestModel *)model;

@end
