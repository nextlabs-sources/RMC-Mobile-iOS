//
//  NXSharedWithMeFile.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#define NXSHAREDWITHMEFILE_DUID                 @"NXSHAREDWITHMEFILE_DUID"
#define NXSHAREDWITHMEFILE_FILETYPE             @"NXSHAREDWITHMEFILE_FILETYPE"
#define NXSHAREDWITHMEFILE_SHAREBY              @"NXSHAREDWITHMEFILE_SHAREBY"
#define NXSHAREDWITHMEFILE_TRANSACTIONID        @"NXSHAREDWITHMEFILE_TRANSACTIONID"
#define NXSHAREDWITHMEFILE_TRANSACTIONCODE      @"NXSHAREDWITHMEFILE_TRANSACTIONCODE"
#define NXSHAREDWITHMEFILE_SHAREDLINK           @"NXSHAREDWITHMEFILE_SHAREDLINK"
#define NXSHAREDWITHMEFILE_COMMENT              @"NXSHAREDWITHMEFILE_COMMENT"
#define NXSHAREDWITHMEFILE_RIGHTS               @"NXSHAREDWITHMEFILE_RIGHTS"
#define NXSHAREDWITHMEFILE_LASTMODIFIED         @"NXSHAREDWITHMEFILE_LASTMODIFIED"
#define NXSHAREDWITHMEFILE_SHAREDDATE           @"NXSHAREDWITHMEFILE_SHAREDDATE"
#import "NXSharedWithMeFile.h"
#import "NXCommonUtils.h"
#import "NXSharedWithMeGetFileHeaderAPI.h"
@implementation NXSharedWithMeFile
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeShareWithMe;
        [self setValuesForKeysWithDictionary:dict];
        self.sharedDate = self.sharedDate/1000;
        self.fullServicePath = self.transactionCode;
        if (self.lastModified) {
            long long lastModified =  self.lastModified.longLongValue/1000;
            self.lastModifiedTime = [NSString stringWithFormat:@"%0lld", lastModified];
            self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:lastModified];
        }else {
            self.lastModifiedTime = [NSString stringWithFormat:@"%0f", self.sharedDate];
            self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:self.sharedDate];
        }
        
    }
    return self ;
}

-(instancetype)initFileFromResultSharedWithMeDownloadFileDic:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeShareWithMe;
        [self setValuesForKeysWithDictionary:dict];
        self.sharedDate = self.sharedDate/1000;
        self.fullServicePath = self.transactionCode;
        if (self.lastModified) {
            long long lastModified =  self.lastModified.longLongValue/1000;
            self.lastModifiedTime = [NSString stringWithFormat:@"%0lld", lastModified];
            self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:lastModified];
        }else {
            self.lastModifiedTime = [NSString stringWithFormat:@"%0f", self.sharedDate];
            self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:self.sharedDate];
        }
    }
    return self ;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
- (NSUInteger)hash
{
    return [self.duid hash] ^ [self.duid hash] ^ [self.transactionCode hash];
}
- (BOOL)isEqual:(id)object {
    NSString *fileKey = [NXCommonUtils fileKeyForFile:object];
    if ([object isMemberOfClass:[NXSharedWithMeFile class]]) {
        NXSharedWithMeFile *item = (NXSharedWithMeFile *)object;
        if ([item.duid isEqualToString:self.duid]||(item.transactionId == self.transactionId && item.transactionCode == self.transactionCode)) {
            if ( [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
                 return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;
}
#pragma mark - NSCoding
- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _duid = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_DUID];
        _fileType = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_FILETYPE];
        _sharedBy = [aDecoder  decodeObjectForKey:NXSHAREDWITHMEFILE_SHAREBY];
        _transactionId = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_TRANSACTIONID];
        _transactionCode = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_TRANSACTIONCODE];
        _sharedLink = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_SHAREDLINK];
        _comment = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_COMMENT];
        _rights = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_RIGHTS];
        _lastModified = [aDecoder decodeObjectForKey:NXSHAREDWITHMEFILE_LASTMODIFIED];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_duid forKey:NXSHAREDWITHMEFILE_SHAREDDATE];
    [aCoder encodeObject:_fileType forKey:NXSHAREDWITHMEFILE_FILETYPE];
    [aCoder encodeObject:_sharedBy forKey:NXSHAREDWITHMEFILE_SHAREBY];
    [aCoder encodeObject:_transactionId forKey:NXSHAREDWITHMEFILE_TRANSACTIONID];
    [aCoder encodeObject:_transactionCode forKey:NXSHAREDWITHMEFILE_TRANSACTIONCODE];
    [aCoder encodeObject:_sharedLink forKey:NXSHAREDWITHMEFILE_TRANSACTIONCODE];
    [aCoder encodeObject:_comment forKey:NXSHAREDWITHMEFILE_COMMENT];
    [aCoder encodeObject:_rights forKey:NXSHAREDWITHMEFILE_RIGHTS];
    if (_lastModified) {
        [aCoder encodeObject:_lastModified forKey:NXSHAREDWITHMEFILE_LASTMODIFIED];
    }
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone
{
    NXSharedWithMeFile *sharedWithMeFile = [[NXSharedWithMeFile alloc] init];
    sharedWithMeFile.name = [self.name copy];
    sharedWithMeFile.fullPath = [self.fullPath copy];
    sharedWithMeFile.fullServicePath = [self.fullServicePath copy];
    sharedWithMeFile.localPath = [self.localPath copy];
    sharedWithMeFile.lastModifiedTime =  [self.lastModifiedTime copy];
    sharedWithMeFile.lastModifiedDate = [self.lastModifiedDate copy];
    sharedWithMeFile.size = self.size;
    sharedWithMeFile.refreshDate = [self.refreshDate copy];
    sharedWithMeFile.isRoot = self.isRoot;
    sharedWithMeFile.serviceAlias = [self.serviceAlias copy];
    sharedWithMeFile.serviceAccountId = [self.serviceAccountId copy];
    sharedWithMeFile.isFavorite = self.isFavorite;
    sharedWithMeFile.isOffline = self.isOffline;
    sharedWithMeFile.SPSiteId = [self.SPSiteId copy];
    sharedWithMeFile.repoId = [self.repoId copy];
    sharedWithMeFile.sorceType = self.sorceType;
    sharedWithMeFile.duid = [self.duid copy];
    sharedWithMeFile.fileType = [self.fileType copy];
    sharedWithMeFile.sharedBy = [self.sharedBy copy];
    sharedWithMeFile.transactionId = [self.transactionId copy];
    sharedWithMeFile.transactionCode = [self.transactionCode copy];
    sharedWithMeFile.sharedLink = [self.sharedLink copy];
    sharedWithMeFile.comment = [self.comment copy];
    sharedWithMeFile.rights = [self.rights copy];
    sharedWithMeFile.isOwner = self.isOwner;
    sharedWithMeFile.lastModified = [self.lastModified copy];
    return sharedWithMeFile;
}


#pragma mark - NXFileGetNXLHeaderProtocol
- (NSString *)getNXLHeader:(NXFileGetNXLHeaderCompletedBlock)compBlock {
    NXSharedWithMeGetFileHeaderAPIRequest *req = [[NXSharedWithMeGetFileHeaderAPIRequest alloc] init];
    [req requestWithObject:self Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            NXSharedWithMeGetFileHeaderAPIResponse *getNXLHeaderResponse = (NXSharedWithMeGetFileHeaderAPIResponse *)response;
            if(response.rmsStatuCode == 200) {
                NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:self.name];
                [getNXLHeaderResponse.fileData writeToFile:tmpPath atomically:NO];
                NXProjectFile *projectFile = [self copy];
                projectFile.localPath = tmpPath;
                compBlock(projectFile, getNXLHeaderResponse.fileData, nil);
            }else {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                NXProjectFile *projectFile = [self copy];
                compBlock(projectFile, nil, restError);
            }
        }else {
            // try to get header by part download
            [[NXWebFileManager sharedInstance] downloadFile:[self copy] toSize:NXL_FILE_HEAD_LENGTH completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                compBlock(file, fileData, error);
            }];
        }
    }];
    return @"";
}

@end
