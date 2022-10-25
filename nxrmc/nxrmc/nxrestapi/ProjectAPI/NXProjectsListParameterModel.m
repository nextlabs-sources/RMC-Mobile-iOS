//
//  NXProjectsListParameterModel.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 12/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectsListParameterModel.h"

@implementation NXProjectsListParameterModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = @"1";
        self.size = @"1000";
        self.orderByType = NXProjectsListOrderByTypeLastActionTimeDescending;
        self.ownerByType = NXProjectsListOwnerByTypeforAll;
    }
    return self;
}
@end
