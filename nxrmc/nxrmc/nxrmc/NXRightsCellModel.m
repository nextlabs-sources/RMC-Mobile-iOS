//
//  NXRightsCellModel.m
//  nxrmc
//
//  Created by nextlabs on 11/16/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRightsCellModel.h"

@implementation NXRightsCellModel

- (instancetype)initWithTitle:(NSString *)title value:(long)value modelType:(MODELTYPE)modelType actived:(BOOL)active {
    if (self = [super init]) {
        _title = title;
        _value = value;
        _modelType = modelType;
        _active = active;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title value:(long)value modelType:(MODELTYPE)modelType actived:(BOOL)active extDic:(NSDictionary *)extDic
{
    if (self = [super init]) {
        _title = title;
        _value = value;
        _modelType = modelType;
        _active = active;
        _extDic = extDic;
    }
    
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    NXRightsCellModel *model = [[NXRightsCellModel alloc]init];
    model.title = [self.title copyWithZone:zone];
    model.value = self.value;
    model.active = self.active;
    model.modelType = self.modelType;
    
    return model;
}
@end
