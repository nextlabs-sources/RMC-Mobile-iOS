//
//  NXSharedWithMeFileListParameterModel.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSharedWithMeFileListParameterModel.h"

@implementation NXSharedWithMeFileListParameterModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.size = 1000;
        self.searchByType = NXSharedWithMeFileListSearchFileByName;
        self.orderByType = NXSharedWithMeFileListOrderBySharedDateDescending;
        self.searchString = @"";
    }
    return self;
}
@end
