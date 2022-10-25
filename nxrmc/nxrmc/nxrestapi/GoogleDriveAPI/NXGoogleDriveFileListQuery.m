//
//  NXGoogleDriveFileListQuery.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 18/07/2017.
//  Copyright © 2017 Stepanoval (Xinxin) Huang. All rights reserved.
//

#import "NXGoogleDriveFileListQuery.h"

@implementation NXGoogleDriveFileListQuery

@synthesize corpora = _corpora,
            corpus = _corpus,
            includeTeamDriveItems = _includeTeamDriveItems,
            orderBy = _orderBy,
            pageSize = _pageSize,
            pageToken = _pageToken,
            q = _q,
            spaces = _spaces,
            teamDriveId = _teamDriveId,
            fields = _fields,
            supportsTeamDrives = _supportsTeamDrives;

- (id)init
{
    self = [super init];
    if (self) {
        _corpora = @"user";
        _corpus = @"";
        _includeTeamDriveItems = false;
        _orderBy = @"folder";
        _pageSize = 1000;
        _pageToken = @"";
        _q = @"";
        _spaces = @"drive";
        _supportsTeamDrives = false;
        _teamDriveId = @"";
        _fields = @"files(mimeType,id,kind,name,modifiedTime,size)";
    }
    return self;
}

+ (instancetype)query
{
    NXGoogleDriveFileListQuery *fileListQuery = [[self alloc] init];
    return fileListQuery;
}

- (id)copyWithZone:(NSZone *)zone {
    NXGoogleDriveFileListQuery *newFileListQuery = [[[self class] allocWithZone:zone] init];
    newFileListQuery.corpora = self.corpora;
    newFileListQuery.corpus = self.corpus;
    newFileListQuery.includeTeamDriveItems = self.includeTeamDriveItems;
    newFileListQuery.orderBy = self.orderBy;
    newFileListQuery.pageSize = self.pageSize;
    newFileListQuery.pageToken = self.pageToken;
    newFileListQuery.q = self.q;
    newFileListQuery.spaces = self.spaces;
    newFileListQuery.supportsTeamDrives = self.supportsTeamDrives;
    newFileListQuery.teamDriveId = self.teamDriveId;
    newFileListQuery.fields = self.fields;
    return newFileListQuery;
}

#pragma mark -NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.corpora forKey:NSStringFromSelector(@selector(corpora))];
    [aCoder encodeObject:self.corpus forKey:NSStringFromSelector(@selector(corpus))];
    [aCoder encodeObject:@(self.includeTeamDriveItems) forKey:NSStringFromSelector(@selector(includeTeamDriveItems))];
    [aCoder encodeObject:self.orderBy forKey:NSStringFromSelector(@selector(orderBy))];
    [aCoder encodeObject:@(self.pageSize) forKey:NSStringFromSelector(@selector(pageSize))];
    [aCoder encodeObject:self.pageToken forKey:NSStringFromSelector(@selector(pageToken))];
    [aCoder encodeObject:self.q forKey:NSStringFromSelector(@selector(q))];
    [aCoder encodeObject:self.spaces forKey:NSStringFromSelector(@selector(spaces))];
    [aCoder encodeObject:@(self.supportsTeamDrives) forKey:NSStringFromSelector(@selector(supportsTeamDrives))];
    [aCoder encodeObject:self.teamDriveId forKey:NSStringFromSelector(@selector(teamDriveId))];
    [aCoder encodeObject:self.fields forKey:NSStringFromSelector(@selector(fields))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.pageSize = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(pageSize))] integerValue];
    self.corpora = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(corpora))];
    self.supportsTeamDrives = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(supportsTeamDrives))] integerValue];
    self.includeTeamDriveItems = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(includeTeamDriveItems))] integerValue];
    self.corpus = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(corpus))];
    self.orderBy = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(orderBy))];
    self.pageToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(pageToken))];
    self.q = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(q))];
    self.spaces = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(spaces))];
    self.teamDriveId = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(teamDriveId))];
    self.fields = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(fields))];
    
    return self;
}


@end
