//
//  NXProject.m
//  nxrmc
//
//  Created by xx-huang on 22/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProject.h"
#import "NXProjectFile.h"
#import "NXProjectListMembersOperation.h"
#import "NXProjectFileMetaDataOperation.h"
#import "NXProjectFileMetaDataAPI.h"
#import "NXProjectFileListOperation.h"
#import "NXProjectRecentFilesOperation.h"
#import "NXProjectFileListParameterModel.h"
#import "NXProjectDeleteFileOperation.h"
#import "NXProjectDeleteFolderOperation.h"
#import "NXProjectInvitationOperation.h"
#import "NXProjectUploadFileOperation.h"
#import "NXProjectDownloadFileOperation.h"
#import "NXProjectUploadFileParameterModel.h"
#import "NXProjectCreateFolderOperation.h"
#import "NXProjectSearchOpearation.h"
#import "NXProjectUploadFileAPI.h"
#import "NXProjectGetMemberDetailsOperation.h"
#import "NXProjectRemoveMemberOperation.h"
#import "NXProjectListPendingOperation.h"
#import "NXProjectMetaDataOperation.h"
#import "NXProjectGetClassificationProfileOperation.h"
#import "NXProjectReclassifyFileOperation.h"
#import "NXProjectStorage.h"
#import "NXProjectMemberSync.h"
#import "NXProjectPendingMemberSync.h"
#import "NXProjectGetMembershipIdOperation.h"
#import "NXLFileValidateDateModel.h"
#import "NXSharedWithProjectFileListOperation.h"

@interface NXProject()<NXProjectMemberSyncDelegate, NXProjectPendingMemberSyncDelegate>
@property(nonatomic, strong) NXProjectMemberSync *memberSync;
@property(nonatomic, strong) NXProjectPendingMemberSync *pendingMemberSync;
@property(nonatomic, assign, readwrite) NSTimeInterval lastActionTime;
@property(nonatomic, strong) NSMutableArray<NXClassificationCategory *> *projectClassifications;
@property(nonatomic, strong) NSMutableArray *queryProjectClassificationsCallBackBlocks;
@property(nonatomic, strong) NXProjectGetClassificationProfileOperation *getClassificationOpt;
@end

@implementation NXProject

#pragma -mark GET ProjectModel METHOD

- (instancetype) initWithProjectModel:(NXProjectModel *)projectModel
{
    self = [super init];
    if (self) {
        _projectId = [projectModel.projectId copy];
        _parentTenantId = [projectModel.parentTenantId copy];
        _parentTenantName = [projectModel.parentTenantName copy];
        _membershipId = [projectModel.membershipId copy];
        _tokenGroupName = [projectModel.tokenGroupName copy];
        _projectName = [projectModel.name copy];
        _projectDescription = [projectModel.projectDescription copy];
        _creationTime = projectModel.createdTime;
        _lastActionTime = projectModel.lastActionTime;
        _displayName = projectModel.displayName;
        _totalMembers = projectModel.totalMembers;
        _homeShowMembers = [projectModel.homeShowMembers mutableCopy];
//        _pendingMembers = [projectModel.pendingMembers mutableCopy];
        _totalFiles = projectModel.totalFiles;
        _isCreatedByMe = projectModel.isOwnedByMe;
        _owner = [projectModel.projectOwner copy];
        _memberSync = [[NXProjectMemberSync alloc] initWithProjectModel:projectModel members:projectModel.homeShowMembers];
        _memberSync.delegate = self;
        _pendingMemberSync = [[NXProjectPendingMemberSync alloc] initWithProjectModel:projectModel pendingMembers:nil];
        _pendingMemberSync.delegate = self;
        _projectState = NXProjectStateInactive;
        _watermark = [projectModel.watermark copy];
        _configurationModified = projectModel.configurationModified;
        _validateModel = [projectModel.validateModel copy];
    }
    return self;
}

- (void)dealloc
{
    [self.memberSync destory];
    [self.pendingMemberSync destory];
}

- (void)activeProjectAtLocalTime:(NSTimeInterval)lastActionTime
{
    if (self.projectState == NXProjectStateInactive) {
        self.projectState = NXProjectStateActive;
        [self.memberSync startSyncProjectMember];
        [self.pendingMemberSync startSyncProjectPendingMember];
        NSOperation *opt = [self getProjectClassificationsWithCompletion:^(NSArray<NXClassificationCategory *> *projectClassifications, NSError *error) {
            
        }];
        [opt start];
    }
    self.lastActionTime = lastActionTime;
    [NXProjectStorage insertProjectModel:[self getProjectModel]];
}

- (void)inactiveProject
{
    if (self.projectState == NXProjectStateActive) {
        self.projectState = NXProjectStateInactive;
        [self.memberSync stopSyncProjectMember];
        [self.pendingMemberSync stopSyncProjectPendingMember];
        [self.projectClassifications removeAllObjects];
    }
}

- (NXProjectModel *)getProjectModel
{
    NXProjectModel *model = [[NXProjectModel alloc] initWithProject:self];
    return model;
}


- (NSMutableArray *)getPendingMembers{
    @synchronized (self) {
        return _pendingMembers;
    }
}

#pragma -mark Quick Interface 
- (void)resendInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectResendProjectInvitionCompletion)completion
{
    [self.pendingMemberSync resendInvitation:pendingInvitation withCompletion:^(NSString *statusCode, NSError *error) {
        completion(statusCode, error);
    }];
}

- (void)revokePendingInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectRevokeProjectInvitionCompletion)completion
{
    [self.pendingMemberSync revokeInvitation:pendingInvitation withCompletion:^(NSString *statusCode, NSError *error) {
        completion(statusCode, error);
    }];
}


#pragma -mark GET METHOD
- (NSMutableArray *)projectClassifications {
    @synchronized (self) {
        if (_projectClassifications == nil) {
            _projectClassifications = [[NSMutableArray alloc] init];
        }
        return _projectClassifications;
    }
}

- (NSMutableArray *)queryProjectClassificationsCallBackBlocks {
    @synchronized (self) {
        if (_queryProjectClassificationsCallBackBlocks == nil) {
            _queryProjectClassificationsCallBackBlocks = [[NSMutableArray alloc] init];
        }
        return _queryProjectClassificationsCallBackBlocks;
    }
}

- (NSOperation *)getListMemberWithPage:(NSUInteger)page
                                  siez:(NSUInteger)size
                               orderBy:(ListMemberOrderByType)orderByType
                   shouldReturnUserPic:(BOOL)shouldReturnUserPic
                            Completion:(getListMemberCompletion)completion
{
    NXProjectListMembersOperation *memberListOpera = [[NXProjectListMembersOperation alloc] initWithProjectModel:[self getProjectModel] page:page size:size orderBy:orderByType shouldReturnUserPicture:shouldReturnUserPic];
    
    NXProjectModel *projectModel = [self getProjectModel];
    memberListOpera.projecListMembersCompletion = ^(NSMutableArray *membersArray,NSInteger totalMembers,NSError *error){
        completion(projectModel, [membersArray copy], error);
    };
    
    return memberListOpera;
}

- (NSOperation *)getMemberDetailByMemberId:(NSString *)memberId withCompletion:(getMemberDetailCompletion)completion;
{
    NXProjectGetMemberDetailsOperation *getMemberDetailsOpera = [[NXProjectGetMemberDetailsOperation alloc] initWithProjectModel:[self getProjectModel] memberId:memberId];
    
    getMemberDetailsOpera.getMemberDetaisCompletion = ^(NXProjectMemberModel *memberDetail,NSError *error){
        
        completion(memberDetail,error);
    };
    
    return getMemberDetailsOpera;
}

- (NSOperation *)getMembershipIdByProjectModel:(NXProjectModel *)projectModel withCompletion:(getProjectMembershipIdCompletion)completion
{
     NXProjectGetMembershipIdOperation* getMemberShipIdOpera = [[NXProjectGetMembershipIdOperation alloc] initWithProjectModel:[self getProjectModel]];
    
    getMemberShipIdOpera.getMembershipIdCompletion = ^(NXProjectModel *model,NSError *error){
        completion(model,error);
    };
    
    return getMemberShipIdOpera;
}

-(NSOperation *)getFileMetaData:(NXProjectFile *)file withCompletion:(getFileMetaDataCompletion)completion
{
    NXProjectFileMetaDataOperation *fileMetaDataOpera = [[NXProjectFileMetaDataOperation alloc] initWithProjectModel:[self getProjectModel] filePath:file.fullServicePath];
    
    fileMetaDataOpera.getProjectFileMetadataCompletion = ^(NXProjectFile *fileInfo,NSString*filePath,NSError *error){
    
        completion(fileInfo,error);
    };
    
    return fileMetaDataOpera;
}

- (NSOperation *)getFileListByPage:(NSUInteger)page
                              size:(NSUInteger)size
                           orderBy:(NXProjectFileListOrderByType )orderByType
                        parentPath:(NSString *)parentPath
                    withCompletion:(getFileListCompletion)completion
{
    NXProjectFileListParameterModel *paraModel = [[NXProjectFileListParameterModel alloc] init];
    
    paraModel.page = [NSString stringWithFormat:@"%lu",(unsigned long)page];
    paraModel.size = [NSString stringWithFormat:@"%lu",(unsigned long)size];
    paraModel.orderByType = orderByType;
    paraModel.parentPath = parentPath;
    paraModel.projectId = self.projectId;
    
    NXProjectFileListOperation *fileMetaDataOpera = [[NXProjectFileListOperation alloc] initWithParmeterModel:paraModel];
    
    fileMetaDataOpera.ProjectFileListCompletion = ^(NSArray *fileItems,NXProjectFileListParameterModel*parmeterMD,NSError *error){
        
        NXProjectFolder *folder = [[NXProjectFolder alloc] init];
        
        folder.localPath = parentPath;
        folder.fullServicePath = parentPath;
        
        completion([self getProjectModel],folder,fileItems,error);
    };
    return fileMetaDataOpera;
}
- (NSOperation *)getFileListParentPath:(NSString *)parentPath filterType:(NXProjectFileListFilterByType)filterByType orderBy:(NXProjectFileListOrderByType)orderByType withCompletion:(getFileListCompletion)completion {
    NXProjectFileListParameterModel *paraModel = [[NXProjectFileListParameterModel alloc] init];
       paraModel.filterType = filterByType;
       paraModel.orderByType = orderByType;
       paraModel.parentPath = parentPath;
       paraModel.projectId = self.projectId;
       
       NXProjectFileListOperation *fileListOpera = [[NXProjectFileListOperation alloc] initWithParmeterModel:paraModel];
       
       fileListOpera.ProjectFileListCompletion = ^(NSArray *fileItems,NXProjectFileListParameterModel*parmeterMD,NSError *error){
           
           NXProjectFolder *folder = [[NXProjectFolder alloc] init];
           
           folder.localPath = parentPath;
           
           completion([self getProjectModel],folder,fileItems,error);
       };
       return fileListOpera;
    
}
- (NSOperation *)getRecentFileListByPage:(NSUInteger)page size:(NSUInteger)size withCompletion:(getRecentFileCompletion)completion {
    NXProjectFileListParameterModel *paraModel = [[NXProjectFileListParameterModel alloc] init];
    
    paraModel.page = [NSString stringWithFormat:@"%lu",(unsigned long)page];
    paraModel.size = [NSString stringWithFormat:@"%lu",(unsigned long)size];
    paraModel.projectId = self.projectId;
    
    NXProjectRecentFilesOperation *fileMetaDataOpera = [[NXProjectRecentFilesOperation alloc] initWithParmeterModel:paraModel];
    fileMetaDataOpera.ProjectFileListCompletion = ^(NSArray *fileItems,NSDictionary *spaceDict, NXProjectFileListParameterModel *parmeterMD, NSError *error) {
        completion([self getProjectModel],fileItems,spaceDict,error);
    };
    
    return fileMetaDataOpera;

}
- (NSOperation *)getProjectMetaDataWithCompletion:(projectMetaDataCompletion)completion
{
    NXProjectMetaDataOperation *opt = [[NXProjectMetaDataOperation alloc] initWithProjectModelId:self.projectId];
    opt.ProjectMetaDataCompletion = ^(NXProjectModel *projectItem,NSNumber *projectId,NSError *error){
        if (!error) {
            _projectName = [projectItem.name copy];
            _parentTenantName = [projectItem.parentTenantName copy];
            _projectDescription = [projectItem.projectDescription copy];
            _invitationMsg = [projectItem.invitationMsg copy];
            _creationTime = projectItem.createdTime;
            _displayName = projectItem.displayName;
            _totalMembers = projectItem.totalMembers;
            _totalFiles = projectItem.totalFiles;
            _isCreatedByMe = projectItem.isOwnedByMe;
            _owner = [projectItem.projectOwner copy];
            NXProjectModel *projectModel = [self getProjectModel];
            // update storage
            [NXProjectStorage insertProjectModel:projectModel];
        }
        completion(projectItem, error);
    };
    return opt;
}

- (NSOperation *)getProjectClassificationsWithCompletion:(getProjectClassificationsCompletion)completion {
    if (self.projectClassifications.count) {
        completion([self.projectClassifications copy], nil);
        return nil;
    }
    BOOL firstCall = NO;
    if (self.queryProjectClassificationsCallBackBlocks.count == 0) {
        firstCall = YES;
    }
    [self.queryProjectClassificationsCallBackBlocks addObject:completion];
    if (firstCall) {
        self.getClassificationOpt = [[NXProjectGetClassificationProfileOperation alloc] initWithProject:[self getProjectModel]];
        WeakObj(self);
        self.getClassificationOpt.optCompletion = ^(NSArray<NXClassificationCategory *> *classifications, NSError *error) {
            StrongObj(self);
            if (self) {
                for (getProjectClassificationsCompletion getCompletion in self.queryProjectClassificationsCallBackBlocks) {
                    getCompletion(classifications, error);
                }
                [self.queryProjectClassificationsCallBackBlocks removeAllObjects];
                if (error == nil && classifications != nil && self.projectState == NXProjectStateActive) {
                    self.projectClassifications = [NSMutableArray arrayWithArray:classifications];
                }
                self.getClassificationOpt = nil;
            }
        };
        return self.getClassificationOpt;
    }
    return nil;
    
}

-(NSOperation*)getSharedWithProjectFileListWithCompletion:(getSharedWithProjectFileListCompletion)completion {
    NXSharedWithProjectFileListOperation *opt = [[NXSharedWithProjectFileListOperation alloc] initWithProjectModel:[self getProjectModel]];
    opt.sharedWithProjectFileListCompletion = ^(NXProjectModel * _Nonnull project, NSArray * _Nonnull fileListArray, NSError * _Nonnull error) {
        completion(project, fileListArray, error);
    };
    return opt;
}

#pragma -mark DELETE METHOD

- (void)removeMember:(NXProjectMemberModel *)member withCompletion:(removeMemberCompletion)completion
{
    WeakObj(self);
    [self.memberSync removeProjectMember:member completion:^(NSError *error) {
        StrongObj(self);
        if (!error) {
            NXProjectMemberModel *toDel = nil;
            for (NXProjectMemberModel *item in self.homeShowMembers) {
                if(item.userId.integerValue == member.userId.integerValue){
                    toDel = item;
                    break;
                }
            }
            if (toDel) {
                [self.homeShowMembers removeObject:toDel];
            }
        }
        completion(error);
    }];
}

- (NSOperation *)deleteFileItem:(NXFileBase *)file withCompletion:(deleteProjectFileItemCompletion)completion
{
//    __weak typeof(self) weakSelf = self;
    
    NXProjectDeleteFileOperation *deleteFileOpera = [[NXProjectDeleteFileOperation alloc] initWithProjectModel:[self getProjectModel] filePath:file.fullServicePath];
    WeakObj(self);
    deleteFileOpera.deletProjectFileCompletion = ^(NXProjectFile *deletedfile,NSError *error){
        if (!error){
            StrongObj(self);
            if (self) {
                self.totalFiles--;
            }
        }
        
        completion(deletedfile, error);
    };
    return deleteFileOpera;
}

#pragma -mark UPDATE METHOD
- (NSOperation *)getListPendingWithPage:(NSUInteger)page size:(NSUInteger)size orderBy:(ListPendingOrderByType)orderByType Completion:(getListMemberCompletion)completion {
    NXProjectListPendingOperation *memberListOpera = [[NXProjectListPendingOperation alloc] initWithProjectModel:[self getProjectModel] page:page size:size orderBy:orderByType];
    
//    NXProjectModel *projectModel = [self getProjectModel];
    memberListOpera.projecListPendingCompletion = ^(NXProjectModel *projectModel,NSMutableArray *pendingArray,NSError *error){
        
        completion(projectModel,pendingArray, error);
    };
    
    return memberListOpera;
}
- (void)inviteMember:(NSArray *)members invitationMsg:(NSString *)invitationMsg  withCompletion:(inviteMemberCompletion)completion
{
    [self.pendingMemberSync inviteMemebers:members invitationMsg:invitationMsg withCompletion:^(NXProjectModel *project, NSDictionary *resultDic, NSError *error) {
        completion(resultDic, error);
    }];
}

- (NSOperation *)uploadFile:(NXProjectUploadFileParameterModel *)upFileParModel underFolder:(NXProjectFolder *)folder progress:(NSProgress *)uploadProgress withCompletion:(uploadFileCompletion)completion
{
    NXProjectUploadFileOperation *uploadFileOpera = [[NXProjectUploadFileOperation alloc] initWithParmeterModel:upFileParModel];
    WeakObj(self);
    uploadFileOpera.projectUploadFileCompletion = ^(NXProjectFile *fileItem,NXProjectUploadFileParameterModel*parmeterMD,NSError *error){
        StrongObj(self);
        if (self) {
            self.totalFiles++;
        }
        completion(fileItem,error);
    };
    uploadFileOpera.uploadProgress = uploadProgress;
    return uploadFileOpera;
}

- (NSOperation *)createFolder:(NXProjectFolder *)newFolder autoRename:(NSString *)autoRename underFolder:(NXProjectFolder *)folder withCompletion:(createProjectFolderCompletion)completion
{

    NXProjectCreateFolderOperation *createFolderOpera = [[NXProjectCreateFolderOperation alloc]initWithProjectModel:[self getProjectModel] parentPathId:folder.fullServicePath withNewFolderName:newFolder.name autoRename:autoRename];
    
    createFolderOpera.projectCreateFolderCompletion = ^(NXProjectFolder *createdFolder,NSError *error){
        
        NXProjectFolder *folder = createdFolder;
        completion(folder,error);
    };
    return createFolderOpera;
}

#pragma -mark QUERY METHOD

-(NSOperation *)searchFileWithQueryKeyword:(NSString *)queryKeyword withCompletion:(searchFileCompletion)completion
{
    NXProjectSearchOpearation *searchOpera = [[NXProjectSearchOpearation alloc] initWithProjectModel:[self getProjectModel] queryKeyword:queryKeyword];
    
    searchOpera.projectSearchCompletion = ^(NSArray *matchesFileList,NSError *error){
        
        completion(matchesFileList,error);
    };
    return searchOpera;
}

- (NXFileBase *)queryParentFolderForFolder:(NXProjectFolder *)projectFolder {
    return [NXProjectStorage queryParentFolderForProjectFolder:projectFolder fromProject:[self getProjectModel]];
}

#pragma -mark RECLASSIFY FILE MERHOD
-(NSOperation *)reClassifyFile:(NXProjectFile *)fileItem withNewTags:(NSDictionary *)tags withCompletion:(reClassifyFileCompletion)completion {
    NXProjectUploadFileParameterModel *fileParameterModel = [[NXProjectUploadFileParameterModel alloc]init];
    fileParameterModel.fileName = fileItem.name;
    fileParameterModel.destFilePathId = fileItem.parentPath;
    fileParameterModel.projectId = fileItem.projectId;
    fileParameterModel.duid = fileItem.duid;
    fileParameterModel.tags = tags;
    NXProjectReclassifyFileOperation *reClassifyFileOpera = [[NXProjectReclassifyFileOperation alloc] initWithParmeterModel:fileParameterModel];
    reClassifyFileOpera.projectReclassifyFileCompletion = ^(NXProjectFile *fileItem, NXProjectUploadFileParameterModel *parmeterMD, NSError *error) {
        completion(fileItem,error);
    };
    return reClassifyFileOpera;
}
#pragma mark - NXProjectMemberSyncDelegate
- (void)projectMemberSyncDidUpdateMembers:(NSArray *)members
{
    NSSet *oldMembersSet = [NSSet setWithArray:self.members];
    NSSet *newMembersSet = [NSSet setWithArray:members];

    if(![oldMembersSet isEqualToSet:newMembersSet]){
        self.members = [[NSMutableArray alloc] initWithArray:members];
    }
    dispatch_main_async_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
    });
    
}

#pragma mark - NXProjectPendingMemberSyncDelegate
- (void)projectPendingMembersSyncDidUpdatePendingMembers:(NSArray *)pendingMembers
{
    NSSet *oldPendingMembersSet = [NSSet setWithArray:self.pendingMembers];
    NSSet *newPendingMembersSet = [NSSet setWithArray:pendingMembers];
    if (![oldPendingMembersSet isEqualToSet:newPendingMembersSet]) {
         self.pendingMembers = [[NSMutableArray alloc] initWithArray:pendingMembers];
    }
    dispatch_main_async_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
    });
}

@end
