//
//  NXProfilePageCellModel.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXProfilePageCellModel.h"

@implementation NXProfilePageCellModel

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message operation:(NSString *)operation {
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.operation = operation;
    }
    return self;
}

@end
