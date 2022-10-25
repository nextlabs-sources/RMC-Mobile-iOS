//
//  NXSharedWithProjectFile.m
//  nxrmc
//
//  Created by 时滕 on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFile.h"
#import "NSObject+NXLRuntimeExt.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
@implementation NXSharedWithProjectFile
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeSharedWithProject;
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
- (BOOL)isEqual:(id)object {
    NSString *fileKey = [NXCommonUtils fileKeyForFile:object];
    if ([object isKindOfClass:[NXSharedWithProjectFile class]]  && [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
        NXSharedWithProjectFile *otherObj = (NXSharedWithProjectFile *)object;
        if ([otherObj.duid isEqualToString:self.duid] && [otherObj.transactionId isEqualToString:self.transactionId]) {
            return YES;
        }
    }
    return NO;
}
- (void)queryLastModifiedDate:(queryLastModifiedDateCompBlock)compBlock;
{
    [[NXLoginUser sharedInstance].myProject getSharedWithProjectFileMetadata:self withCompletion:^(NXSharedWithProjectFile *file, NSError *error) {
        if (!error) {
            [[NXLoginUser sharedInstance].myProject updateSharedWithProjectFileInCoreData:file];
        }
        compBlock(file.lastModifiedDate,error);
    }];
}
- (NSUInteger)hash {
    return [self.duid hash] ^ [self.transactionId hash];
}

#pragma mark Copying
#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    NXSharedWithProjectFile *sharedWithProjectFile = [[NXSharedWithProjectFile alloc] init];
    sharedWithProjectFile.name = [self.name copy];
    sharedWithProjectFile.fullPath = [self.fullPath copy];
    sharedWithProjectFile.fullServicePath = [self.fullServicePath copy];
    sharedWithProjectFile.localPath = [self.localPath copy];
    sharedWithProjectFile.lastModifiedTime =  [self.lastModifiedTime copy];
    sharedWithProjectFile.lastModifiedDate = [self.lastModifiedDate copy];
    sharedWithProjectFile.size = self.size;
    sharedWithProjectFile.refreshDate = [self.refreshDate copy];
    sharedWithProjectFile.isRoot = self.isRoot;
    sharedWithProjectFile.isFavorite = self.isFavorite;
    sharedWithProjectFile.isOffline = self.isOffline;
    sharedWithProjectFile.sorceType = self.sorceType;
    sharedWithProjectFile.duid = [self.duid copy];
    sharedWithProjectFile.fileType = [self.fileType copy];
    sharedWithProjectFile.sharedBy = [self.sharedBy copy];
    sharedWithProjectFile.sharedProject = [self.sharedProject copy];
    sharedWithProjectFile.sharedByProject = [sharedWithProjectFile.sharedByProject copy];
    sharedWithProjectFile.transactionId = [self.transactionId copy];
    sharedWithProjectFile.transactionCode = [self.transactionCode copy];
    sharedWithProjectFile.sharedLink = [self.sharedLink copy];
    sharedWithProjectFile.sharedDate = self.sharedDate;
    sharedWithProjectFile.comment = [self.comment copy];
    sharedWithProjectFile.rights = [self.rights copy];
    sharedWithProjectFile.isOwner = self.isOwner;
    sharedWithProjectFile.spaceId = [self.spaceId copy];
    sharedWithProjectFile.shareWith = [self.shareWith copy];
    sharedWithProjectFile.reshareComment = [self.reshareComment copy];
    sharedWithProjectFile.lastModified = [self.lastModified copy];
    return sharedWithProjectFile;
}


#pragma mark OverWrite Coding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self nxlEncode:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self nxlDecode:aDecoder];
    }
    return self;
}

@end
