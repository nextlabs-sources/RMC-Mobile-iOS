//
//  NXProjectFile.m
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectFile.h"
#import "NXProjectFileOwnerModel.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXProjectFileGetNXLHeaderAPI.h"

#define NXMYPROJECT_PROJECT_ID    @"NXMYPROJECT_PROJECT_ID"
#define NXMYPROJECT_ID            @"NXMYPROJECT_ID"
#define NXMYPROJECT_DUID          @"NXMYPROJECT_DUID"
#define NXMYPROJECT_CREATIONTIME  @"NXMYPROJECT_CREATIONTIME"
#define NXMYPROJECT_RIGHTS        @"NXMYPROJECT_RIGHTS"
#define NXMYPROJECT_PROJECTFILEOWNER @"NXMYPROJECT_PROJECTFILEOWNER"
@interface NXProjectFile()
@property(nonatomic, strong) NSString *fromType;
@end

@implementation NXProjectFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sorceType = NXFileBaseSorceTypeProject;
    }
    return self;
}
-(instancetype)initFileFromResultProjectFileListDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _fromType = @"projectFileList";
        self.sorceType = NXFileBaseSorceTypeProject;
        [self setValuesForKeysWithDictionary:dic];
        NSString *parentPath = [self.fullServicePath stringByDeletingLastPathComponent];
        if (![parentPath isEqualToString:@"/"]) {
           parentPath = [parentPath stringByAppendingString:@"/"];
        }
        self.parentPath = parentPath;
    }
    return self;
}
-(instancetype)initFileFromResultProjectUploadFileDic:(NSDictionary *)dic {
    self=[super init];
    if (self) {
        _fromType = @"projectUploadFile";
        self.sorceType = NXFileBaseSorceTypeProject;
        [self setValuesForKeysWithDictionary:dic];
        NSString *parentPath = [self.fullServicePath stringByDeletingLastPathComponent];
        if (![parentPath isEqualToString:@"/"]) {
           parentPath = [parentPath stringByAppendingString:@"/"];
        }
        self.parentPath = parentPath;
    }
    return self;
}
-(instancetype)initFileFromResultProjectFileMetadataDic:(NSDictionary *)dic {
    self=[super init];
    if (self) {
        _fromType = @"projectFileMetadata";
        self.sorceType = NXFileBaseSorceTypeProject;
        [self setValuesForKeysWithDictionary:dic];
        NSString *parentPath = [self.fullServicePath stringByDeletingLastPathComponent];
        if (![parentPath isEqualToString:@"/"]) {
           parentPath = [parentPath stringByAppendingString:@"/"];
        }
        self.parentPath = parentPath;
    }
    return self;
}

- (NSMutableArray<NSNumber *> *)sharedWithProjectList {
    @synchronized (self) {
        if (_sharedWithProjectList == nil) {
            _sharedWithProjectList = [NSMutableArray array];
        }
        return _sharedWithProjectList;
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"lastModified"]) {
        self.lastModifiedTime = [NSString stringWithFormat:@"%f", ((NSNumber *)value).doubleValue/1000];
        self.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:self.lastModifiedTime.longLongValue];
    }else if ([key isEqualToString:@"creationTime"]) {
        self.creationTime = [NSString stringWithFormat:@"%f", ((NSNumber *)value).doubleValue/1000];
    }else{
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    // projectFileListModel
    if ([key isEqualToString:@"pathId"]) {
        self.fullServicePath = value;
    }
    if ([key isEqualToString:@"pathDisplay"]) {
        self.fullPath = value;
    }
    if ([_fromType isEqual:@"projectFileList"]) {
        if ([key isEqualToString:@"id"]) {
            self.Id = value;
        }

        if ([key isEqualToString:@"owner"]) {
            NSDictionary*ownerDic = (NSDictionary*)value;
            NXProjectFileOwnerModel *owner = [[NXProjectFileOwnerModel alloc]init];
            [owner setValuesForKeysWithDictionary:ownerDic];
            self.projectFileOwner = owner;
        }

    }
    
    if ([key isEqualToString:@"shareWithProject"]) {
        NSArray *sharedProjectList = (NSArray *)value;
        for (NSNumber *projectId in sharedProjectList) {
            [self.sharedWithProjectList addObject:projectId];
        }
    }
    
    // projectUploadFile
    if ([_fromType isEqualToString:@"projectUploadFile"]) {
        if ([key isEqualToString:@"lastModified"]) {
            self.lastModifiedTime=value;
        }
    }
}

#pragma mark - NSCoding
- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _projectId = [aDecoder decodeObjectForKey:NXMYPROJECT_PROJECT_ID];
        _Id = [aDecoder decodeObjectForKey:NXMYPROJECT_ID];
        _duid = [aDecoder decodeObjectForKey:NXMYPROJECT_DUID];
        _creationTime = [aDecoder decodeObjectForKey:NXMYPROJECT_CREATIONTIME];
        _rights = [aDecoder decodeObjectForKey:NXMYPROJECT_RIGHTS];
        _projectFileOwner = [aDecoder decodeObjectForKey:NXMYPROJECT_PROJECTFILEOWNER];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_projectId forKey:NXMYPROJECT_PROJECT_ID];
    [aCoder encodeObject:_Id forKey:NXMYPROJECT_ID];
    [aCoder encodeObject:_duid forKey:NXMYPROJECT_DUID];
    [aCoder encodeObject:_creationTime forKey:NXMYPROJECT_CREATIONTIME];
    [aCoder encodeObject:_rights forKey:NXMYPROJECT_RIGHTS];
    [aCoder encodeConditionalObject:_projectFileOwner forKey:NXMYPROJECT_PROJECTFILEOWNER];
   
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone
{
    NXProjectFile *proejctFile = [[NXProjectFile alloc]init];
    proejctFile.name = [self.name copy];
    proejctFile.fullPath = [self.fullPath copy];
    proejctFile.fullServicePath = [self.fullServicePath copy];
    proejctFile.localPath = [self.localPath copy];
    proejctFile.lastModifiedTime =  [self.lastModifiedTime copy];
    proejctFile.lastModifiedDate = [self.lastModifiedDate copy];
    proejctFile.size = self.size;
    proejctFile.refreshDate = [self.refreshDate copy];
    proejctFile.isRoot = self.isRoot;
    proejctFile.serviceAlias = [self.serviceAlias copy];
    proejctFile.serviceAccountId = [self.serviceAccountId copy];
    proejctFile.isFavorite = self.isFavorite;
    proejctFile.isOffline = self.isOffline;
    proejctFile.SPSiteId = [self.SPSiteId copy];
    proejctFile.repoId = [self.repoId copy];
    proejctFile.sorceType = self.sorceType;
    proejctFile.projectId = [self.projectId copy];
    proejctFile.parentPath = [self.parentPath copy];
    proejctFile.Id = [self.Id copy];
    proejctFile.duid = [self.duid copy];
    proejctFile.creationTime = [self.creationTime copy];
    proejctFile.rights = [self.rights copy];
    proejctFile.projectFileOwner = [self.projectFileOwner copy];
    proejctFile.fileType = [self.fileType copy];
    proejctFile.isShared = self.isShared;
    proejctFile.revoked = self.revoked;
    return proejctFile;
}

- (void)queryLastModifiedDate:(queryLastModifiedDateCompBlock)compBlock
{
    [[NXLoginUser sharedInstance].myProject getFileMetaData:self withCompletion:^(NXProjectFile *file, NSError *error) {
        if (!error) {
            [[NXLoginUser sharedInstance].myProject updateProjectFileInCoreData:file];
        }
        compBlock(file.lastModifiedDate,error);
    }];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NXProjectFile class]]) {
        return NO;
    }
    
    NXProjectFile *otherObj = (NXProjectFile *)object;
    NSString *fileKey = [NXCommonUtils fileKeyForFile:otherObj];
    if ([otherObj.duid isEqualToString:self.duid] && [otherObj.fullServicePath isEqualToString:self.fullServicePath] && [fileKey isEqualToString:[NXCommonUtils fileKeyForFile:self]]) {
        return YES;
    }else {
        return NO;
    }
}

- (NSUInteger)hash {
    return [self.duid hash] ^ [self.fullServicePath hash];
}

#pragma mark - NXFileGetNXLHeaderProtocol
- (NSString *)getNXLHeader:(NXFileGetNXLHeaderCompletedBlock)compBlock {
    NXProjectFileGetNXLHeaderRequest *req = [[NXProjectFileGetNXLHeaderRequest alloc] init];
    [req requestWithObject:self Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error == nil) {
            NXProjectFileGetNXLHeaderResponse *getNXLHeaderResponse = (NXProjectFileGetNXLHeaderResponse *)response;
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
