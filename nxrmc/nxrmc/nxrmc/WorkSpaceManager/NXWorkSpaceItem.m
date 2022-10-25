//
//  NXWorkSpaceFile.m
//  nxrmc
//
//  Created by Eren on 2019/8/29.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceItem.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXWorkSpaceFileGetNXLHeaderAPI.h"

@implementation NXWorkSpaceFileItemUploader

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXWorkSpaceFileItemUploader *newItem = [[[self class] allocWithZone:zone] init];
    newItem.email = [_email copy];
    newItem.userId = self.userId;
    newItem.displayName = [_displayName copy];
    return newItem;
}

@end

@implementation NXWorkSpaceFileItemLastModifiedUser

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXWorkSpaceFileItemLastModifiedUser *newItem = [[[self class] allocWithZone:zone] init];
    newItem.email = [_email copy];
    newItem.userId = self.userId;
    newItem.displayName = [_displayName copy];
    return newItem;
}
@end

@implementation NXWorkSpaceFile

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeWorkSpace;
        self.rights = [[NXLRights alloc] init];
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.sorceType = NXFileBaseSorceTypeWorkSpace;
        self.rights = [[NXLRights alloc] init];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"pathDisplay"]) {
        self.fullPath = (NSString *)value;
    }else if([key isEqualToString:@"pathId"]) {
        self.fullServicePath = (NSString *)value;
    }else if([key isEqualToString:@"lastModified"]) {
        NSNumber *timeValue = (NSNumber *)value;
        NSTimeInterval timeInterval = timeValue.longLongValue / 1000;
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }else if([key isEqualToString:@"creationTime"]) {
        NSNumber *timeValue = (NSNumber *)value;
        NSTimeInterval timeInterval = timeValue.longLongValue / 1000;
        self.creationDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }else if([key isEqualToString:@"uploadedBy"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileUploader = [[NXWorkSpaceFileItemUploader alloc] initWithDictionary:dict];
    }else if([key isEqualToString:@"lastModifiedUser"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileModifiedUser = [[NXWorkSpaceFileItemLastModifiedUser alloc] initWithDictionary:dict];
    }else if([key isEqualToString:@"rights"]) {
        NSArray *rightsArray = (NSArray *)value;
        [self.rights setStringRights:rightsArray];
    }
}

- (void)queryLastModifiedDate:(queryLastModifiedDateCompBlock)compBlock;
{
    [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileMetadataWithFile:self withCompletion:^(NXWorkSpaceFile *workSpaceFile, NSError *error) {
        compBlock(workSpaceFile.lastModifiedDate, error);
    }];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NXWorkSpaceFile class]]) {
        return NO;
    }
    
    NXWorkSpaceFile *otherObj = (NXWorkSpaceFile *)object;
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
    NXWorkSpaceFile *newItem = [super copyWithZone:zone];
    newItem.duid = [_duid copy];
    newItem.rights = [_rights copy];
    newItem.tags = [_tags copy];
    newItem.fileUploader = [_fileUploader copy];
    newItem.fileModifiedUser = [_fileModifiedUser copy];
    return newItem;
}

#pragma mark - NXFileGetNXLHeaderProtocol
- (NSString *)getNXLHeader:(NXFileGetNXLHeaderCompletedBlock)compBlock {
    NXWorkSpaceFileGetNXLHeaderRequest *req = [[NXWorkSpaceFileGetNXLHeaderRequest alloc] init];
    [req requestWithObject:self Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            NXWorkSpaceFileGetNXLHeaderResponse *getNXLHeaderResponse = (NXWorkSpaceFileGetNXLHeaderResponse *)response;
            if(response.rmsStatuCode == 200) {
                NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:self.name];
                [getNXLHeaderResponse.fileData writeToFile:tmpPath atomically:NO];
                NXWorkSpaceFile *copyFile = [self copy];
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

@implementation NXWorkSpaceFolder

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeWorkSpace;
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.sorceType = NXFileBaseSorceTypeWorkSpace;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"pathDisplay"]) {
        self.fullPath = (NSString *)value;
    }else if([key isEqualToString:@"pathId"]) {
        self.fullServicePath = (NSString *)value;
    }else if([key isEqualToString:@"lastModified"]) {
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
    }else if([key isEqualToString:@"uploader"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileUploader = [[NXWorkSpaceFileItemUploader alloc] initWithDictionary:dict];
    }else if([key isEqualToString:@"lastModifiedUser"]) {
        NSDictionary *dict = (NSDictionary *)value;
        self.fileModifiedUser = [[NXWorkSpaceFileItemLastModifiedUser alloc] initWithDictionary:dict];
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NXWorkSpaceFolder class]]) {
        return NO;
    }
    
    NXWorkSpaceFolder *otherObj = (NXWorkSpaceFolder *)object;
    if ([otherObj.fullServicePath isEqualToString:self.fullServicePath]) {
        return YES;
    }else {
        return NO;
    }
}

@end


