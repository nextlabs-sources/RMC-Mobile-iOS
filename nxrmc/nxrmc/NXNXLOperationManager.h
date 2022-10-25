//
//  NXNXLOperationManager.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NXLClient.h"
#import "NXFileBase.h"
#import "NXWatermarkWord.h"
#import "NXClassificationCategory.h"
#import "NXProjectFolder.h"
#import "NXProjectFile.h"
#import "NXLRights.h"
#import "NXProjectModel.h"
#import "NXClassificationCategory.h"
#import "NXWorkSpaceItem.h"
#import "NXRMCDef.h"

@class NXLProfile;
@class NXLClient;
@class NXLRights;
@class NXLFileValidateDateModel;
typedef void(^nxlOptEncryptCompletion)(NSString *filePath, NSError *error);
typedef void(^nxlOptEncryptMultipleFilesCompletion)(NSArray *successArray,NSArray *failArray,NSError *error);
typedef void(^nxlOptProtectMultipleFilesToWorkSpaceCompletion)(NSArray *successArray,NSArray *failArray,NSError *error);
typedef void(^nxlOptProtectMultipleCompletion)(NSArray *successArray,NSArray *failArray,NSError *error);
typedef void(^nxlOptProjectFileEncryptCompletion)(NXProjectFolder *projectFolder, NXProjectFile *newProjectFile, NSError *error);
typedef void(^nxlOptWorkSpaceFileEncryptCompletion)(NXFolder *folder, NXFileBase *newFile, NSError *error);
typedef void(^nxlOptShareFileToProjectCompletion)(NXProjectModel *destProject, NXProjectFile *newProjectFile, NSError *error);
typedef void(^nxlOptShareFileToWorkSpaceCompletion)(NXWorkSpaceFile *newWorkSpaceFile, NSError *error);
typedef void(^nxlOptClassificationRightsCompletion)(NXLRights *rights, NSError *error);
typedef void(^nxlOptDecryptCompletion)(NSString *filePath, NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSString *owner, BOOL isOwner, NSError *error);
typedef void(^nxlOptShareFileCompletion)(NSString *sharedFileName,NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error);
typedef void(^nxlOptShareLocalFileCompletion)(NSURL *originalFilePath,NSString *sharedFileName,NSArray *alreadySharedArray,NSArray *newSharedArray,NSError *error);
typedef void(^nxlOptUpateSharedFileCompletion)(NSArray *newRecipients, NSArray *removedRecipients, NSError *error);
typedef void(^nxlOptUpateProjectRecipentsFromSharedFileCompletion)(NSArray *newRecipients, NSArray *removedRecipients, NSArray *alreadyRecipients,NSError *error);
typedef void(^nxlOptRevokeDocumentCompletion)(NSError *error);
typedef void(^nxlOptGetNXLRightsCompletion)(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error);
typedef void(^nxlCheckCenterPolicyFileRightCompletion)(NXLRights *rights, NSError *error);
typedef void(^nxlOptIsStewardCompletion)(BOOL isSteward, NSError *error);
typedef void(^nxlOptCanDoOperationCompletion)(BOOL isAllowed, NSString *duid, NXLRights *rights, NSString *owner, BOOL isOwner, NSError *error);
typedef void(^downloadNXLFileAndDecryptedCompletion)(NXFileBase *file,NXLRights *originalNXLFileRights,NSString *duid,NSString*ownerId,NSError *error);
typedef void(^convertNXLFileCompletion)(NXFileBase *newNXLFile,NSString *originalFileownerID,NSString *originalFileDuid,NSString *newFileOwnerId,NSString *newFileDuid,NSError *error);
typedef void(^uploadNXLFileCompletion)(NXFileBase *file,NSError *error);
typedef void(^nxlOptAddNXLFileCompletion)(NXFileBase *file,NSError *error);
typedef void(^nxlCopyNXLFileCompletion)(NXFileBase *file,NSError *error);

@interface NXNXLOperationManager : NSObject
- (instancetype)initWithNXProfile:(NXLProfile *)profile;

+ (NXLClient *)currentNXLClient:(NSError **)error;
- (NSString *)protectAndUploadMultipleFilesToMyVault:(NSArray *)fileArray permissions:(NXLRights *)permissions membershipId:(NSString *)meberShipId  withCompletion:(nxlOptProtectMultipleCompletion)completion;
- (NSString *)protectToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId createDate:(NSDate *)createDate withCompletion:(nxlOptEncryptCompletion)completion;
// For encrypt
- (NSString *)onlyEncryptToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId createDate:(NSDate *)createDate withCompletion:(nxlOptEncryptCompletion)completion;
- (NSString *)onlyEncryptToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId  createDate:(NSDate *)createDate withCompletion:(nxlOptEncryptCompletion)completion;
// For project
- (void)encryptAndUploadMultipleFilesToRepo:(NSArray *)filesArray toPath:(NXFileBase *)folder permissions:(NXLRights *)permissions membershipId:(NSString *)memeberShipId withComplection:(nxlOptProtectMultipleCompletion)completion;
- (void)downloadAndEncryptMultipleFile:(NSArray *)filesArray  permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId  withComplection:(nxlOptEncryptMultipleFilesCompletion)completion;
- (void)downloadAndEncryptMultipleFile:(NSArray *)filesArray classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId  withComplection:(nxlOptEncryptMultipleFilesCompletion)completion;
- (void)encryptAndUploadMultipleFilesToRepo:(NSArray *)filesArray toPath:(NXFileBase *)folder classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memeberShipId withComplection:(nxlOptProtectMultipleCompletion)completion;
- (NSString *)protectFileToWorkSpace:(NXFileBase *)file toPath:(NSString *)destPath membershipId:(NSString *)memberShipId permissions:(NXLRights *)permissions classifications:(NSDictionary *)classificaitonDict intoFolder:(NXFolder *)folder createDate:(NSDate *)createDate andIsOverwrite:(BOOL)isOverwrite withCompletion:(nxlOptWorkSpaceFileEncryptCompletion)completion;
- (void)protectMultipleAlreadyDownloadFilesToWorkspace:(NSArray *)downloadFiles  membershipLid:(NSString *)memberShipId permissions:(NXLRights *)permissions classifications:(NSDictionary *)classificationDict inFolder:(NXFolder *)folder  withCompletion:(nxlOptProtectMultipleFilesToWorkSpaceCompletion)completion;
- (void)protectMultipleFilesToProject:(NSArray *)fileArray classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder  andIsOverwrite:(BOOL)isOverwrite  withCompletion:(nxlOptProtectMultipleCompletion)completion;
- (void)protectMultipleFilesToProject:(NSArray *)fileArray permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder  andIsOverwrite:(BOOL)isOverwrite  withCompletion:(nxlOptProtectMultipleCompletion)completion;
- (void)protectMultipleFilesToWorkspace:(NSArray *)fileArray membershipId:(NSString *)membershipId permissions:(NXLRights *)permissions classifications:(NSDictionary *)classificationDict intoFolder:(NXFolder *)folder withCompletion:(nxlOptProtectMultipleFilesToWorkSpaceCompletion)completion;
- (NSString *)protectToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder createDate:(NSDate *)createDate andIsOverwrite:(BOOL)isOverwrite withCompletion:(nxlOptProjectFileEncryptCompletion)completion;

- (NSString *)protectToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder createDate:(NSDate *)createDate  andIsOverwrite:(BOOL)isOverwrite withCompletion:(nxlOptProjectFileEncryptCompletion)completion;

- (void)decryptNXLFile:(NXFileBase *)file toPath:(NSString *)destPath withCompletion:(nxlOptDecryptCompletion)completion;

- (void)decryptNXLFile:(NXFileBase *)file toPath:(NSString *)destPath shouldSendLog:(BOOL)shouldSendLog withCompletion:(nxlOptDecryptCompletion)completion;
//- (void)addNXLFile:(NXFileBase *)file intoDestFolder:(NXFolder *)destFolder completion:(nxlOptAddNXLFileCompletion)completion;
- (void)addNXLFile:(NXFileBase *)file intoDestFolder:(NXFolder *)destFolder shouldRename:(BOOL)shouldRename newName:(NSString*)newName completion:(nxlOptAddNXLFileCompletion)completion;
// for save as
- (NSString *)saveAsNXlFileToLocal:(NXFileBase *)file withCompletion:(nxlCopyNXLFileCompletion)completion;
// for upload nxl file from local
- (NSString *)uploadNXLFromLocal:(NXFileBase *)file shouldOverwrite:(BOOL)overwrite toSpaceType:(NSString *)destType andDestPathFolder:(NXFileBase *)destpathFolder withCompletion:(nxlCopyNXLFileCompletion)completion;
// for copy nxl file
- (NSString *)copyNXLFile:(NXFileBase *)file toSpace:(NSString *)destPath withCompletion:(nxlCopyNXLFileCompletion)completion;
- (NSString *)copyNXLFile:(NXFileBase *)file shouldOverwrite:(BOOL)overwrite toSpaceType:(NSString *)destType andDestPathFolder:(NXFileBase *)destpathFolder withCompletion:(nxlCopyNXLFileCompletion)completion;
#pragma mark - SHARE
// share file to workspace

- (NSString *)shareFile:(NXFileBase *)file toWorkSpaceWithDestFolder:(NXWorkSpaceFolder *)destFolder classification:(NSArray<NXClassificationCategory *>*)classifications originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToWorkSpaceCompletion)completion;
- (NSString *)shareFile:(NXFileBase *)file toWorkSpaceWithDestFolder:(NXWorkSpaceFolder *)destFolder rights:(NXLRights *)digitalrights originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToWorkSpaceCompletion)completion;
// share file to project
- (NSString *)shareFile:(NXFileBase *)file toProject:(NXProjectModel *)project destFolder:(NXProjectFolder *)destFolder withClassification:(NSArray<NXClassificationCategory *>*)clafficications originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToProjectCompletion)completion;
- (NSString *)shareFile:(NXFileBase *)file toProect:(NXProjectModel *)project destFolder:(NXProjectFolder *)destFolder permissions:(NXLRights *)permissions originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToProjectCompletion)completion;



- (NSString *)shareProjectFile:(NXFileBase *)file recipients:(NSArray *)recipients permissions:(NXLRights *)permissions comment:(NSString *)comment originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid withCompletion:(nxlOptShareFileCompletion)completion;

// share file to mySpace
- (NSString *)shareFile:(NXFileBase *)file recipients:(NSArray *)recipients permissions:(NXLRights *)permissions comment:(NSString *)comment withCompletion:(nxlOptShareFileCompletion)completion;
// share project file to project
- (NSString *)shareProjectFile:(NXFileBase *)file fromPorject:(NXProjectModel *)project toRecipinets:(NSArray *)recipients comment:(NSString *)commnet withCompletion:(nxlOptShareFileCompletion)completion;
// update project recipient
- (NSString *)updateSharedFile:(NXFileBase *)file fromProject:(NXProjectModel *)projectModel addRecipients:(NSArray *)addRecipients removeRecipients:(NSArray *)removeRecipients comment:(NSString *)commnet withCompletion:(nxlOptUpateProjectRecipentsFromSharedFileCompletion)completion;
// share project file (adhoc)to person
- (NSString *)downloadNXLFileAndDecrypted:(NXFileBase *)file completion:(downloadNXLFileAndDecryptedCompletion)completion;

- (void)updateSharedFileRecipients:(NXFileBase *)file newRecipients:(NSArray *)newRecipients removedRecipients:(NSArray *)removedRecipients comment:(NSString *)comment withCompletion:(nxlOptUpateSharedFileCompletion)completion;
- (NSString *)revokeSharedFileByFileDuid:(NSString *)duid wtihCompletion:(nxlOptRevokeDocumentCompletion)completion;
- (void)revokeDocument:(NXFileBase *)file withCompletion:(nxlOptRevokeDocumentCompletion)completion;

- (void)getNXLFileRights:(NXFileBase *)file withWatermark:(BOOL)needWatermark withCompletion:(nxlOptGetNXLRightsCompletion)completion;

- (void)checkCenterPolicyFileRightsWithMemberShip:(NSString *)membershipId classifications:(NSArray<NXClassificationCategory *> *) classifications fileName:(NSString *)fileName withCompletion:(nxlCheckCenterPolicyFileRightCompletion)completion;
- (NSString *)checkCenterPolicyFileRightsForNXLFile:(NXFileBase *)fileBase copyToDestPathFolder:(NXFileBase *)pathFolder withDestMemberShip:(NSString *)membershipId  withCompletion:(nxlCheckCenterPolicyFileRightCompletion)completion;
- (BOOL)isNXLFile:(NXFileBase *)file;

- (void)canDoOperation:(NXLRIGHT)operationType forFile:(NXFileBase *)file withCompletion:(nxlOptCanDoOperationCompletion)completion;

- (void)cancelNXLOpt:(NSString *)optIdentify;

- (void)signOut:(NSError **)error;
- (void)updateProfile:(NXLProfile *)profile;

- (void)checkClassificationFileRights:(NXFileBase *)file duid:(NSString *)duid membershipId:(NSString *)memberShipId withCompletion:(nxlOptClassificationRightsCompletion)completion;

- (NSNumber *)nxlRightToLogRight:(NXLRIGHT)nxlRight;

#pragma mark - Cache operation
- (void)cleanCachedRight:(NXFileBase *)file;
- (void)cacheRights:(NXLRights *)rights duid:(NSString *)duid ownerId:(NSString *)ownerId forFile:(NXFileBase *)file;


@end
