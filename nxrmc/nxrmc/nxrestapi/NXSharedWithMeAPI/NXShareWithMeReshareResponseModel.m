//
//  NXShareWithMeReshareResponseModel.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXShareWithMeReshareResponseModel.h"

@implementation NXShareWithMeReshareResponseModel

- (instancetype)initWithNSDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _freshSharedList = [[NSArray alloc] init];
        _alreadySharedList = [[NSArray alloc] init];
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"newTransactionId"]) {
        self.freshTransactionId = value;
    }
    if ([key isEqualToString:@"newSharedList"]) {
        self.freshSharedList = value;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    NXShareWithMeReshareResponseModel *model = [[NXShareWithMeReshareResponseModel alloc]init];
    model.freshTransactionId = [self.freshTransactionId copy];
    model.sharedLink = [self.sharedLink copy];
    model.freshSharedList = [self.freshSharedList copy];
    model.alreadySharedList = [self.alreadySharedList copy];
    return model;
}
@end
