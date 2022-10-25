//
//  NXOfflineFileRightsManager.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/9.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOfflineFileRightsManager.h"
#import "NXFile.h"
#import "NXWebFileManager.h"
#import "NXQueryFileRightsOperation.h"
#import "NXNetworkHelper.h"
#import "NXRMCDef.h"
#import "NSString+Codec.h"
#import "NXLoginUser.h"
#import "NSData+Encryption.h"
#import "NXCommonUtils.h"
#import "NXOfflineFile.h"
#import "NXLProfile.h"
#import "NXLRights.h"
@interface NXOfflineFileRightsCacheNode : NSObject<NSCoding>
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NXLRights *rights;
@property(nonatomic, strong) NSArray<NXClassificationCategory *> *classifications;
@property(nonatomic, strong) NSArray<NXWatermarkWord *> *waterMarkWords;
@property(nonatomic, strong) NSString *owner;
@property(nonatomic, assign) BOOL isOwner;
@property(nonatomic, strong) NSString *fileKey; // record fileKey, in case the cached rights file replace by other file's rights file.
@end

@implementation NXOfflineFileRightsCacheNode

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_duid forKey:@"duid"];
    [aCoder encodeObject:_rights forKey:@"rights"];
    [aCoder encodeObject:_classifications forKey:@"classifications"];
    [aCoder encodeObject:_waterMarkWords forKey:@"waterMarkWords"];
    [aCoder encodeObject:_owner forKey:@"owner"];
    [aCoder encodeObject:_fileKey forKey:@"fileKey"];
    [aCoder encodeObject:[NSNumber numberWithBool:_isOwner] forKey:@"isOwner"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _duid = [aDecoder decodeObjectForKey:@"duid"];
        _rights = [aDecoder decodeObjectForKey:@"rights"];
        _classifications = [aDecoder decodeObjectForKey:@"classifications"];
        _waterMarkWords = [aDecoder decodeObjectForKey:@"waterMarkWords"];
        _owner = [aDecoder decodeObjectForKey:@"owner"];
        _fileKey = [aDecoder decodeObjectForKey:@"fileKey"];
        _isOwner = ((NSNumber *)[aDecoder decodeObjectForKey:@"isOwner"]).boolValue;
    }
    return self;
}

@end

@interface NXOfflineFileRightsManager()
@property(nonatomic, strong) NSMutableDictionary *optDict;
@end


@implementation NXOfflineFileRightsManager
#pragma mark - Public method
- (NSString *)queryRightsForFile:(NXFileBase *)file completed:(queryNXLFileRightsCompletedBlock) completed {
    if ([file isKindOfClass:[NXOfflineFile class]]) {
        file = [self offlineFileSourceFile:(NXOfflineFile *)file];
    }
    NSString *optId = [[NSUUID UUID] UUIDString];
    if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] ) {
        NXQueryFileRightsOperation *opt = [[NXQueryFileRightsOperation alloc] initWithFile:file];
        [self.optDict setObject:opt forKey:optId];
        WeakObj(self);
        opt.completed = ^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
            StrongObj(self);
            if (self) {
                if(error == nil) {
                    // Do/Update cache
                    NXOfflineFileRightsCacheNode *cacheNode = [[NXOfflineFileRightsCacheNode alloc] init];
                    cacheNode.duid = duid;
                    cacheNode.rights = rights;
                    cacheNode.classifications = classifications;
                    cacheNode.waterMarkWords = waterMarkWords;
                    cacheNode.owner = owner;
                    cacheNode.isOwner = isOwner;
                    cacheNode.fileKey = [NXCommonUtils fileKeyForFile:file];
                    [self cacheFileRights:cacheNode forFile:file];
                }
                NSOperation *opt =  [self.optDict objectForKey:optId];
                if (opt) {
                    [self.optDict removeObjectForKey:optId];
                    opt = nil;
                    completed(duid, rights, classifications, waterMarkWords, owner, isOwner, error);
                }
            }
        };
        [opt start];
    }else { // no net work, get from cache
        NXOfflineFileRightsCacheNode *cacheNode = [self cachedRightsForFile:file];
        if (cacheNode == nil) {
            NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GET_RIGHT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_FAILED_GET_NXL_FILE_RIGHT", nil)}];
            completed(nil, nil, nil, nil, nil, NO, error);
        }else if (![cacheNode.fileKey isEqualToString:[NXCommonUtils fileKeyForFile:file]]) {
            NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GET_RIGHT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_FAILED_GET_NXL_FILE_RIGHT", nil)}];
            completed(nil, nil, nil, nil, nil, NO, error);
        }else {
            completed(cacheNode.duid, cacheNode.rights, cacheNode.classifications, cacheNode.waterMarkWords, cacheNode.owner, cacheNode.isOwner, nil);
        }
    }
    return optId;
}

- (NSString *)refreshRightsForFile:(NXFileBase *)file completed:(queryNXLFileRightsCompletedBlock) completed {
    if ([file isKindOfClass:[NXOfflineFile class]]) {
        file = [self offlineFileSourceFile:(NXOfflineFile *)file];
    }
    NSString *optId = [[NSUUID UUID] UUIDString];
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) { // NO network , just return error
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GET_RIGHT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_FAILED_GET_NXL_FILE_RIGHT", nil)}];
        completed(nil, nil, nil, nil, nil, NO, error);
    }else {
        NXQueryFileRightsOperation *opt = [[NXQueryFileRightsOperation alloc] initWithFile:file];
        [self.optDict setObject:opt forKey:optId];
        WeakObj(self);
        opt.completed = ^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
            StrongObj(self);
            if (self) {
                if(error == nil) {
                    // Do/Update cache
                    NXOfflineFileRightsCacheNode *cacheNode = [[NXOfflineFileRightsCacheNode alloc] init];
                    cacheNode.duid = duid;
                    cacheNode.rights = rights;
                    cacheNode.classifications = classifications;
                    cacheNode.waterMarkWords = waterMarkWords;
                    cacheNode.owner = owner;
                    cacheNode.isOwner = isOwner;
                    [self cacheFileRights:cacheNode forFile:file];
                }
                NSOperation *opt =  [self.optDict objectForKey:optId];
                if (opt) {
                    [self.optDict removeObjectForKey:optId];
                    opt = nil;
                    completed(duid, rights, classifications, waterMarkWords, owner, isOwner, error);
                }
            }
        };
        [opt start];
    }
    return optId;
}

- (void)clearCachedRightsForFile:(NXFileBase *)file {
    if ([file isKindOfClass:[NXOfflineFile class]]) {
        file = [self offlineFileSourceFile:(NXOfflineFile *)file];
    }
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    fileKey = [fileKey MD5];
    NSURL *cacheURL = [self getRightCacheURL];
    cacheURL = [cacheURL URLByAppendingPathComponent:fileKey isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
}

- (void)clearAllCachedRights {
    [[NSFileManager defaultManager] removeItemAtURL:[self getRightCacheURL] error:nil];
}

- (void)cancelOperation:(NSString *)optID {
    if (optID) {
        NSOperation *opt = [self.optDict objectForKey:optID];
        [opt cancel];
        [self.optDict removeObjectForKey:optID];
    }
}

#pragma mark - Private method
- (void)cacheFileRights:(NXOfflineFileRightsCacheNode *)cacheNode forFile:(NXFileBase *)file{
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    NSData *content = [NSKeyedArchiver archivedDataWithRootObject:cacheNode];
    fileKey = [fileKey MD5];
    content = [content AES256ParmEncryptWithKey:fileKey];
    NSURL *cacheURL = [self getRightCacheURL];
    cacheURL = [cacheURL URLByAppendingPathComponent:fileKey isDirectory:NO];
    [[NSFileManager defaultManager] createFileAtPath:cacheURL.path contents:content attributes:nil];
}


- (NXOfflineFileRightsCacheNode *)cachedRightsForFile:(NXFileBase *)file {
    NSString *fileKey = [[NXCommonUtils fileKeyForFile:file] MD5];
    NSURL *cacheURL = [self getRightCacheURL];
    cacheURL = [cacheURL URLByAppendingPathComponent:fileKey isDirectory:NO];
    if([[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path]) {
        NSData * content = [NSData dataWithContentsOfURL:cacheURL];
        content = [content AES256ParmDecryptWithKey:fileKey];
        if (content) {
            NXOfflineFileRightsCacheNode *cacheNode = [NSKeyedUnarchiver unarchiveObjectWithData:content];
            return cacheNode;
        }else {
            return nil;
        }
    }else {
        return nil;
    }
    
}

-(NSURL *) getRightCacheURL
{
    NXLProfile *clientProfile = [NXLoginUser sharedInstance].profile;
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // cache format
    // document/rms service/user id/rbk/
    cacheUrl = [[[cacheUrl URLByAppendingPathComponent:clientProfile.rmserver] URLByAppendingPathComponent:clientProfile.userId] URLByAppendingPathComponent:@"rbk"];
    //
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    return cacheUrl;
}

#pragma mark - Getter/Setter
- (NSMutableDictionary *)optDict {
    if(_optDict == nil) {
        _optDict = [[NSMutableDictionary alloc] init];
    }
    return _optDict;
}

#pragma mark - FIX ME!!!!
- (NXFile *)offlineFileSourceFile:(NXOfflineFile *)offlineFile {
    NSAssert([offlineFile isKindOfClass:[NXOfflineFile class]], nil);
    NXFile *file = nil;
    if (offlineFile.sorceType == NXFileBaseSorceTypeProject) {
        file = [[NXOfflineFileManager sharedInstance]  getProjectFilePartner:offlineFile];
    }else if (offlineFile.sorceType == NXFileBaseSorceTypeMyVaultFile) {
        file = [[NXOfflineFileManager sharedInstance] getMyVaultFilePartner:offlineFile];
    }else if (offlineFile.sorceType == NXFileBaseSorceTypeShareWithMe) {
        file = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:offlineFile];
    }else if (offlineFile.sorceType == NXFileBaseSorceTypeWorkSpace) {
        file = [[NXOfflineFileManager sharedInstance] getWorkSpaceFilePartner:offlineFile];
    }else if (offlineFile.sorceType == NXFileBaseSorceTypeSharedWithProject) {
        file = [[NXOfflineFileManager sharedInstance] getShareWithProjectFilePartner:offlineFile];
    }
    
    NSAssert(file, @"Should have one source file!!");
    return file;
}
@end
