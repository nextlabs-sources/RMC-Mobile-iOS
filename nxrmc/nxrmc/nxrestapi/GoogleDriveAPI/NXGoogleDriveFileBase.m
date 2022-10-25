//
//  NXGoogleDriveFileBase.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 18/07/2017.
//  Copyright © 2017 Stepanoval (Xinxin) Huang. All rights reserved.
//

#import "NXGoogleDriveFileBase.h"

@implementation NXGoogleDriveFileBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        _parents = [[NSArray alloc] init];
    }
    return self;
}

@end
