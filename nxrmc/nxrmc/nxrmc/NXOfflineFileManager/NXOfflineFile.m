//
//  NXOfflineFile.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOfflineFile.h"

#define NXOFFLINE_SOURCE_PATH            @"sourcePath"
#define NXOFFLINE_STATE                  @"state"
#define NXOFFLINE_DUID                   @"duid"
#define NXOFFLINE_FILEKEY                @"fileKey"
#define NXOFFLINE_MARKASOFFLINE_DATE     @"markAsOfflineDate"
#define NXOFFLINE_IS_CENTER_POLICY       @"isCenterPolicyEncrypted"

@implementation NXOfflineFile

- (instancetype)init {
    if (self = [super init]) {
        _state = NXFileStateOfflined;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

#pragma mark - NSCoding
- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _sourcePath = [aDecoder decodeObjectForKey:NXOFFLINE_SOURCE_PATH];
        _fileKey = [aDecoder decodeObjectForKey:NXOFFLINE_FILEKEY];
        _duid = [aDecoder decodeObjectForKey:NXOFFLINE_DUID];
        _markAsOfflineDate = [aDecoder decodeObjectForKey:NXOFFLINE_MARKASOFFLINE_DATE];
        _isCenterPolicyEncrypted = [aDecoder decodeBoolForKey:NXOFFLINE_IS_CENTER_POLICY];
        _state = [aDecoder decodeIntegerForKey:NXOFFLINE_STATE];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeConditionalObject:_sourcePath forKey:NXOFFLINE_SOURCE_PATH];
    [aCoder encodeConditionalObject:_fileKey forKey:NXOFFLINE_FILEKEY];
    [aCoder encodeConditionalObject:_duid forKey:NXOFFLINE_DUID];
    [aCoder encodeConditionalObject:_markAsOfflineDate forKey:NXOFFLINE_MARKASOFFLINE_DATE];
    [aCoder encodeBool:_isCenterPolicyEncrypted forKey:NXOFFLINE_IS_CENTER_POLICY];
    [aCoder encodeInteger:_state forKey:NXOFFLINE_STATE];
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone
{
    NXOfflineFile *offlineFile = [super copyWithZone:zone];
    offlineFile.sourcePath = [self.sourcePath copy];
    offlineFile.state = self.state;
    offlineFile.duid = [self.duid copy];
    offlineFile.fileKey = [self.fileKey copy];
    offlineFile.isCenterPolicyEncrypted = self.isCenterPolicyEncrypted;
    offlineFile.markAsOfflineDate = [self.markAsOfflineDate copy];
    return offlineFile;
}

@end
