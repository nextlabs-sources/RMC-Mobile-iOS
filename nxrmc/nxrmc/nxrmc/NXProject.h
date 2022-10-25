//
//  NXProject.h
//  nxrmc
//
//  Created by xx-huang on 22/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXProjectMemberModel.h"
#import "NXProjectFile.h"
#import "NXProjectFolder.h"
#import "NXProjectModel.h"
#import "NXProjectFileListParameterModel.h"
#import "NXProjectMemberModel.h"
#import "NXProjectUploadFileParameterModel.h"
#import "NXPendingProjectInvitationModel.h"
#import "NXClassificationCategory.h"
@class NXProjectModel;
@class NXProjectOwnerItem;
typedef void(^inviteMemberCompletion)(NSDictionary *resultDic, NSError *error);
typedef void(^getListMemberCompletion)(NXProjectModel *project, NSArray *membersArray, NSError *error);
typedef void(^projectMetaDataCompletion)(NXProjectModel *project, NSError *error);
typedef void(^getProjectClassificationsCompletion)(NSArray<NXClassificationCategory *> *projectClassifications, NSError *error);
typedef void(^getMemberDetailCompletion)(NXProjectMemberModel *member, NSError *error);
typedef void(^removeMemberCompletion)(NSError *error);

typedef void(^getFileListCompletion)(NXProjectModel *project, NXProjectFolder *parentFolder, NSArray *fileList, NSError *error);
typedef void(^getRecentFileCompletion)(NXProjectModel *project,NSArray *fileList,NSDictionary *spaceDict, NSError *error);
typedef void(^getProjectMembershipIdCompletion)(NXProjectModel *project, NSError *error);
typedef void(^deleteProjectFileItemCompletion)(NXFileBase *file, NSError *error);

typedef void(^uploadFileCompletion)(NXProjectFile *file, NSError *error);

typedef void(^downloadFileCompletion)(NXProjectFile *file, NSError *error);
typedef void(^createProjectFolderCompletion)(NXProjectFolder *folder, NSError *error);

typedef void(^getFileMetaDataCompletion)(NXProjectFile *file, NSError *error);
typedef void(^searchFileCompletion)(NSArray *matchsFile, NSError *error);

typedef void(^projectRevokeProjectInvitionCompletion)(NSString *statusCode, NSError *error);
typedef void(^projectResendProjectInvitionCompletion)(NSString *statusCode, NSError *error);

typedef void(^reClassifyFileCompletion)(NXProjectFile *file, NSError *error);

typedef void(^getSharedWithProjectFileListCompletion)(NXProjectModel *project, NSArray *sharedWithProjectFileList, NSError *error);

typedef NS_ENUM(NSInteger, NXProjectState){
    NXProjectStateActive = 1,
    NXProjectStateInactive,
};
@class NXLFileValidateDateModel;
@interface NXProject : NSObject

@property(nonatomic, strong) NSNumber *projectId;
@property(nonatomic, strong) NSString *parentTenantId;
@property(nonatomic, strong) NSString *membershipId;
@property(nonatomic, strong) NSString *tokenGroupName;
@property(nonatomic, strong) NSString *projectName;
@property(nonatomic, strong) NSString *parentTenantName;
@property(nonatomic, strong) NSString *projectDescription;
@property(nonatomic, strong) NSString *invitationMsg;
@property(nonatomic, assign) NSTimeInterval creationTime;
@property(nonatomic, assign, readonly) NSTimeInterval lastActionTime;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSMutableArray *members;
@property(nonatomic, strong) NSMutableArray *homeShowMembers;
@property(nonatomic, strong) NSMutableArray *pendingMembers;
@property(nonatomic, assign) NSUInteger totalMembers;
@property(nonatomic, assign) NSUInteger totalFiles;
@property(nonatomic, assign) BOOL isCreatedByMe;
@property(nonatomic, strong) NXProjectOwnerItem *owner;
@property(nonatomic, assign) NXProjectState projectState;
@property (nonatomic, strong) NSString *watermark;
@property (nonatomic, assign) NSTimeInterval configurationModified;
@property (nonatomic, strong) NXLFileValidateDateModel *validateModel;

- (instancetype) initWithProjectModel:(NXProjectModel *)projectModel;
- (void)activeProjectAtLocalTime:(NSTimeInterval)lastActionTime;
- (void)inactiveProject;
#pragma -mark Invitation Operation
- (void)resendInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectResendProjectInvitionCompletion)completion;
- (void)revokePendingInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectRevokeProjectInvitionCompletion)completion;

#pragma -mark GET ProjectModel METHOD

- (NXProjectModel *)getProjectModel;

#pragma -mark GET METHOD

- (NSOperation *)getListMemberWithPage:(NSUInteger)page
                                  siez:(NSUInteger)size
                               orderBy:(ListMemberOrderByType)orderByType
                   shouldReturnUserPic:(BOOL)shouldReturnUserPic
                            Completion:(getListMemberCompletion)completion;

- (NSOperation *)getMemberDetailByMemberId:(NSString *)memberId withCompletion:(getMemberDetailCompletion)completion;

- (NSOperation *)getMembershipIdByProjectModel:(NXProjectModel *)projectModel withCompletion:(getProjectMembershipIdCompletion)completion;

-(NSOperation *)getFileMetaData:(NXProjectFile *)file withCompletion:(getFileMetaDataCompletion)completion;

- (NSOperation *)getFileListByPage:(NSUInteger)page
                              size:(NSUInteger)size
                           orderBy:(NXProjectFileListOrderByType)orderByType
                        parentPath:(NSString *)parentPath
                    withCompletion:(getFileListCompletion)completion;
- (NSOperation *)getRecentFileListByPage:(NSUInteger)page size:(NSUInteger)size withCompletion:(getRecentFileCompletion)completion;
- (NSOperation *)getFileListParentPath:(NSString *)parentPath filterType:(NXProjectFileListFilterByType)filterByType orderBy:(NXProjectFileListOrderByType)orderByType withCompletion:(getFileListCompletion)completion;
- (NSOperation *)getProjectMetaDataWithCompletion:(projectMetaDataCompletion) completion;
- (NSOperation *)getProjectClassificationsWithCompletion:(getProjectClassificationsCompletion)completion;
- (NSOperation *)getSharedWithProjectFileListWithCompletion:(getSharedWithProjectFileListCompletion)completion;

#pragma -mark DELETE METHOD

- (void)removeMember:(NXProjectMemberModel *)member withCompletion:(removeMemberCompletion)completion;

- (NSOperation *)deleteFileItem:(NXFileBase *)file withCompletion:(deleteProjectFileItemCompletion)completion;

#pragma -mark UPDATE METHOD
- (NSOperation *)getListPendingWithPage:(NSUInteger)page size:(NSUInteger)size orderBy:(ListPendingOrderByType)orderByType Completion:(getListMemberCompletion)completion;
- (void)inviteMember:(NSArray *)members invitationMsg:(NSString *)invitationMsg withCompletion:(inviteMemberCompletion)completion;

- (NSOperation *)uploadFile:(NXProjectUploadFileParameterModel *)file underFolder:(NXProjectFolder *)folder progress:(NSProgress *)uploadProgress withCompletion:(uploadFileCompletion)completion;


- (NSOperation *)createFolder:(NXProjectFolder *)newFolder autoRename:(NSString *)autoRename underFolder:(NXProjectFolder *)folder withCompletion:(createProjectFolderCompletion)completion;

#pragma -mark QUERY METHOD

-(NSOperation *)searchFileWithQueryKeyword:(NSString *)queryKeyword withCompletion:(searchFileCompletion)completion;
- (NXFileBase *)queryParentFolderForFolder:(NXProjectFolder *)projectFolder;
#pragma -mark RECLASSIFY FILE MERHOD
-(NSOperation *)reClassifyFile:(NXProjectFile *)fileItem withNewTags:(NSDictionary *)tags withCompletion:(reClassifyFileCompletion)completion;
@end
