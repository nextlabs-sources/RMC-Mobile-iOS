//
//  NXSharePointFile.m
//  nxrmc
//
//  Created by ShiTeng on 15/6/2.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//
#define NXSHAREPOINTCODINGOWNERSITE            @"NXSharePointSiteCodingOwnerSite"
#import "NXSharePointFile.h"
#import "NXFile.h"

@implementation NXSharePointFile
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
       [aCoder encodeObject:_ownerSiteURL forKey:NXSHAREPOINTCODINGOWNERSITE];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _ownerSiteURL = [aDecoder decodeObjectForKey:NXSHAREPOINTCODINGOWNERSITE];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NXSharePointFile *newItem = [super copyWithZone:zone];
    newItem.ownerSiteURL = [_ownerSiteURL copy];
    return newItem;
}

@end
