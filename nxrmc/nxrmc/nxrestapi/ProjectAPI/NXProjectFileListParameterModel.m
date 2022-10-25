//
//  NXProjectFileListModel.m
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectFileListParameterModel.h"

@implementation NXProjectFileListParameterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = @"1";
        self.size = @"1000";
        self.parentPath = @"/";
        self.orderByType = NXProjectListSortTypeFileNameAscending;
        self.filterType = NXProjectFileListFilterByTypeAllFiles;
    }
    return self;
}
@end
