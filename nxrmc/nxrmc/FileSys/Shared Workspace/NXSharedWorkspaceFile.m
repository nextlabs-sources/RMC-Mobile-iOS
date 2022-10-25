//
//  NXSharedWorkspaceFile.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/2/24.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXSharedWorkspaceFile.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXSharedWorkspaceGetNXLFileHeaderAPI.h"
@implementation NXSharedWorkspaceFileItemUploader

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXSharedWorkspaceFileItemUploader *newItem = [[[self class] allocWithZone:zone] init];
    newItem.email = [_email copy];
    newItem.userId = self.userId;
    newItem.displayName = [_displayName copy];
    return newItem;
}

@end

@implementation NXSharedWorkspaceFileItemLastModifiedUser

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXSharedWorkspaceFileItemLastModifiedUser *newItem = [[[self class] allocWithZone:zone] init];
    newItem.email = [_email copy];
    newItem.userId = self.userId;
    newItem.displayName = [_displayName copy];
    return newItem;
}
@end
@implementation NXSharedWorkspaceFile
- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeSharedWorkspaceFile;
        self.rights = [[NXLRights alloc] init];
        [self setValuesForKeysWithDictionary:dic];
        NSTimeInterval timeInterval =  [self.lastModifiedTime longLongValue] / 1000;
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.sorceType = NXFileBaseSorceTypeSharedWorkspaceFile;
        self.rights = [[NXLRights alloc] init];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"path"]) {
        self.fullPath = (NSString *)value;
    }else if([key isEqualToString:@"pathId"]) {
        self.fullServicePath = (NSString *)value;
    }else if([key isEqualToString:@"lastModifiedTime"]) {
        NSNumber *timeValue = (NSNumber *)value;
        NSTimeInterval timeInterval = timeValue.longLongValue / 1000;
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }else if([key isEqualToString:@"creationTime"]) {
        NSNumber *timeValue = (NSNumber *)value;
        NSTimeInterval timeInterval = timeValue.longLongValue / 1000;
        self.creationDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }else if([key isEqualToString:@"uploadedBy"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileUploader = [[NXSharedWorkspaceFileItemUploader alloc] initWithDictionary:dict];
    }else if([key isEqualToString:@"lastModifiedUser"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileModifiedUser = [[NXSharedWorkspaceFileItemLastModifiedUser alloc] initWithDictionary:dict];
    }else if([key isEqualToString:@"rights"]) {
        NSArray *rightsArray = (NSArray *)value;
        [self.rights setStringRights:rightsArray];
    }else if([key isEqualToString:@"fileSize"]){
        self.size = ((NSNumber *)value).longLongValue;
    }
}
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NXSharedWorkspaceFile class]]) {
        return NO;
    }
    
    NXSharedWorkspaceFile *otherObj = (NXSharedWorkspaceFile *)object;
    NSString *fileKey = [NXCommonUtils fileKeyForFile:object];
    if ([otherObj.fullServicePath isEqualToString:self.fullServicePath]  && [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXSharedWorkspaceFile *newItem = [super copyWithZone:zone];
    newItem.fileId = [_fileId copy];
    newItem.rights = [_rights copy];
    newItem.tags = [_tags copy];
    newItem.fileType = [_fileType copy];
    newItem.isFolder = _isFolder;
    newItem.protectedFile = _protectedFile;
    newItem.fileUploader = [_fileUploader copy];
    newItem.fileModifiedUser = [_fileModifiedUser copy];
    newItem.protectionType = _protectionType;
    newItem.encryptable = _encryptable;
    return newItem;
}
- (NSString *)getNXLHeader:(NXFileGetNXLHeaderCompletedBlock)compBlock {
    NXSharedWorkspaceGetNXLFileHeaderAPIRequest *req = [[NXSharedWorkspaceGetNXLFileHeaderAPIRequest alloc] init];
    [req requestWithObject:self Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            NXSharedWorkspaceGetNXLFileHeaderAPIResponse *getNXLHeaderResponse = (NXSharedWorkspaceGetNXLFileHeaderAPIResponse *)response;
            if(response.rmsStatuCode == 200) {
                NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:self.name];
                [getNXLHeaderResponse.fileData writeToFile:tmpPath atomically:NO];
                NXSharedWorkspaceFile *copyFile = [self copy];
                copyFile.localPath = tmpPath;
                compBlock(copyFile, getNXLHeaderResponse.fileData, nil);
            }else {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                NXWorkSpaceFile *copyFile = [self copy];
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
@implementation NXSharedWorkspaceFolder

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeSharedWorkspaceFile;
        [self setValuesForKeysWithDictionary:dic];
        NSTimeInterval timeInterval =  [self.lastModifiedTime longLongValue] / 1000;
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.sorceType = NXFileBaseSorceTypeSharedWorkspaceFile;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"path"]) {
        self.fullPath = (NSString *)value;
    }else if([key isEqualToString:@"pathId"]) {
        self.fullServicePath = (NSString *)value;
    }else if([key isEqualToString:@"lastModifiedTime"]) {
        NSNumber *timeValue = (NSNumber *)value;
        NSTimeInterval timeInterval = timeValue.longLongValue / 1000;
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
        [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
        self.lastModifiedTime = [dateFormtter stringFromDate:self.lastModifiedDate];
    }else if([key isEqualToString:@"creationTime"]) {
        NSNumber *timeValue = (NSNumber *)value;
        NSTimeInterval timeInterval = timeValue.longLongValue / 1000;
        self.creationDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }else if([key isEqualToString:@"uploadedBy"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileUploader = [[NXSharedWorkspaceFileItemUploader alloc] initWithDictionary:dict];
    }else if([key isEqualToString:@"lastModifiedUser"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileModifiedUser = [[NXSharedWorkspaceFileItemLastModifiedUser alloc] initWithDictionary:dict];
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NXSharedWorkspaceFolder class]]) {
        return NO;
    }
    
    NXSharedWorkspaceFolder *otherObj = (NXSharedWorkspaceFolder *)object;
    if ([otherObj.fullServicePath isEqualToString:self.fullServicePath]) {
        return YES;
    }else {
        return NO;
    }
}
@end
