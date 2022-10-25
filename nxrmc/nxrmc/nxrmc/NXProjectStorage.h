//
//  NXProjectStorage.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 12/9/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, NXProjectListType) {
    NXProjectListTypeByAll = 1,
    NXProjectListTypeByMe,
    NXProjectListTypeByOther,
};

@class NXProjectModel;
@class NXProjectMemberModel;
@class NXPendingProjectInvitationModel;
@class NXFileBase;
@class NXFile;
@class NXProjectFile;
@interface NXProjectStorage : NSObject

#pragma mark ------> Insert or update project
+ (void)insertProjectModel:(NXProjectModel *)projectModel;
+ (void)insertProjectModels:(NSArray *)projectItemModels;

#pragma mark -----> Query project list
+ (NSMutableArray *)queryProjectListFromStorageWhichType:(NXProjectListType)byType;
+ (NXProjectModel *)queryProjectModelByProjectModel:(NXProjectModel *)projectModel;
#pragma mark -----> Delete project
+ (void)deleteProjectModel:(NXProjectModel *)projectModel;

#pragma mark -----> Insert member for project
+ (void)insertMenber:(NXProjectMemberModel *)memberModel toProject:(NXProjectModel *)projectModel;
+ (void)insertMembers:(NSArray *)members toProject:(NXProjectModel *)projectModel;

#pragma mark -----> Query member by projectId
+ (NSMutableSet *)queryMemberByProjectId:(NSNumber *)projectId;
#pragma mark -----> Delete member from project
+ (void)deleteProjectMember:(NXProjectMemberModel *)member fromProject:(NXProjectModel *)projectModel;

#pragma mark -----> Insert pending member for project
+ (void)insertPendingMembers:(NSArray *)pendingMembers toProject:(NXProjectModel *)projectModel;
#pragma mark -----> Query pending member for project
+(NSMutableArray *)quertAllPendingMembersFromProject:(NXProjectModel *)projectModel;
#pragma mark -----> Delete pending member for project
+ (void)deletePendingMember:(NXPendingProjectInvitationModel *)member fromProject:(NXProjectModel *)projectModel;
#pragma mark -----> Insert file for project
+ (void)insertProjectFiles:(NSArray *)files toFolder:(NSString *)folderPath toProject:(NXProjectModel *)projectModel;
+ (void)insertProjectFile:(NXFileBase *)fileModel toParentFolder:(NSString *)folderPath toProjectModel:(NXProjectModel *)projectModel;

#pragma mark -----> Delete file form project
+ (void)deleteProjectFile:(NXFileBase *)file fromProjectModel:(NXProjectModel *)projectModel;
+ (void)deleteAllProjectFilesFromProject:(NXProjectModel *)projectModel;

#pragma mark ----->Query project file for project
+ (NSMutableArray *)queryProjectFilesUnderFolder:(NSString *)folderPath fromProject:(NXProjectModel *)projectModel;
+ (NSMutableArray *)querySummanyProjectFile:(NXProjectModel *)projectModel;
+ (NSMutableArray *)queryAllSharedByProjectFile:(NXProjectModel *)projectModel;


#pragma mark ----->Query project for project file
+ (NXProjectModel *)queryProjectModelByProjectFile:(NXFileBase *)fileBase;
#pragma mark ----->update projectFileItem in coredata
+(void)updateProjectFileItem:(NXProjectFile *)projectFile;
#pragma mark ----->update parent folder
+ (NXFileBase *)queryParentFolderForProjectFolder:(NXFileBase *)projectFolder fromProject:(NXProjectModel *)projectModel;

#pragma mark ----->Shared by project file list
+ (NSMutableArray *)querySharedByProjectFile:(NXProjectModel *)projectModel;
+ (void)updateSharedByProjectFileItems:(NXProjectModel *)projectModel withSharedByFileList:(NSArray<NXProjectFile *> *)sharedByFileList;
@end
