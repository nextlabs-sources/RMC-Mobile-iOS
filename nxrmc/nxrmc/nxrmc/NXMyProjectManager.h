//
//  NXMyProjectManager.h
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXProjectMemberModel.h"
#import "NXProjectModel.h"
#import "NXProjectFile.h"
#import "NXProjectFolder.h"
#import "NXProjectUploadFileParameterModel.h"
#import "NXPendingProjectInvitationModel.h"
#import "NXFileChooseFlowDataSorceDelegate.h"
#import "NXClassificationCategory.h"

#define NXPrjectInvitationNotifiy @"NXPrjectInvitationNotifiy"
#define NXProjectInvitationsKey @"NXProjectInvitationsKey"
@class NXSharedWithProjectFile;
// listInvitationsProjectCompletion
typedef void(^queryAllMyProjectCompletion)(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers,NSArray *pendingProjects, NSError *error);
typedef void(^queryAllProjectCompletion)(NSArray *projects, NSError *error);
typedef void(^queryAllMyProjectContainMembersCompletion)(NSArray *projectsCreatedByMe,NSArray *projectsInvitedByOthers,NSTimeInterval serverTime, NSError *error);
typedef void(^queryProjectMetadataCompletion)(NXProjectModel *projectModel, NSError *error);
typedef void(^queryAllInvitationsCompletion)(NSArray *allInvitations);
typedef void(^queryAllMemebersInProjectCompletion)(NXProjectModel *project, NSArray *memebersArray, NSError *error);
typedef void(^queryAllMemebersContainPendingInProjectCompletion)(NXProjectModel *project, NSArray *memebersArray, NSArray *pendingsArray,NSError *error);
typedef void(^queryAllPendingInProjectCompletion)(NXProjectModel *project, NSArray *pendingArray, NSError *error);
typedef void(^listInvitationsProjectCompletion)(NXProjectModel *project, NSArray *invitationsArray, NSError *error);
typedef void(^inviteMemberInProjectCompletion)(NXProjectModel *project, NSDictionary *resultDic, NSError *error);
typedef void(^removeMemberFromProjectCompletion)(NSError *error);
typedef void(^getProjectModelByIdCompletion)(NXProjectModel *projectModel, NSError *error);
typedef void(^getFileMetaDataCompletion)(NXProjectFile *file, NSError *error);
typedef void(^getSharedWithProjectFileMetaDataCompletion)(NXSharedWithProjectFile *file, NSError *error);
typedef void(^getMemberDetailsCompletion)(NXProjectMemberModel *memberDetail, NSError *error);
typedef void(^getMemberShipIDCompletion)(NXProjectModel *projectModel, NSError *error);

typedef void(^addProjectFileUnderParentFolderCompletion)(NXProjectFolder *parentFolder, NXProjectFile *newProjectFile, NSError *error);
typedef void(^downloadProjectFileCompletion)(NXProjectFile *file, NSError *error);
typedef void(^getProjectFileListCompletion)(NXProjectModel *project, NXProjectFolder *parentFolder, NSArray *fileList, NSError *error);
typedef void(^getFilterProjectFileListCompletion)(NXProjectModel *project, NSArray *fileList, NSError *error);
typedef void(^getProjectRecentFileListCompletion)(NXProjectModel *project,NSArray *fileList,NSDictionary *spaceDict, NSError *error);
typedef void(^creatProjectCompletion)(NXProjectModel *project, NSError *error);
typedef void(^updateProjectCompletion)(NXProjectModel *project, NSError *error);
typedef void(^deleteProjectFileItemCompletion)(NXFileBase *fileItem, NSError *error);
typedef void(^createProjectFolderCompletion)(NXProjectFolder *newProjectFolder, NSError *error);
typedef void(^queryProjectFileMetaDataCompletion)(NXProjectFile *fileMetaData, NSError *error);

typedef void(^acceptProjectInvitationCompletion)(NXProjectModel *project,NSTimeInterval serverTime, NSError *error);
typedef void(^invitationCompletion)(NSError *error);

typedef void(^revokeProjectInvitionCompletion)(NSString *statusCode, NSError *error);
typedef void(^resendProjectInvitionCompletion)(NSString *statusCode, NSError *error);
typedef void(^declineProjectInvitationCompletion)(NXPendingProjectInvitationModel *pendingInvitation,NSTimeInterval serverTime, NSError *error);

// classificaitons
typedef void(^queryProjectClassificationCompletion)(NXProjectModel *project, NSArray<NXClassificationCategory *> *classificaiton, NSError *error);
typedef void(^reclassifyFileCompletion) (NXProjectFile *newProjectFile,NSError *error);

// Shared with project
typedef void(^getSharedWithProjectFileListFromProjectCompletion)(NXProjectModel* project, NSArray *sharedFileListWithProject, NSError *error);

@class NXLProfile;
@interface NXMyProjectManager : NSObject<NXFileChooseFlowDataSorceDelegate>
#pragma mark - Initialize and config
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile;
- (void)bootup;
- (void)shutDown;

#pragma mark - Project operations
- (NSString *)createProject:(NXProjectModel *)projectModel invitedEmails:(NSArray *)emails invitationMsg:(NSString *)invitationMsg withCompletion:(creatProjectCompletion)completion;
- (NSString *)updateProject:(NXProjectModel *)projectModel withCompletion:(updateProjectCompletion)completion;
- (NSString *)allMyProjectsWithCompletion:(queryAllMyProjectCompletion)completion;
- (NSString *)allProjectsWithCompletion:(queryAllProjectCompletion)completion;
- (NSString *)allMyProjectsContainAllMemberWithCompletion:(queryAllMyProjectContainMembersCompletion)completion;
- (NSString *)project:(NXProjectModel *)projectModel MetadataWithCompletion:(queryProjectMetadataCompletion)completion;
//- (void)getAllMembersContainPendingsInProject:(NXProjectModel *)projectModel withCompletion:(queryAllMemebersContainPendingInProjectCompletion)completion;
- (void)getAllMembersContainPendingsInProject:(NXProjectModel *)projectModel isReadCache:(BOOL)isReadCache withCompletion:(queryAllMemebersContainPendingInProjectCompletion)completion;
- (void)allMemebersInProject:(NXProjectModel *)projectModel withCompletion:(queryAllMemebersInProjectCompletion)completion;
- (void)inviteMember:(NSArray *)memberArray invitationMsg:(NSString *)invitationMsg  inProject:(NXProjectModel *)projectModel withCompletion:(inviteMemberInProjectCompletion)completion;
- (NSString *)getMemberDetails:(NXProjectMemberModel *)memberModel  withCompletion:(getMemberDetailsCompletion)completion;
- (NSString *)getMemberShipID:(NXProjectModel *)projectModel withCompletion:(getMemberShipIDCompletion)completion;
- (NSString *)getFileMetaData:(NXProjectFile *)projectFile withCompletion:(getFileMetaDataCompletion)completion;
- (NSString *)getSharedWithProjectFileMetadata:(NXSharedWithProjectFile *)fileItem withCompletion:(getSharedWithProjectFileMetaDataCompletion)completion;
- (void)removeProjectMember:(NXProjectMemberModel *)memberModel withCompletion:(removeMemberFromProjectCompletion)completion;
- (NSString *)projectModelByProjectId:(NSNumber *)projectId withCompletion:(getProjectModelByIdCompletion)completion;
- (NSArray  *)getAllProjectParentTenantNameArray;
#pragma mark - Project file item operations
- (NSString *)addFile:(NXProjectUploadFileParameterModel *)upFileParModel underParentFolder:(NXProjectFolder *)parentFolder progress:(NSProgress *)uploadProgress withCompletion:(addProjectFileUnderParentFolderCompletion)completion;
- (NSString *)getFileListUnderParentFolder:(NXProjectFolder *)parentFolder withCompletion:(getProjectFileListCompletion)completion;
- (NSString *)getFileListFromServerUnderParentFolder:(NXProjectFolder *)parentFolder  withCompletion:(getProjectFileListCompletion)completion;
- (NSArray *)getFileListUnderParentFolderInCoreData:(NXProjectFolder *)parentFolder;
- (NSString *)getShareByProjectFileListForProject:(NXProjectModel *)projectModel withCompletion:(getFilterProjectFileListCompletion)completion;
- (NSString *)getAllRevokedFileListForProject:(NXProjectModel *)projectModel withCompletion:(getFilterProjectFileListCompletion)completion;
- (NSString *)getFileListRecentFileForProject:(NXProjectModel *)projectModel withCompletion:(getProjectRecentFileListCompletion)completion;
- (NSString *)removeFileItem:(NXFileBase *)fileItem withCompletion:(deleteProjectFileItemCompletion)completion;
- (NSString *)createProjectFolder:(NSString *)folderName isAutoRename:(BOOL)autoRename underFolder:(NXProjectFolder *)parentFolder withCompletion:(createProjectFolderCompletion)completion;
- (NSString *)createProjectFolderUnderRootFolderWithName:(NSString *)folderName isAutoRename:(BOOL)autoRename withCompletion:(createProjectFolderCompletion)completion;
- (NSString *)queryFileItemMetaData:(NXProjectFile *)fileItem withCompletion:(queryProjectFileMetaDataCompletion)completion;
- (NSString *)reclassifyFileWithParameterModel:(NXProjectFile *)fileItem withNewTags:(NSDictionary *)tags withCompletion:(reClassifyFileCompletion)completion;
- (void)updateProjectFileInCoreData:(NXProjectFile *)projectFile;
- (void)updateSharedWithProjectFileInCoreData:(NXSharedWithProjectFile *)projectFile;
#pragma mark - Invitaion
- (NSString *)listPendingInvitationsForProject:(NXProjectModel *)projectModel WithCompletion:(listInvitationsProjectCompletion)competion;
- (void)allPendingProjectInvitainsWithCompletion:(queryAllInvitationsCompletion)completion;
- (void)acceptProjectInvitation:(NXPendingProjectInvitationModel *)invitation withCompletion:(acceptProjectInvitationCompletion)completion;
- (void)revokeProjectInvitation:(NXPendingProjectInvitationModel *)pendingModel withComoletion:(revokeProjectInvitionCompletion)completion;
- (void)resendProjectInvitation:(NXPendingProjectInvitationModel *)pendingModel withComoletion:(resendProjectInvitionCompletion)completion;
- (void)declineProjectInvitation:(NXPendingProjectInvitationModel *)invitation forReason:(NSString *)declineReason withCompletion:(declineProjectInvitationCompletion)completion;

#pragma mark - Classification
- (NSString *)allClassificationsForProject:(NXProjectModel *)projectModel withCompletion:(queryProjectClassificationCompletion)completion;

#pragma mark - Help method
+ (NXProjectFolder *)rootFolderForProject:(NXProjectModel *)projectModel;
- (NXProjectModel *)getProjectModelForFile:(NXProjectFile *)projectFile;
- (NXProjectModel *)getProjectModelForFolder:(NXProjectFolder *)projectFolder;
- (NXProjectModel *)getProjectModelForProjectId:(NSNumber *)projectId;
- (NXProjectModel *)getProjectModelFromAllProjectForProjectId:(NSNumber *)projectId;

- (void)startSyncProjectInfo;
- (void)pauseSyncProjectInfo;
- (void)activeProject:(NXProjectModel *)projectModel atLocalTime:(NSTimeInterval)lastActionTime;
- (void)inactiveProject:(NXProjectModel *)projectModel;

- (void)cancelOperation:(NSString *)operationIdentify;
@property (nonatomic, weak) id upDateFiledelegate;

#pragma mark - Shared With to project
- (NSString *)getSharedFileListInProject:(NXProjectModel *)project withCompletion:(getSharedWithProjectFileListFromProjectCompletion)completion;
@end


@protocol NXMyProjectFileUpdateDelegate <NSObject>
- (void)nxMyProjectManager:(NXMyProjectManager *)manager didGetProjectFiles:(NSArray *)files underFolder:(NXProjectFolder *)folder withSpaceDict:(NSDictionary *)dict withError:(NSError *)error;
@end
