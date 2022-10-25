//
//  NXMyVaultFile.m
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultFile.h"
#import "NXCommonUtils.h"
#import "NXLFileValidateDateModel.h"
#import "NXLoginUser.h"
#import "NXMyVaultFileGetNXLHeaderAPI.h"
#define NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_NAME_PRO     @"NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_NAME_PRO"
#define NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_TYPE_PRO     @"NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_TYPE_PRO"
#define NXMYVAULT_CUSTOM_METADATA_SOURCE_FILE_DISPLAY_PRO  @"NXMYVAULT_CUSTOM_METADATA_SOURCE_FILE_DISPLAY_PRO"
#define NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_ID_PRO       @"NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_ID_PRO"

@implementation NXMyVaultFileCustomMetadata
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sourceRepoName = @"";
        _sourceRepoId = @"";
        _sourceFilePathDisplay = @"";
        _sourceRepoType = @"";
    }
    
    return self;
}
#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _sourceRepoName = [aDecoder decodeObjectForKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_NAME_PRO];
        _sourceRepoType = [aDecoder decodeObjectForKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_TYPE_PRO];
        _sourceFilePathDisplay = [aDecoder decodeObjectForKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_FILE_DISPLAY_PRO];
        _sourceRepoId = [aDecoder decodeObjectForKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_ID_PRO];
    }
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_sourceRepoName forKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_NAME_PRO];
    [aCoder encodeObject:_sourceRepoType forKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_TYPE_PRO];
    [aCoder encodeObject:_sourceFilePathDisplay forKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_FILE_DISPLAY_PRO];
    [aCoder encodeObject:_sourceRepoId forKey:NXMYVAULT_CUSTOM_METADATA_SOURCE_REPO_ID_PRO];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXMyVaultFileCustomMetadata*newItem = [[NXMyVaultFileCustomMetadata alloc] init];
    newItem.sourceRepoName = [_sourceRepoName copy];
    newItem.sourceRepoType = [_sourceRepoType copy];
    newItem.sourceRepoId = [_sourceRepoId copy];
    newItem.sourceFilePathDisplay =  [_sourceFilePathDisplay copy];
    return newItem;
}
@end




#define NXMYVAULT_SHARE_WITH_PRO        @"NXMYVAULT_SHARE_WITH_NODE"
#define NXMYVAULT_SHARE_ON_PRO          @"NXMYVAULT_SHARE_ON_PRO"
#define NXMYVAULT_DUID_PRO              @"NXMYVAULT_DUID_PRO"
#define NXMYVAULT_SHARED_PRO            @"NXMYVAULT_SHARED_PRO"
#define NXMYVAULT_REVOKED_PRO           @"NXMYVAULT_REVOKED_PRO"
#define NXMYVAULT_DELETED_PRO           @"NXMYVAULT_DELETED_PRO"
#define NXMYVAULT_CUSTOM_METADATA_PRO   @"NXMYVAULT_CUSTOM_METADATA_PRO"
#define NXMYVAULT_FILELINK              @"NXMYVAULT_FILELINK"
#define NXMYVAULT_PROTECTEDON           @"NXMYVAULT_PROTECTEDON"
#define NXMYVAULT_RECIPIENTS            @"NXMYVAULT_RECIPIENTS"
#define NXMYVAULT_RIGHTS                @"NXMYVAULT_RIGHTS"

@implementation NXMyVaultFile

- (instancetype)init {
    if (self = [super init]) {
        _validateFileModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
        self.sorceType = NXFileBaseSorceTypeMyVaultFile;
    }
    return self;
}
- (instancetype)initWithDictory:(NSDictionary *)dic {
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dic];
        _validateFileModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
        self.sorceType = NXFileBaseSorceTypeMyVaultFile;
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"sharedOn"]) {
        self.sharedOn = [NSNumber numberWithDouble:((NSNumber *)value).doubleValue/1000];
        self.lastModifiedTime = [NSString stringWithFormat:@"%0f", ((NSNumber *)value).doubleValue/1000];
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:self.lastModifiedTime.longLongValue];
    }
    
    if ([key isEqualToString:@"protectedOn"]) {
        self.protectedOn = [NSNumber numberWithDouble:((NSNumber *)value).doubleValue/1000];
    }
    if ([key isEqualToString:@"sharedWith"]) {
        if ([value isKindOfClass:[NSString class]]) {
            NSArray *sharedWithArray = [(NSString *)value componentsSeparatedByString:@","];
            self.sharedWith = sharedWithArray;
        }else if([value isKindOfClass:[NSArray class]] | [value isKindOfClass:[NSMutableArray class]]){
            self.sharedWith = value;
        }
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"customMetadata"]) {
        NSDictionary *metadataDic =(NSDictionary*)value;
        NXMyVaultFileCustomMetadata *customMata= [[NXMyVaultFileCustomMetadata alloc]init];
        [customMata setValuesForKeysWithDictionary:metadataDic];
        self.metaData=customMata;
    }
    if ([key isEqualToString:@"pathId"]) {
        self.fullServicePath=value;
    }
    if ([key isEqualToString:@"pathDisplay"]) {
        self.fullPath=value;
    }
//    if ([key isEqualToString:@"fileName"]) {
//        self.name=value;
//    }
    if ([key isEqualToString:@"lastModified"]) {
        self.lastModifiedTime = value;
    }
    if ([key isEqualToString:@"revoked"]) {
        self.isRevoked=[value boolValue];
    }
    if ([key isEqualToString:@"deleted"]) {
        self.isDeleted=[value boolValue];
    }
    if ([key isEqualToString:@"shared"]) {
        self.isShared=[value boolValue];
    }
}

#pragma mark - NSCoding
- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _sharedWith = [aDecoder decodeObjectForKey:NXMYVAULT_SHARE_WITH_PRO];
        _sharedOn = [aDecoder decodeObjectForKey:NXMYVAULT_SHARE_ON_PRO];
        _duid = [aDecoder decodeObjectForKey:NXMYVAULT_DUID_PRO];
        _isShared = ((NSNumber *)([aDecoder decodeObjectForKey:NXMYVAULT_SHARED_PRO])).boolValue;
        _isRevoked = ((NSNumber *)([aDecoder decodeObjectForKey:NXMYVAULT_REVOKED_PRO])).boolValue;
        _isDeleted = ((NSNumber *)([aDecoder decodeObjectForKey:NXMYVAULT_DELETED_PRO])).boolValue;
        _metaData = [aDecoder decodeObjectForKey:NXMYVAULT_CUSTOM_METADATA_PRO];
        _fileLink = [aDecoder decodeObjectForKey:NXMYVAULT_FILELINK];
        _protectedOn = [aDecoder decodeObjectForKey:NXMYVAULT_PROTECTEDON];
        _recipients = [aDecoder decodeObjectForKey:NXMYVAULT_RECIPIENTS];
        _rights = [aDecoder decodeObjectForKey:NXMYVAULT_RIGHTS];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeConditionalObject:_sharedWith forKey:NXMYVAULT_SHARE_WITH_PRO];
    [aCoder encodeConditionalObject:_sharedOn forKey:NXMYVAULT_SHARE_ON_PRO];
    [aCoder encodeConditionalObject:_duid forKey:NXMYVAULT_DUID_PRO];
    [aCoder encodeConditionalObject:[NSNumber numberWithBool:_isShared] forKey:NXMYVAULT_SHARED_PRO];
    [aCoder encodeConditionalObject:[NSNumber numberWithBool:_isRevoked] forKey:NXMYVAULT_REVOKED_PRO];
    [aCoder encodeConditionalObject:[NSNumber numberWithBool:_isDeleted] forKey:NXMYVAULT_DELETED_PRO];
    [aCoder encodeConditionalObject:_metaData forKey:NXMYVAULT_CUSTOM_METADATA_PRO];
    [aCoder encodeObject:_fileLink forKey:NXMYVAULT_FILELINK];
    [aCoder encodeObject:_protectedOn forKey:NXMYVAULT_PROTECTEDON];
    [aCoder encodeObject:_rights forKey:NXMYVAULT_RIGHTS];
    [aCoder encodeObject:_recipients forKey:NXMYVAULT_RECIPIENTS];
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone
{
    NXMyVaultFile *myVaultFile = [[NXMyVaultFile alloc] init];
    myVaultFile.name = [self.name copy];
    myVaultFile.fullPath = [self.fullPath copy];
    myVaultFile.fullServicePath = [self.fullServicePath copy];
    myVaultFile.localPath = [self.localPath copy];
    myVaultFile.lastModifiedTime =  [self.lastModifiedTime copy];
    myVaultFile.lastModifiedDate = [self.lastModifiedDate copy];
    myVaultFile.size = self.size;
    myVaultFile.refreshDate = [self.refreshDate copy];
    myVaultFile.isRoot = self.isRoot;
    myVaultFile.serviceAlias = [self.serviceAlias copy];
    myVaultFile.serviceAccountId = [self.serviceAccountId copy];
    myVaultFile.isFavorite = self.isFavorite;
    myVaultFile.isOffline = self.isOffline;
    myVaultFile.SPSiteId = [self.SPSiteId copy];
    myVaultFile.repoId = [self.repoId copy];
    myVaultFile.sorceType = self.sorceType;
    myVaultFile.sharedWith = [self.sharedWith copy];
    myVaultFile.sharedOn = [self.sharedOn copy];
    myVaultFile.duid = [self.duid copy];
    myVaultFile.isRevoked = self.isRevoked;
    myVaultFile.isShared = self.isShared;
    myVaultFile.isDeleted = self.isDeleted;
    myVaultFile.metaData = [self.metaData copy];
    myVaultFile.fileLink = [self.fileLink copy];
    myVaultFile.protectedOn = [self.protectedOn copy];
    myVaultFile.rights = [self.rights copy];
    myVaultFile.recipients = [self.recipients copy];
    myVaultFile.validateFileModel = [self.validateFileModel copy];
    return myVaultFile;
}

#pragma mark - NXWebFileDownloadItemProtocol
- (void)queryLastModifiedDate:(queryLastModifiedDateCompBlock)compBlock {
    [[NXLoginUser sharedInstance].myVault metaData:self withCompletetino:^(NXMyVaultFile *file, NSError *error) {
        compBlock(file.lastModifiedDate, error);
    }];
}

- (BOOL)isEqual:(id)object {
    NSString *fileKey = [NXCommonUtils fileKeyForFile:object];
    if ([object isKindOfClass:[NXMyVaultFile class]]) {
        if ([[NXCommonUtils fileKeyForFile:self] isEqualToString:[NXCommonUtils fileKeyForFile:object]] && [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
            return YES;
        }else {
            return NO;
        }
    }
    return NO;
}

- (NSUInteger)hash {
    return [[NXCommonUtils fileKeyForFile:self] hash];
}

#pragma mark - NXFileGetNXLHeaderProtocol
- (NSString *)getNXLHeader:(NXFileGetNXLHeaderCompletedBlock)compBlock {
    NXMyVaultFileGetNXLHeaderRequest *req = [[NXMyVaultFileGetNXLHeaderRequest alloc] init];
    [req requestWithObject:self Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            NXMyVaultFileGetNXLHeaderResponse *getNXLHeaderResponse = (NXMyVaultFileGetNXLHeaderResponse *)response;
            if(response.rmsStatuCode == 200) {
                NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:self.name];
                [getNXLHeaderResponse.fileData writeToFile:tmpPath atomically:NO];
                NXMyVaultFile *copyFile = [self copy];
                copyFile.localPath = tmpPath;
                compBlock(copyFile, getNXLHeaderResponse.fileData, nil);
            }else {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                NXMyVaultFile *copyFile = [self copy];
                compBlock(copyFile, nil, restError);
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
