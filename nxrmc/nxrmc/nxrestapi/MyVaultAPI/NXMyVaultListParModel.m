//
//  NXVaultListParModel.m
//  nxrmc
//
//  Created by helpdesk on 29/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXMyVaultListParModel.h"

@implementation NXMyVaultListParModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = @"1";
        self.size = @"10000";
        self.filterType = NXMyvaultListFilterTypeAllFiles;
        self.sortOptions = @[@(NXMyVaultListSortTypeCreateTimeAscending)];
        self.searchString = @"";
    }
    return self;
}
@end
