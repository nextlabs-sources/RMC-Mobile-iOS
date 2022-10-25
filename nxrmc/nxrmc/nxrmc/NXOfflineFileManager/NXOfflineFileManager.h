//
//  NXOfflineFileManager.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/9.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXRMCDef.h"
#import "NXWebFileManager.h"
#import "NXOfflineFileTokenManager.h"
#import "NXOfflineFileRightsManager.h"
#import "NXOfflineFile.h"
#import "NXSharedWithMeFile.h"
#import "NXSharedWithProjectFile.h"
#import "NXWorkSpaceItem.h"

@class NXMyVaultFile,NXProjectFile,NXLRigthts,NXSharedWithProjectFile;

typedef void(^markFileAsOfflineCompletedBlock)(NXFileBase *fileItem, NSError *error);
typedef void(^markFileAsOfflineProgressBlock)(int64_t receivedSize,int64_t totalCount,double fractionCompleted);
typedef void(^unmarkFileAsOfflineCompletedBlock)(NXFileBase *fileItem, NSError *error);
typedef void(^operateOfflineFileCompletedBlock)(NXOfflineFile *fileItem,NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error);
typedef void(^optOfflineFileDecryptCompletionBlock)(NSString *filePath, NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSString *owner, BOOL isOwner, NSError *error);
typedef void(^offlineFileOptCanDoOperationCompletion)(BOOL isAllowed, NSString *duid, NXLRights *rights, NSString *owner, BOOL isOwner, NSError *error);
typedef void(^queryRightsCompletedBlock)(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error);
typedef void(^refreshOfflineFileListCompletdBlock)(NSError *error);
typedef void(^refreshOfflineFileExpireDateCompletedBlock)(NSError *error);
typedef void(^refreshOfflineFileTokenCompletedBlock)(NXFileBase *file,NSError *error);
typedef void(^refreshOfflineFileRightsCompletedBlock)(NXFileBase *file,NSError *error);

@interface NXOfflineFileManager : NSObject

@property(nonatomic, strong,readonly) NXWebFileManager *webFileManager;
@property(nonatomic, strong,readonly) NXOfflineFileTokenManager *offlineFileTokenManager;
@property(nonatomic, strong,readonly) NXOfflineFileRightsManager *offlineFileRightsManager;

+ (instancetype)sharedInstance;

- (NSString *)markFileAsOffline:(NXFileBase *)file
                 withCompletion:(markFileAsOfflineCompletedBlock)completion;

- (NSString *)markFileAsOffline:(NXFileBase *)file
                  progressBlock:(markFileAsOfflineProgressBlock)progressBlock
                 withCompletion:(markFileAsOfflineCompletedBlock)completion;

-(void)unmarkFileAsOffline:(NXFileBase *)file
            withCompletion:(unmarkFileAsOfflineCompletedBlock)completion;

//- (void)operateOfflineFile:(NXOfflineFile *)offlineFile
//            forOperateType:(NXOfflineFileOperateType)type
//            withCompletion:(operateOfflineFileCompletedBlock)completion;

- (void)decryptOfflineFile:(NXOfflineFile *)file
                    toPath:(NSString *)destPath
            withCompletion:(optOfflineFileDecryptCompletionBlock)completion;

// remain
//- (void)configureOfflineFileDefaultExpireDate:(NSDate *)date;
//- (NSDate *)getDefaultExpireDate;

- (NSArray *)allOfflineFileList;
- (NSArray *)allOfflineFileListFromProject:(NSNumber *)projectId;
- (NSArray *)allOfflineFileListFromMyVault;
- (NSArray *)allOfflineFileListFromMyVaultAndSharedWithMe;
- (NSArray *)allOfflineFileListFromSharedWithMe;
- (NSArray *)allOfflineFileListFromWorkSpace;
- (BOOL)isEncryptedByCenterPolicy:(NXOfflineFile *)file;
- (NXFileState)currentState:(NXFileBase *)file;
- (void)cancelAllMarkTask;
- (BOOL)hasMarkingAsOfflinedFile;
- (BOOL)checkIsExpire:(NXOfflineFile *)offlineFile;
- (void)updateOfflineFileMarkAsOfflineDate:(NXOfflineFile *)file;

- (void)refreshTokenForFile:(NXFileBase *)file
             withCompletion:(refreshOfflineFileTokenCompletedBlock)completion;

- (void)refreshRightsForFile:(NXFileBase *)file
           withCompletion:(refreshOfflineFileRightsCompletedBlock)completion;

- (NXOfflineFile *)getOfflineFilePartner:(NXFileBase *)file;
- (void)canDoOperation:(long)operationType forFile:(NXOfflineFile *)file withCompletion:(offlineFileOptCanDoOperationCompletion)completion;

- (void)queryRightsForFile:(NXFileBase *)file
            withCompletion:(queryRightsCompletedBlock)completion;

- (void)refreshOfflineFileList:(NSArray *)fileList
                withCompletion:(refreshOfflineFileListCompletdBlock)completion;

- (void)refreshOfflineFileExpireDate:(NXOfflineFile *)file withCompletion:(refreshOfflineFileExpireDateCompletedBlock)completion;
- (void)cancelRefreshOfflineFileExpireDateOpt:(NXFileBase *)file;
- (NXMyVaultFile *)getMyVaultFilePartner:(NXOfflineFile *)offlineFile;
- (NXProjectFile *)getProjectFilePartner:(NXOfflineFile *)offlineFile;
- (NXSharedWithMeFile *)getSharedWithMeFilePartner:(NXOfflineFile *)offlineFile;
- (NXWorkSpaceFile *)getWorkSpaceFilePartner:(NXOfflineFile *)offlineFile;
- (NXSharedWithProjectFile *)getShareWithProjectFilePartner:(NXOfflineFile *)offlineFile;
- (BOOL)hasConvertingFailedFile;
- (void)addToConvertOfflineFileSet:(NSString *)fileKey;
- (void)removeFromConvertOfflineFileSet:(NSString *)fileKey;

- (void)updateLastModifyDate:(NXFileBase *)file;

@end
