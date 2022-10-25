//
//  NXSharePointFolder.m
//  nxrmc
//
//  Created by ShiTeng on 15/5/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXSharePointFolder.h"

#define NXSHAREPOINTCODINGCHIDREN              @"NXSharePointSiteCodingChildren"
#define NXSHAREPOINTCODINGFOLDERTYPE           @"NXSharePointSiteCodingFolderType"
#define NXSHAREPOINTCODINGOWNERSITE            @"NXSharePointSiteCodingOwnerSite"
@implementation NXSharePointFolder

#pragma mark implementation of NXFileProtocol
- (void) addChild: (NXFileBase*) child
{
    for (NXFileBase* f in self.children) {
        if ([f.fullServicePath isEqualToString:child.fullServicePath]) {
            [self.children removeObject:f];
            [self removeAllFavoriteChildren:f];
            break;
        }
    }
    
    [self.children addObject:child];
    child.parent = self;
}

- (void)removeChild:(NXFileBase *)child
{
    if ([self.children containsObject: child]) {
        [self.children removeObject:child];
        [self removeAllFavoriteChildren:child];
    }
}

- (NSArray*) getChildren
{
    return self.children;
}

-(void) removeAllFavoriteChildren:(NXFileBase *)file
{
//    if ([file isKindOfClass:[NXSharePointFolder class]]) {
//        for (NXFileBase *child in [file getChildren]) {
//            [self removeAllFavoriteChildren:child];
//        }
//    }
//    [[self ancestor].favoriteFileList removeNode:file];
//    [[self ancestor].offlineFileList removeNode:file];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[NSNumber numberWithInt:_folderType] forKey:NXSHAREPOINTCODINGFOLDERTYPE];
    [aCoder encodeObject:_ownerSiteURL forKey:NXSHAREPOINTCODINGOWNERSITE];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _folderType = [[aDecoder decodeObjectForKey:NXSHAREPOINTCODINGFOLDERTYPE] intValue];
        _ownerSiteURL = [aDecoder decodeObjectForKey:NXSHAREPOINTCODINGOWNERSITE];
    }
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    NXSharePointFolder *newItem = [super copyWithZone:zone];
    newItem.ownerSiteURL = [_ownerSiteURL copy];
    newItem.folderType = _folderType;
    return newItem;
}

@end
