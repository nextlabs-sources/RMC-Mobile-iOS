//
//  NXFileSys.m
//  nxrmc
//
//  Created by Kevin on 15/5/7.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXFileBase.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"



#define NXFILESYSCODINGNAME                 @"NXFileSysCodingName"
#define NXFILESYSCODINGFULLPATH             @"NXFileSysCodingFullPath"
#define NXFILESYSCODINGFULLSERVICEPATH      @"NXFileSysCodingFullServicePath"
#define NXFILESYSCODINGLOCALPATH            @"NXFIleSysCodingLocalPath"
#define NXFILESYSCODINGLASTMODIFIEDTIME     @"NXFileSysCodingLastModifiedTime"
#define NXFILESYSCODINGLASTMODIFIEDDATE     @"NXFileSysCodingLastModifiedDate"
#define NXFILESYSCODINGSIZE                 @"NXFileSysCodingSize"
#define NXFILESYSCODINGREFRESHDATE          @"NXFileSysCodingRefreshDate"
#define NXFILESYSCODINGPARENT               @"NXFileSysCodingParent"
#define NXFILESYSCODINGISROOT               @"NXFileSysCodingIsRoot"
#define NXFILESYSCODINGSERVICEALIAS         @"NXFileSysCodingServiceAlias"
#define NXFILESYSCODINGSERVICEACCOUNTID     @"NXFileSysCodingServiceAccountId"
#define NXFILESYSCODINGSERVICETYPE          @"NXFileSysCodingServiceType"
#define NXFILESYSCODINGSPSITE               @"NXFILESYSCODINGSPSITE"
#define NXFILESYSCODINGISFAVORITE           @"NXFileSysCodingIsFavorite"
#define NXFILESYSCODINGFAVORITEFILELIST     @"NXFileSysCodingFavoriteFileList"
#define NXFILESYSCODINGISOFFLINE            @"NXFileSysCodingIsOffline"
#define NXFILESYSCODINGOFFLINEFILELIST      @"NXFileSysCodingOfflineFileList"
#define NXFILESYSCODINGFAVORITEFILENODES    @"NXFileSysCodingFavoriteFileNODES"
#define NXFILESYSCODINGREPOID               @"NXFileSysCodingRepoId"
#define NXFILESYSCODINGSOURCETYPE           @"NXFileSysCodingSourceType"
@interface NXCustomFileList()

@property(nonatomic, strong) NSMutableArray *nodes;

@end

@implementation NXCustomFileList

- (instancetype) init
{
    if (self = [super init]) {
        _nodes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addNode:(NXFileBase *)node
{
    if (![self.nodes containsObject:node]) {
        [_nodes addObject:node];
    }
}

- (void) removeNode:(NXFileBase *)node
{
    if ([_nodes containsObject:node]) {
        [_nodes removeObject:node];
    }
}

- (NSArray *) allNodes
{
    return _nodes;
}

- (BOOL) containsObject:(NXFileBase *)node {
    return [_nodes containsObject:node];
}

- (NSInteger) count {
    return _nodes.count;
}

- (NXFileBase *) objectAtIndex:(NSInteger) index {
    return [_nodes objectAtIndex:index];
}

- (NSUInteger) IndexOfObject:(NXFileBase *) node
{
    return [_nodes indexOfObject:node];
}

#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_nodes forKey:NXFILESYSCODINGFAVORITEFILENODES];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _nodes = [aDecoder decodeObjectForKey:NXFILESYSCODINGFAVORITEFILENODES];
    }
    return self;
}

@end



@implementation NXFileBase

- (id) init
{
    if (self = [super init]) {
        _isRoot = NO;
    }
    
    return self;
}

- (id)initWithFileBaseSourceType:(NXFileBaseSorceType )type
{
    if (self = [super init]) {
        _isRoot = NO;
        
        if (type == NXFileBaseSorceTypeLocal) {
            _repoId = @"";
            _serviceAlias = @"local";
        }
        _sorceType = type;
    }
    
    return self;
}

-(void) addChild:(NXFileBase *)child
{
    return;
}

- (void) removeChild:(NXFileBase*) child
{
    return;
}

-(NSArray*) getChildren
{
    return nil;
}

- (NXFileBase *) ancestor
{
    if (self.isRoot) {
        return self;
    } else {
        return [self.parent ancestor];
    }
}

- (void) setIsFavorite:(BOOL)isFavorite
{
    _isFavorite = isFavorite;
    if (isFavorite) {
        [[self ancestor].favoriteFileList addNode:self];
    } else {
        [[self ancestor].favoriteFileList removeNode:self];
    }
    return;
}

- (void) setIsOffline:(BOOL)isOffline {
    _isOffline = isOffline;
    
    if (isOffline) {
        [[self ancestor].offlineFileList addNode:self];
    } else {
        [[self ancestor].offlineFileList removeNode:self];
    }
    
    return;
}

- (void)queryLastModifiedDate:(queryLastModifiedDateCompBlock)compBlock;
{
    compBlock(self.lastModifiedDate, nil);
}


- (void)setLastModifiedDate:(NSDate *)lastModifiedDate {
    if (![self.lastModifiedDate isEqualToDate:lastModifiedDate]) {
        _lastModifiedDate = lastModifiedDate;
        NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
        [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
        self.lastModifiedTime = [dateFormtter stringFromDate:self.lastModifiedDate];
    }
}

#pragma mark - NSCoding protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:NXFILESYSCODINGNAME];
    [aCoder encodeObject:_fullPath forKey:NXFILESYSCODINGFULLPATH];
    [aCoder encodeObject:_fullServicePath forKey:NXFILESYSCODINGFULLSERVICEPATH];
    [aCoder encodeObject:_localPath forKey:NXFILESYSCODINGLOCALPATH];
    [aCoder encodeObject:_lastModifiedTime forKey:NXFILESYSCODINGLASTMODIFIEDTIME];
    [aCoder encodeObject:_lastModifiedDate forKey:NXFILESYSCODINGLASTMODIFIEDDATE];
    [aCoder encodeObject:[NSNumber numberWithLongLong: _size ] forKey:NXFILESYSCODINGSIZE];
    [aCoder encodeObject:_refreshDate forKey:NXFILESYSCODINGREFRESHDATE];
    [aCoder encodeObject:_parent forKey:NXFILESYSCODINGPARENT];
    [aCoder encodeObject:[NSNumber numberWithBool:_isRoot] forKey:NXFILESYSCODINGISROOT];
    [aCoder encodeObject:_serviceAlias forKey:NXFILESYSCODINGSERVICEALIAS];
    [aCoder encodeObject:_serviceAccountId forKey:NXFILESYSCODINGSERVICEACCOUNTID];
    [aCoder encodeObject:[NSNumber numberWithBool:_isFavorite]forKey:NXFILESYSCODINGISFAVORITE];
    [aCoder encodeObject:[NSNumber numberWithBool:_isOffline] forKey:NXFILESYSCODINGISOFFLINE];
    [aCoder encodeObject:_offlineFileList forKey:NXFILESYSCODINGOFFLINEFILELIST];
    [aCoder encodeObject:_favoriteFileList forKey:NXFILESYSCODINGFAVORITEFILELIST];
    [aCoder encodeObject:_serviceType forKey:NXFILESYSCODINGSERVICETYPE];
    [aCoder encodeObject:_SPSiteId forKey:NXFILESYSCODINGSPSITE];
    [aCoder encodeObject:_repoId forKey:NXFILESYSCODINGREPOID];
    [aCoder encodeObject: [NSNumber numberWithInteger:_sorceType] forKey:NXFILESYSCODINGSOURCETYPE];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:NXFILESYSCODINGNAME];
        _fullPath = [aDecoder decodeObjectForKey:NXFILESYSCODINGFULLPATH];
        _fullServicePath = [aDecoder decodeObjectForKey:NXFILESYSCODINGFULLSERVICEPATH];
        _localPath = [aDecoder decodeObjectForKey:NXFILESYSCODINGLOCALPATH];
        _lastModifiedTime = [aDecoder decodeObjectForKey:NXFILESYSCODINGLASTMODIFIEDTIME];
        _lastModifiedDate = [aDecoder decodeObjectForKey:NXFILESYSCODINGLASTMODIFIEDDATE];
        _size = [[aDecoder decodeObjectForKey:NXFILESYSCODINGSIZE] longLongValue];
        _refreshDate = [aDecoder decodeObjectForKey:NXFILESYSCODINGREFRESHDATE];
        _parent = [aDecoder decodeObjectForKey:NXFILESYSCODINGPARENT];
        _isRoot = [[aDecoder decodeObjectForKey:NXFILESYSCODINGISROOT] boolValue];
        _serviceAlias = [aDecoder decodeObjectForKey:NXFILESYSCODINGSERVICEALIAS];
        _serviceAccountId = [aDecoder decodeObjectForKey:NXFILESYSCODINGSERVICEACCOUNTID];
        _isFavorite = [[aDecoder decodeObjectForKey:NXFILESYSCODINGISFAVORITE] boolValue];
        _favoriteFileList = [aDecoder decodeObjectForKey:NXFILESYSCODINGFAVORITEFILELIST];
        _isOffline = [[aDecoder decodeObjectForKey:NXFILESYSCODINGISOFFLINE] boolValue];
        _offlineFileList = [aDecoder decodeObjectForKey:NXFILESYSCODINGOFFLINEFILELIST];
        _serviceType = [aDecoder decodeObjectForKey:NXFILESYSCODINGSERVICETYPE];
        _SPSiteId = [aDecoder decodeObjectForKey:NXFILESYSCODINGSPSITE];
        _repoId = [aDecoder decodeObjectForKey:NXFILESYSCODINGREPOID];
        _sorceType = ((NSNumber *)[aDecoder decodeObjectForKey:NXFILESYSCODINGSOURCETYPE]).integerValue;
    }
    
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXFileBase *newItem = [[[self class] alloc] init];
    newItem.name = [_name copy];
    newItem.fullPath = [_fullPath copy];
    newItem.fullServicePath = [_fullServicePath copy];
    newItem.localPath = [_localPath copy];
    newItem.lastModifiedTime =  [_lastModifiedTime copy];
    newItem.lastModifiedDate = [_lastModifiedDate copy];
    newItem.size = _size;
    newItem.refreshDate = [_refreshDate copy];
    newItem.isRoot = _isRoot;
    newItem.serviceAlias = [_serviceAlias copy];
    newItem.serviceAccountId = [_serviceAccountId copy];
    newItem.isFavorite = _isFavorite;
    newItem.isOffline = _isOffline;
    newItem.SPSiteId = [_SPSiteId copy];
    newItem.repoId = [_repoId copy];
    newItem.sorceType = _sorceType;
    newItem.serviceType = [_serviceType copy];
    return newItem;
}

#pragma mark - user for as key
// for use nxrepomodel as continer key
- (NSUInteger)hash
{
    if (self.sorceType == NXFileBaseSorceTypeRepoFile) {
        return [self.fullServicePath hash] ^ [self.repoId hash];
    }else if(self.sorceType == NXFileBaseSorceTypeLocal){
        return [self.localPath hash];
    }else{
        return [self.fullServicePath hash];
    }
}
- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:[NXFileBase class]]) {
        return NO;
    }
    NXFileBase *otherFileItem = (NXFileBase *)other;
    NSString *fileKey = [NXCommonUtils fileKeyForFile:other];
    if (otherFileItem.sorceType == NXFileBaseSorceTypeRepoFile) {
        if ([otherFileItem.fullServicePath isEqualToString:self.fullServicePath]  && [otherFileItem.repoId isEqualToString:self.repoId] && [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
            return YES;
        }
        // specilal for mult-repository root folder
        if (otherFileItem.isRoot && self.isRoot) {
            if (self.repoId == nil && otherFileItem.repoId == nil) {
                return YES;
            }else {
                if([self.repoId isEqualToString:otherFileItem.repoId]){
                    return YES;
                }else{
                    return NO;
                }
            }
        }
        
    }else if((otherFileItem.sorceType == NXFileBaseSorceTypeLocal && self.sorceType == NXFileBaseSorceTypeLocal)||(otherFileItem.sorceType == NXFileBaseSorceTypeLocalFiles && self.sorceType == NXFileBaseSorceTypeLocalFiles)){
        if ([otherFileItem.localPath isEqualToString:self.localPath] && [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
            return YES;
        }else{
            return NO;
        }
    
    }else{
        if ([otherFileItem.fullServicePath isEqualToString:self.fullServicePath]  && [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
            return YES;
        }
    }
    return NO;
}


@end
