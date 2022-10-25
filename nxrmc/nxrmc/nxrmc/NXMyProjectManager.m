//
//  NXMyProjectManager.m
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMyProjectManager.h"
#import "NXProject.h"
#import "NXProjectListOperation.h"
#import "NXAllProjectListOperation.h"
#import "NXProjectCreateOperation.h"
#import "NXProjectUpateOperation.h"
#import "NXSharedWithProjectFileMetadataOperation.h"
#import "NXRMCDef.h"
#import "NXLProfile.h"
#import "NXProjectMemberModel.h"
#import "NXProjectListPendingOperation.h"
#import "NXProjectUploadFileParameterModel.h"
#import "NXProjectListAPI.h"
#import "NXProjectListMembersAPI.h"
#import "NXProjectGetListPendingInvitationsAPI.h"
#import "NXProjectInvitationHelper.h"
#import "NXProjectInfoSync.h"
#import "NXNetworkHelper.h"
#import "NXAcceptProjectInvitationAPI.h"
#import "NXDeclineProjectInvitationAPI.h"
#import "NXProjectMetaDataOperation.h"
#import "NXPendingProjectInvitationSync.h"
#import "NXProjectMemberSync.h"
#import "NXProjectPendingMemberSync.h"
#import "NXProjectStorage.h"
#import "NXSharedWithProjectFileStorage.h"
#import "NXLFileValidateDateModel.h"
@interface NXMyProjectManager()<NXProjectInfoSyncDelegate, NXProjectInvitationHelperDelegate>
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, strong) NXProjectInvitationHelper *projectInvitationHelper;
@property(nonatomic, strong) NSMutableDictionary *projectOptDict;
@property(nonatomic, strong) NSMutableDictionary *completeBlockDict;
@property(nonatomic, strong) NSMutableDictionary *myProjectDict;
@property(nonatomic, strong) NSMutableDictionary *allProjectDict;
@property(nonatomic, weak) id<NXFileChooseFlowDataSorceDelegate> fileChooseDataSorceDelegate;
@property(nonatomic, strong) NXProjectInfoSync *projectInfoSync;
@property(nonatomic, strong) NXPendingProjectInvitationSync *pendingInvitationSync;
@end

@implementation NXMyProjectManager
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile
{
    self = [super init];
    if (self) {
         _userProfile = userProfile;
}
    return self;
   
}

- (void)bootup
{
    _allProjectDict = [NSMutableDictionary dictionary];
    _projectOptDict = [[NSMutableDictionary alloc] init];
    _completeBlockDict = [[NSMutableDictionary alloc] init];
    _myProjectDict = nil;
//    _projectInvitationHelper = [[NXProjectInvitationHelper alloc] initWithUserProfile:self.userProfile];
//    _projectInvitationHelper.delegate = self;
//    [_projectInvitationHelper bootUp];
//
    [self allProjectsWithCompletion:^(NSArray *projects, NSError *error) {
        
    }];
    _projectInfoSync = [[NXProjectInfoSync alloc] init];
    _projectInfoSync.delegate = self;
    [_projectInfoSync getMyProjectWithCompletion:^(NSArray *projectsArray, NSError *error) {
        if (projectsArray) {
            _myProjectDict = [NSMutableDictionary dictionary];
            for (NXProjectModel *model in projectsArray) {
                   NXProject *project = [[NXProject alloc]initWithProjectModel:model];
                   [_myProjectDict setObject:project forKey:model.projectId];
            }
        }
    }];
    
    _pendingInvitationSync = [[NXPendingProjectInvitationSync alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectUserKicked:) name:NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pendingProjectInvitationDidChanged:) name:NOTIFICATION_PROJECT_PENDING_INVITATION_CHANGED object:nil];

}

- (void)projectUserKicked:(NSNotification *)notification
{
    NSArray *projectIds = notification.userInfo[@"projectId"];
    for (NSNumber *Id in projectIds) {
        NXProject *project = self.myProjectDict[Id];
        if (project) {
            [project inactiveProject];
            [self.myProjectDict removeObjectForKey:Id];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_YOU_ARE_KICKED_OUTSIDE object:nil userInfo:@{@"projectId":projectIds}];
}

- (void)pendingProjectInvitationDidChanged:(NSNotification *)notification{
    dispatch_main_async_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
    });
}

- (void)dealloc
{
    DLog();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)shutDown
{
//    [_projectInvitationHelper shutDown];
//    _projectInvitationHelper = nil;
    
    [_projectInfoSync destroy];
    _projectInfoSync = nil;
    
    [_pendingInvitationSync stopSync];
    _pendingInvitationSync = nil;
    
    for (NSOperation *opt in self.projectOptDict.allValues) {
        [opt cancel];
    }
    
    self.projectOptDict = nil;
    self.completeBlockDict = nil;
    self.myProjectDict = nil;
}

- (NSMutableDictionary *)myProjectDict
{
    @synchronized (self) {
        return _myProjectDict;
    }
}

- (NSString *)allMyProjectsContainAllMemberWithCompletion:(queryAllMyProjectContainMembersCompletion)completion {
    NSError *error = nil;
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)}];
    }
    NSMutableArray *projectsByMe = nil;
    NSMutableArray *projectsByOther = nil;
 
    if (_myProjectDict) {
        projectsByMe = [NSMutableArray array];
        projectsByOther = [NSMutableArray array];
        for (NXPendingProjectInvitationModel * model in [self.pendingInvitationSync allPendingInvitations]) {
            [projectsByOther addObject:model];
        }
        for (NXProject *project in self.myProjectDict.allValues) {
            NXProjectModel *projectModel = [project getProjectModel];
            if (projectModel.isOwnedByMe) {
                [projectsByMe addObject:projectModel];
            }else {
                [projectsByOther addObject:projectModel];
            }
        }
    }
    completion(projectsByMe,projectsByOther,0,error);
    return nil;
    
}
- (NSString *)allMyProjectsWithCompletion:(queryAllMyProjectCompletion)completion
{
    NSError *error = nil;
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)}];
    }
    NSMutableArray *projectsByMe = nil;
    NSMutableArray *projectsByOther = nil;
    NSMutableArray *ProjectByPending = nil;
    
    if (_myProjectDict) {
        projectsByMe = [NSMutableArray array];
        projectsByOther = [NSMutableArray array];
        ProjectByPending = [NSMutableArray array];
        for (NXPendingProjectInvitationModel * model in [self.pendingInvitationSync allPendingInvitations]) {
            [ProjectByPending addObject:model];
        }
        for (NXProject *project in self.myProjectDict.allValues) {
            NXProjectModel *projectModel = [project getProjectModel];
            if (projectModel.isOwnedByMe) {
                [projectsByMe addObject:projectModel];
            }else {
                [projectsByOther addObject:projectModel];
            }
            
        }
    }
    completion(projectsByMe,projectsByOther,ProjectByPending,error);
    return nil;
}

- (NSString *)project:(NXProjectModel *)projectModel MetadataWithCompletion:(queryProjectMetadataCompletion)completion
{
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    NSOperation *opt = [project getProjectMetaDataWithCompletion:^(NXProjectModel *projectItem, NSError *error) {
        completion(projectItem, error);
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
    }];
    
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:opt forKey:optIdentify];
    
    [opt start];
    return optIdentify;
}


- (NSString *)createProject:(NXProjectModel *)projectModel invitedEmails:(NSArray *)emails invitationMsg:(NSString *)invitationMsg withCompletion:(creatProjectCompletion)completion
{
    BOOL isDisplayNameContainMultiByteStr = [NXCommonUtils checkStringContainMultiByte:projectModel.displayName];
    BOOL isDescriptionContainMultiByteStr = [NXCommonUtils checkStringContainMultiByte:projectModel.projectDescription];
    if(isDisplayNameContainMultiByteStr || isDescriptionContainMultiByteStr) {
        NSDictionary *errorInfo = isDisplayNameContainMultiByteStr ? @{NSLocalizedDescriptionKey:NSLocalizedString(@"UI_COM_NAME_CONTAIN_SPECIAL_WARNING", NULL)} : @{NSLocalizedDescriptionKey:NSLocalizedString(@"UI_COM_DESCRIPTION_CONTAIN_SPECIAL_WARNING", NULL)};
        NSError *error = [NSError errorWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_INVALIDE_PROJECT_NAME userInfo:errorInfo];
        completion(projectModel, error);
        return nil;
    }
    
    NXProjectCreateParmetersMD *createProjectMD = [[NXProjectCreateParmetersMD alloc] init];
    createProjectMD.projectName =  projectModel.displayName;
    createProjectMD.projectDescription = projectModel.projectDescription;
    createProjectMD.userEmails = emails;
    createProjectMD.invitationMsg = invitationMsg;
    [self.projectInfoSync createProject:createProjectMD withCompletion:^(NXProjectModel *project, NSError *error) {
        if (error == nil) {
            // add new membership into login user info
            NXLMembership *newMembershipo = [[NXLMembership alloc] init];
            newMembershipo.projectId = [project.projectId copy];
            newMembershipo.tenantId = [projectModel.parentTenantId copy];
            newMembershipo.type = @0;
            newMembershipo.ID = [project.membershipId copy];
            
            [[NXLoginUser sharedInstance].profile.memberships addObject:newMembershipo];
            [NXCommonUtils storeProfile:[NXLoginUser sharedInstance].profile];
        }
        completion(project, error);
    }];
    return nil;
}
- (NSString *)updateProject:(NXProjectModel *)projectModel withCompletion:(updateProjectCompletion)completion {
    NXProjectUpdateParmetersMD *updateProjectMD = [[NXProjectUpdateParmetersMD alloc]init];
    updateProjectMD.projectName = projectModel.name;
    updateProjectMD.projectDescription = projectModel.projectDescription;
    updateProjectMD.invitationMsg = projectModel.invitationMsg;
    updateProjectMD.projectId = projectModel.projectId;
    [self.projectInfoSync updateProject:projectModel withParmetersMD:updateProjectMD withCompletion:^(NXProjectModel *project, NSError *error) {
        completion(project, error);
        }];
    return nil;
}
- (void)allMemebersInProject:(NXProjectModel *)projectModel withCompletion:(queryAllMemebersInProjectCompletion)completion
{
    if (projectModel == nil) {
        return;
    }
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return;
    }
    
    completion(projectModel, [project.members copy], nil);
}
- (void)inviteMember:(NSArray *)memberArray invitationMsg:(NSString *)invitationMsg  inProject:(NXProjectModel *)projectModel withCompletion:(inviteMemberInProjectCompletion)completion
{
    if (projectModel == nil) {
        return;
    }
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSError *invalidError = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_NOT_EXISTED userInfo:@{NSLocalizedDescriptionKey:@"Invalid project"}];
        completion(nil,nil,invalidError);
//        NSAssert(NO, @"Can not be!!!");
        return;
    }
    [project inviteMember:memberArray invitationMsg:invitationMsg withCompletion:^(NSDictionary *resultDic, NSError *error) {
        completion(projectModel, resultDic, error);
        if (!error) {
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
            });
        }
        
    }];
    
   
}
- (void)getAllMembersContainPendingsInProject:(NXProjectModel *)projectModel withCompletion:(queryAllMemebersContainPendingInProjectCompletion)completion {
    if (projectModel == nil) {
        return ;
    }
  __block  NSMutableArray *membersArray = [NSMutableArray array];
  __block  NSMutableArray *pendingsArray = [NSMutableArray array];
    NXProjectListMembersAPIRequest * memberRequest =[[NXProjectListMembersAPIRequest alloc]init];
    NSDictionary *paraDic = @{@"projectId":projectModel.projectId,@"page":@(1),@"size":@(1000),@"orderBy":[NSNumber numberWithUnsignedInteger:ListMemberOrderByTypeCreateTimeDescending],@"picture":[NSNumber numberWithBool:YES]};
    [memberRequest requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXProjectListMembersAPIResponse *lastResponse = (NXProjectListMembersAPIResponse*)response;
        NSMutableArray *memberArray = lastResponse.membersItems;
        membersArray = memberArray;
        if (membersArray) {
            NXProjectMemberModel *owner = nil;
            for (NXProjectMemberModel *memeber in membersArray) {
                if ([memeber.userId isEqual:projectModel.projectOwner.userId]) {
                    owner = memeber;
                    break;
                }
            }
            if (owner) {
                [membersArray removeObject:owner];
                owner.isProjectOwner = YES;
                [membersArray insertObject:owner atIndex:0];
            }
            
            NXProject *project = self.myProjectDict[projectModel.projectId];
            if (project) {
                project.members = membersArray;
                project.totalMembers = lastResponse.totalMembers.integerValue;
            }
        }

        NXProjectGetListPendingInvitationsAPIRequest *pendingRequest = [[NXProjectGetListPendingInvitationsAPIRequest alloc]init];
        NSDictionary *paraDic = @{@"projectId":projectModel.projectId,@"page":@(1),@"size":@(1000),@"orderBy":[NSNumber numberWithUnsignedInteger:ListPendingOrderByTypeCreateTimeDescending],@"searchString":@""};
        [pendingRequest requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            NXProjectGetListPendingInvitationsAPIResponse *lastResponse = (NXProjectGetListPendingInvitationsAPIResponse *)response;
            NSMutableArray *pendingArray = lastResponse.pendingArray;
            pendingsArray = pendingArray;
            if (!error && lastResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NXProject *project = self.myProjectDict[projectModel.projectId];
                if(project){
                    project.pendingMembers = pendingArray;
                }
            }
            if (completion) {
                completion(projectModel,membersArray,pendingsArray,nil);
            }
        }];
    }];
}

- (void)getAllMembersContainPendingsInProject:(NXProjectModel *)projectModel isReadCache:(BOOL)isReadCache withCompletion:(queryAllMemebersContainPendingInProjectCompletion)completion {
    if (projectModel == nil) {
        return ;
    }
    if (isReadCache) {
        NSArray *memberArray = [NXProjectMemberSync getMemberListFromStorageOfProject:projectModel];
        NSArray *pendingMemberArray = [NXProjectPendingMemberSync currentPendingMembersFromStorageOfProject:projectModel];
        if (completion) {
            completion(projectModel,memberArray,pendingMemberArray,nil);
        }
        
    } else {
        __block  NSMutableArray *membersArray = [NSMutableArray array];
        __block  NSMutableArray *pendingsArray = [NSMutableArray array];
        NXProjectListMembersAPIRequest * memberRequest =[[NXProjectListMembersAPIRequest alloc]init];
        NSDictionary *paraDic = @{@"projectId":projectModel.projectId,@"page":@(1),@"size":@(1000),@"orderBy":[NSNumber numberWithUnsignedInteger:ListMemberOrderByTypeCreateTimeDescending],@"picture":[NSNumber numberWithBool:YES]};
        [memberRequest requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            if (!error) {
                NXProjectListMembersAPIResponse *lastResponse = (NXProjectListMembersAPIResponse*)response;
                NSMutableArray *memberArray = lastResponse.membersItems;
                membersArray = memberArray;
                if (membersArray) {
                    NXProjectMemberModel *owner = nil;
                    for (NXProjectMemberModel *memeber in membersArray) {
                        if ([memeber.userId isEqual:projectModel.projectOwner.userId]) {
                            owner = memeber;
                            break;
                        }
                    }
                    if (owner) {
                        [membersArray removeObject:owner];
                        owner.isProjectOwner = YES;
                        [membersArray insertObject:owner atIndex:0];
                    }
                    
                    NXProject *project = self.myProjectDict[projectModel.projectId];
                    if (project) {
                        project.members = membersArray;
                        project.totalMembers = lastResponse.totalMembers.integerValue;
                    }
                }
                
                NXProjectGetListPendingInvitationsAPIRequest *pendingRequest = [[NXProjectGetListPendingInvitationsAPIRequest alloc]init];
                NSDictionary *paraDic = @{@"projectId":projectModel.projectId,@"page":@(1),@"size":@(1000),@"orderBy":[NSNumber numberWithUnsignedInteger:ListPendingOrderByTypeCreateTimeDescending],@"searchString":@""};
                [pendingRequest requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                    NXProjectGetListPendingInvitationsAPIResponse *lastResponse = (NXProjectGetListPendingInvitationsAPIResponse *)response;
                    NSMutableArray *pendingArray = lastResponse.pendingArray;
                    pendingsArray = pendingArray;
                    if (!error && lastResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                        NXProject *project = self.myProjectDict[projectModel.projectId];
                        if(project){
                            project.pendingMembers = pendingArray;
                        }
                    }
                    [NXProjectMemberSync syncFromRMSMemebers:memberArray toProject:projectModel];
                    [NXProjectPendingMemberSync syncFromRMSPendingMemebers:pendingArray toProject:projectModel];
                    if (completion) {
                        completion(projectModel,memberArray,pendingArray,nil);
                    }
                }];

            } else {
                if (completion) {
                    completion(projectModel,nil,nil,error);
                }
            }
               }];
    }
}




- (void)removeProjectMember:(NXProjectMemberModel *)memberModel withCompletion:(removeMemberFromProjectCompletion)completion
{
    if (memberModel == nil) {
        return;
    }
    NXProject *project = self.myProjectDict[memberModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return;
    }

    [project removeMember:memberModel withCompletion:^(NSError *error) {
        completion(error);
    }];
}

- (NSString *)projectModelByProjectId:(NSNumber *)projectId withCompletion:(getProjectModelByIdCompletion)completion
{
    if (projectId) {
        NXProject *project = self.myProjectDict[projectId];
        if (project && project.membershipId!=nil) {
            completion([project getProjectModel], nil);
            return nil;
        }else{
            NXProjectMetaDataOperation *opt = [[NXProjectMetaDataOperation alloc] initWithProjectModelId:projectId];
            NSString *optId = [[NSUUID UUID] UUIDString];
            WeakObj(self);
            opt.ProjectMetaDataCompletion = ^(NXProjectModel *projectItem,NSNumber *projectId,NSError *error){
                StrongObj(self);
                if (self) {
                    getProjectModelByIdCompletion optCallBack = self.completeBlockDict[optId];
                    [self.completeBlockDict removeObjectForKey:optId];
                    [self.projectOptDict removeObjectForKey:optId];
                    if (projectItem && error == nil) {
                        NXProject *project = [[NXProject alloc] initWithProjectModel:projectItem];
                        [self.myProjectDict setObject:project forKey:projectId];
                    }
                    if (optCallBack) {
                        optCallBack(projectItem, error);
                    }
                }
            };
            [self.projectOptDict setObject:opt forKey:optId];
            [self.completeBlockDict setObject:completion forKey:optId];
            [opt start];
            return optId;
        }
    }
    return nil;
}
- (NSString *)allProjectsWithCompletion:(queryAllProjectCompletion)completion {
    NXAllProjectListOperation *opt = [[NXAllProjectListOperation alloc] init];
               NSString *optId = [[NSUUID UUID] UUIDString];
               WeakObj(self);
    opt.getProjectListCompletion = ^(NSArray * _Nonnull projectList, NSError * _Nonnull error) {
        queryAllProjectCompletion optCallBack = self.completeBlockDict[optId];
        if (optCallBack) {
            optCallBack(projectList,error);
        }
        if (!error) {
            StrongObj(self);
            [self.completeBlockDict removeObjectForKey:optId];
            [self.projectOptDict removeObjectForKey:optId];
            for (NXProjectModel *model in projectList) {
                [self.allProjectDict setObject:model forKey:model.projectId];
            }
        }
    };
              
    [self.projectOptDict setObject:opt forKey:optId];
    [self.completeBlockDict setObject:completion forKey:optId];
    [opt start];
    return optId;
    
}
- (NSArray  *)getAllProjectParentTenantNameArray
{
    NSMutableArray *parentTenenantNameArray = [NSMutableArray new];
    if (self.myProjectDict.allValues.count >0) {
        for (NXProject *project in self.myProjectDict.allValues) {
            if (project.parentTenantName) {
                [parentTenenantNameArray addObject:project.parentTenantName];
            }
        }
    }
    return [parentTenenantNameArray copy];
}

- (NSString *)getFileMetaData:(NXProjectFile *)projectFile withCompletion:(getFileMetaDataCompletion)completion {
    if (projectFile == nil) {
        return nil;
    }
    
    NXProject *project = self.myProjectDict[projectFile.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *getFileMetaDataOpt = [project getFileMetaData:projectFile withCompletion:^(NXProjectFile *file, NSError *error) {
        StrongObj(self);
        getFileMetaDataCompletion comp = self.completeBlockDict[optIdentify];
        comp(file,error);
    }];
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:getFileMetaDataOpt forKey:optIdentify];
    [getFileMetaDataOpt start];
    return optIdentify;
}
- (NSString *)getSharedWithProjectFileMetadata:(id)fileItem withCompletion:(getSharedWithProjectFileMetaDataCompletion)completion {
    if (fileItem == nil) {
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NXSharedWithProjectFileMetadataOperation *getFileMetaDataOpt = [[NXSharedWithProjectFileMetadataOperation alloc] initWithSharedWithProjectFile:fileItem];
    getFileMetaDataOpt.getSharedWithProjectFileMetadataCompletion = ^(NXSharedWithProjectFile * _Nonnull fileItem, NSError * _Nonnull error) {
        StrongObj(self);
        getSharedWithProjectFileMetadataCompletion comp = self.completeBlockDict[optIdentify];
        comp(fileItem,error);
        
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
    };
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:getFileMetaDataOpt forKey:optIdentify];
    [getFileMetaDataOpt start];
    return optIdentify;
}
- (NSString *)getMemberDetails:(NXProjectMemberModel *)memberModel withCompletion:(getMemberDetailsCompletion)completion
{
    if (memberModel == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[memberModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *getMemberDetailsOpt = [project getMemberDetailByMemberId:[memberModel.userId stringValue] withCompletion:^(NXProjectMemberModel *member, NSError *error) {
        StrongObj(self);
        getMemberDetailsCompletion comp = self.completeBlockDict[optIdentify];
        comp(member,error);
        
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
    }];
    
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:getMemberDetailsOpt forKey:optIdentify];
    [getMemberDetailsOpt start];
    return optIdentify;
}

- (NSString *)getMemberShipID:(NXProjectModel *)projectModel  withCompletion:(getMemberShipIDCompletion)completion
{
    if (projectModel == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    
    NSOperation *getMemberShipIDOpt = [project getMembershipIdByProjectModel:projectModel withCompletion:^(NXProjectModel *projectModel, NSError *error) {
        StrongObj(self);
        
        getMemberShipIDCompletion comp = self.completeBlockDict[optIdentify];
        
        if (!error) {
            
            // manually add memebership to user profile
            NXLMembership *newMembership = [[NXLMembership alloc] init];
            newMembership.ID = [projectModel.membershipId copy];
            newMembership.projectId = [projectModel.projectId copy];
            newMembership.tokenGroupName = [projectModel.tokenGroupName copy];
            newMembership.type = [NSNumber numberWithInteger:projectModel.accountType.integerValue];
            [[NXLoginUser sharedInstance].profile.memberships addObject:newMembership];
            [NXCommonUtils storeProfile:[NXLoginUser sharedInstance].profile];
            
            project.membershipId = projectModel.membershipId;
            project.tokenGroupName = projectModel.tokenGroupName;
        }
        
         comp(projectModel,error);
        
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
    }];
    
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:getMemberShipIDOpt forKey:optIdentify];
    [getMemberShipIDOpt start];
    return optIdentify;
}
- (NSString *)reclassifyFileWithParameterModel:(NXProjectFile *)fileItem withNewTags:(NSDictionary *)tags withCompletion:(reClassifyFileCompletion)completion {
    if (fileItem == nil) {
        return nil;
    }
    NXProject *proeject = self.myProjectDict[fileItem.projectId];
    if (!proeject) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *reclassifyOpt = [proeject reClassifyFile:fileItem withNewTags:tags withCompletion:^(NXProjectFile *file, NSError *error) {
        StrongObj(self);
        reClassifyFileCompletion comp = self.completeBlockDict[optIdentify];
        comp(file,error);
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
    }];
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:reclassifyOpt forKey:optIdentify];
    [reclassifyOpt start];
    return optIdentify;
}
- (NSString *)addFile:(NXProjectUploadFileParameterModel *)upFileParModel underParentFolder:(NXProjectFolder *)parentFolder progress:(NSProgress *)uploadProgress withCompletion:(addProjectFileUnderParentFolderCompletion)completion
{
    if (upFileParModel == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[upFileParModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    
    if(upFileParModel.fileData.length > RMS_MAX_UPLOAD_SIZE) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_UPLOAD_TO_MAX userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPLOAD_TO_MAX", nil)}];
        completion(parentFolder, nil, error);
        return nil;
    }
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *addFileOpt=[project uploadFile:upFileParModel underFolder:parentFolder progress:uploadProgress withCompletion:^(NXProjectFile *file, NSError *error) {
          StrongObj(self);
        addProjectFileUnderParentFolderCompletion comp =self.completeBlockDict[optIdentify];
        if (comp) {
              comp(parentFolder,file,error);
        }
        if (!error) {
            [NXProjectStorage insertProjectFile:file toParentFolder:parentFolder.fullServicePath toProjectModel:[project getProjectModel]];
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
            });
        }
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
          }];
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:addFileOpt forKey:optIdentify];
    [addFileOpt start];
    return optIdentify;
}

- (NSArray *)getFileListUnderParentFolderInCoreData:(NXProjectFolder *)parentFolder
{
    if (parentFolder == nil) {
          return nil;
      }
    NXProject *project = self.myProjectDict[parentFolder.projectId];
     if (!project) {
         return nil;
     }
    
    NSArray *cacheFileArray = [NXProjectStorage queryProjectFilesUnderFolder:parentFolder.fullServicePath fromProject:[project getProjectModel]];
    if (cacheFileArray.count > 0) {
        return cacheFileArray;
    }else{
        return nil;
    }
}
- (NSString *)getFileListFromServerUnderParentFolder:(NXProjectFolder *)parentFolder  withCompletion:(getProjectFileListCompletion)completion {
    if (parentFolder == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[parentFolder.projectId];
    if (!project) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_NOT_EXISTED userInfo:nil];
        completion([project getProjectModel], parentFolder, nil, error);
        return nil;
    }
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *getFileListOpt = [project getFileListByPage:0 size:0 orderBy:NXProjectListSortTypeFileNameAscending parentPath:parentFolder.fullServicePath withCompletion:^(NXProjectModel *projectModel, NXProjectFolder *parentFolder, NSArray *fileList, NSError *error) {
        StrongObj(self);
        
        //////////////////////for property "offline" base on local ,not server
       
        // step1. insert coredata
        if (!error) {
            if (completion) {
                completion([project getProjectModel],parentFolder,fileList,error);
            }
            // delete storage exist but server is not exist.
            NSArray *cacheFileArray = [NXProjectStorage queryProjectFilesUnderFolder:parentFolder.fullServicePath fromProject:[project getProjectModel]];
            if (cacheFileArray.count) {
                NSMutableSet *oldFilesSet = [NSMutableSet setWithArray:cacheFileArray];
                NSSet *newFilesSet = [NSSet setWithArray:fileList];
                [oldFilesSet minusSet:newFilesSet];
                for (NXFileBase *fileItem in oldFilesSet) {
                    [NXProjectStorage deleteProjectFile:fileItem fromProjectModel:projectModel];
                }
            }
            [NXProjectStorage insertProjectFiles:fileList toFolder:parentFolder.fullServicePath toProject:projectModel];
            NSArray *newFileList = [NXProjectStorage queryProjectFilesUnderFolder:parentFolder.fullServicePath fromProject:projectModel];
           getProjectFileListCompletion comp = self.completeBlockDict[optIdentify];
           if (comp) {
               comp(projectModel, parentFolder, newFileList, error);
           }
        }

        // step2. read from coredata
//        if ([self.upDateFiledelegate respondsToSelector:@selector(nxMyProjectManager:didGetProjectFiles:underFolder:withSpaceDict:withError:)]) {
//            [self.upDateFiledelegate nxMyProjectManager:self didGetProjectFiles:newFileList underFolder:parentFolder withSpaceDict:nil withError:error];
//        }
       
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
        if(error.code == NXRMC_ERROR_CODE_PROJECT_KICKED){
            [project inactiveProject];
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE object:nil userInfo:@{@"projectId":@[projectModel.projectId]}];
            });
        }
        
    }];
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:getFileListOpt forKey:optIdentify];
    [getFileListOpt start];
    return optIdentify;
    
}
- (NSString *)getFileListUnderParentFolder:(NXProjectFolder *)parentFolder withCompletion:(getProjectFileListCompletion)completion
{
    if (parentFolder == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[parentFolder.projectId];
    if (!project) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_NOT_EXISTED userInfo:nil];
        completion([project getProjectModel], parentFolder, nil, error);
        return nil;
    }
    
    NSArray *cacheFileArray = [NXProjectStorage queryProjectFilesUnderFolder:parentFolder.fullServicePath fromProject:[project getProjectModel]];
    if (cacheFileArray.count) {
        completion([project getProjectModel],parentFolder,cacheFileArray,nil);
    }
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *getFileListOpt = [project getFileListByPage:0 size:0 orderBy:NXProjectListSortTypeFileNameAscending parentPath:parentFolder.fullServicePath withCompletion:^(NXProjectModel *projectModel, NXProjectFolder *parentFolder, NSArray *fileList, NSError *error) {
        StrongObj(self);
        
        //////////////////////for property "offline" base on local ,not server
       
        // step1. insert coredata
        if (!error) {
            // delete storage exist but server is not exist.
            if (cacheFileArray.count) {
                NSMutableSet *oldFilesSet = [NSMutableSet setWithArray:cacheFileArray];
                NSSet *newFilesSet = [NSSet setWithArray:fileList];
                [oldFilesSet minusSet:newFilesSet];
                for (NXFileBase *fileItem in oldFilesSet) {
                    [NXProjectStorage deleteProjectFile:fileItem fromProjectModel:projectModel];
                }
            }
            [NXProjectStorage insertProjectFiles:fileList toFolder:parentFolder.fullServicePath toProject:projectModel];
        }
        
         NSArray *newFileList = [NXProjectStorage queryProjectFilesUnderFolder:parentFolder.fullServicePath fromProject:projectModel];
        
        // step2. read from coredata
        if ([self.upDateFiledelegate respondsToSelector:@selector(nxMyProjectManager:didGetProjectFiles:underFolder:withSpaceDict:withError:)]) {
            [self.upDateFiledelegate nxMyProjectManager:self didGetProjectFiles:newFileList underFolder:parentFolder withSpaceDict:nil withError:error];
        }
        getProjectFileListCompletion comp = self.completeBlockDict[optIdentify];
        if (comp && self.fileChooseDataSorceDelegate != nil) {
            
            comp(projectModel, parentFolder, newFileList, error);
        }
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
        if(error.code == NXRMC_ERROR_CODE_PROJECT_KICKED){
            [project inactiveProject];
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE object:nil userInfo:@{@"projectId":@[projectModel.projectId]}];
            });
        }
        
    }];
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:getFileListOpt forKey:optIdentify];
    [getFileListOpt start];
    return optIdentify;
}

- (NSString *)getFileListRecentFileForProject:(NXProjectModel *)projectModel withCompletion:(getProjectRecentFileListCompletion)completion {
    if (projectModel == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSArray *cacheFileArray = [NXProjectStorage querySummanyProjectFile:projectModel];
    if (cacheFileArray.count) {
        completion(projectModel,cacheFileArray,nil,nil);
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *getRecentFilesOpt = [project getRecentFileListByPage:0 size:10 withCompletion:^(NXProjectModel *project, NSArray *fileList,NSDictionary *spaceDict, NSError *error) {
        StrongObj(self);
        
        getProjectRecentFileListCompletion comp = self.completeBlockDict[optIdentify];
        if (comp) {
            comp(project,fileList,spaceDict,error);
        }
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
        if(error.code == NXRMC_ERROR_CODE_PROJECT_KICKED){
            NXProject *project = self.myProjectDict[projectModel.projectId];
            [project inactiveProject];
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE object:nil userInfo:@{@"projectId":@[projectModel.projectId]}];
            });
        }
        if (!error) {
            for (NXProjectFile *projectFile in fileList) {
                [NXProjectStorage insertProjectFile:projectFile toParentFolder:projectFile.parentPath toProjectModel:projectModel];
            }
        }
    }];
    
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:getRecentFilesOpt forKey:optIdentify];
    [getRecentFilesOpt start];
    return optIdentify;

}
- (NSString *)getShareByProjectFileListForProject:(NXProjectModel *)projectModel withCompletion:(getFilterProjectFileListCompletion)completion {
    if (projectModel == nil) {
           return nil;
       }
       NXProject *project = self.myProjectDict[projectModel.projectId];
       if (!project) {
           NSAssert(NO, @"Can not be!!!");
           return nil;
       }
    NSArray *cacheFileArray = [NXProjectStorage queryAllSharedByProjectFile:projectModel];
       if (cacheFileArray.count) {
           completion(projectModel,cacheFileArray,nil);
       }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *shareByMeOpt = [project getFileListParentPath:@"/" filterType:NXProjectFileListFilterByTypeAllShared orderBy:NXProjectListSortTypeFileNameAscending withCompletion:^(NXProjectModel *project, NXProjectFolder *parentFolder, NSArray *fileList, NSError *error) {
            StrongObj(self);
            getFilterProjectFileListCompletion comp = self.completeBlockDict[optIdentify];
            if (comp) {
                comp(project,fileList,error);
            }
            [self.completeBlockDict removeObjectForKey:optIdentify];
            [self.projectOptDict removeObjectForKey:optIdentify];
        if (!error) {
            for (NXProjectFile *projectFile in fileList) {
                [NXProjectStorage insertProjectFile:projectFile toParentFolder:projectFile.parentPath toProjectModel:projectModel];
            }
        }
    }];

    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:shareByMeOpt forKey:optIdentify];
    [shareByMeOpt start];
    return optIdentify;
}
- (NSString *)getAllRevokedFileListForProject:(NXProjectModel *)projectModel withCompletion:(getFilterProjectFileListCompletion)completion {
    if (projectModel == nil) {
           return nil;
       }
       NXProject *project = self.myProjectDict[projectModel.projectId];
       if (!project) {
           NSAssert(NO, @"Can not be!!!");
           return nil;
       }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
      WeakObj(self);
       NSOperation *revokedOpt = [project getFileListParentPath:@"/" filterType:NXProjectFileListFilterByTypeRevoked orderBy:NXProjectListSortTypeFileNameAscending withCompletion:^(NXProjectModel *project, NXProjectFolder *parentFolder, NSArray *fileList, NSError *error) {
               StrongObj(self);
               getFilterProjectFileListCompletion comp = self.completeBlockDict[optIdentify];
               if (comp) {
                   comp(project,fileList,error);
               }
               [self.completeBlockDict removeObjectForKey:optIdentify];
               [self.projectOptDict removeObjectForKey:optIdentify];
       
       }];

       [self.completeBlockDict setObject:completion forKey:optIdentify];
       [self.projectOptDict setObject:revokedOpt forKey:optIdentify];
       [revokedOpt start];
       return optIdentify;

    
    return optIdentify;
}
- (NSString *)removeFileItem:(NXFileBase *)fileItem withCompletion:(deleteProjectFileItemCompletion)completion
{
    if (fileItem == nil) {
        return nil;
    }
    NXProject *project = nil;
    if ([fileItem isKindOfClass:[NXProjectFile class]]) {
        project = self.myProjectDict[((NXProjectFile *)fileItem).projectId];
    }else if([fileItem isKindOfClass:[NXProjectFolder class]]){
        project = self.myProjectDict[((NXProjectFolder *)fileItem).projectId];
    }
    
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *removeFileItemOpt = [project deleteFileItem:fileItem withCompletion:^(NXFileBase *file, NSError *error) {
        StrongObj(self);
        deleteProjectFileItemCompletion comp = self.completeBlockDict[optIdentify];
        if (comp) {
            comp(file, error);
        }
        if (!error) {
            [NXProjectStorage deleteProjectFile:fileItem fromProjectModel:[project getProjectModel]];
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
            });
        }
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
    }];
    
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:removeFileItemOpt forKey:optIdentify];
    [removeFileItemOpt start];
    return optIdentify;
}

- (NSString *)createProjectFolder:(NSString *)folderName isAutoRename:(BOOL)autoRename underFolder:(NXProjectFolder *)parentFolder withCompletion:(createProjectFolderCompletion)completion
{
    if (parentFolder == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[parentFolder.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NXProjectFolder *projectFolder = [[NXProjectFolder alloc] initWithFileBaseSourceType:NXFileBaseSorceTypeProject];
    projectFolder.fullServicePath = [NSString stringWithFormat:@"%@%@", (parentFolder.isRoot? @"/":parentFolder.fullServicePath), folderName];
    projectFolder.name = folderName;
    projectFolder.projectId = [project.projectId copy];
    NSOperation *createProjectFolderOpt = [project createFolder:projectFolder autoRename:(autoRename? @"true":@"false") underFolder:parentFolder withCompletion:^(NXProjectFolder *folder, NSError *error) {
        StrongObj(self);
        createProjectFolderCompletion comp = self.completeBlockDict[optIdentify];
        if (comp) {
            comp(folder, error);
        }
        if (!error) {
            [NXProjectStorage insertProjectFile:folder toParentFolder:parentFolder.fullServicePath toProjectModel:[project getProjectModel]];
        }
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];

    }];
    
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:createProjectFolderOpt forKey:optIdentify];
    [createProjectFolderOpt start];
    return optIdentify;
}

- (NSString *)createProjectFolderUnderRootFolderWithName:(NSString *)folderName isAutoRename:(BOOL)autoRename withCompletion:(createProjectFolderCompletion)completion
{
    NXProjectFolder *rootFolder = [[NXProjectFolder alloc] initWithFileBaseSourceType:NXFileBaseSorceTypeProject];
    rootFolder.isRoot = YES;
    rootFolder.fullServicePath = @"/";
    rootFolder.fullPath = @"/";
    
    return [self createProjectFolder:folderName isAutoRename:autoRename underFolder:rootFolder withCompletion:completion];
}

- (NSString *)queryFileItemMetaData:(NXProjectFile *)fileItem withCompletion:(queryProjectFileMetaDataCompletion)completion
{
    if (fileItem ==nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[fileItem.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *queryFileMetaDataOpt = [project getFileMetaData:fileItem withCompletion:^(NXProjectFile *file, NSError *error) {
        StrongObj(self);
        queryProjectFileMetaDataCompletion comp = self.completeBlockDict[optIdentify];
        if (comp) {
            comp(file, error);
        }
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [self.projectOptDict removeObjectForKey:optIdentify];
    }];
    if(queryFileMetaDataOpt){
        [self.completeBlockDict setObject:completion forKey:optIdentify];
        [self.projectOptDict setObject:queryFileMetaDataOpt forKey:optIdentify];
        [queryFileMetaDataOpt start];
    }
    return optIdentify;
}

- (void)updateProjectFileInCoreData:(NXProjectFile *)projectFile
{
    [NXProjectStorage updateProjectFileItem:projectFile];
}
- (void)updateSharedWithProjectFileInCoreData:(NXSharedWithProjectFile *)projectFile {
    [NXSharedWithProjectFileStorage updateSharedWithProjectFile:projectFile];
}
#pragma mark - Invitaion
- (void)allPendingProjectInvitainsWithCompletion:(queryAllInvitationsCompletion)completion
{
    completion([[self.pendingInvitationSync allPendingInvitations] copy]);
}

- (NSString *)listPendingInvitationsForProject:(NXProjectModel *)projectModel WithCompletion:(listInvitationsProjectCompletion)competion {
    if (projectModel == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil ;
    }
    
    competion(projectModel, project.pendingMembers, nil);
    return nil;
    
//    NSString *optIdentify = [[NSUUID UUID] UUIDString];
//    WeakObj(self);
//    NSOperation *pendingOpt = [project getListPendingWithPage:1 size:1000 orderBy:ListPendingOrderByTypeCreateTimeAscending Completion:^(NXProjectModel *project, NSArray *membersArray, NSError *error) {
//        StrongObj(self);
//        queryAllPendingInProjectCompletion comp = self.completeBlockDict[optIdentify];
//        if (comp) {
//            comp(projectModel, membersArray, error);
//        }
//        
//        [self.completeBlockDict removeObjectForKey:optIdentify];
//        [self.projectOptDict removeObjectForKey:optIdentify];
//
//    }];
//    [self.completeBlockDict setObject:competion forKey:optIdentify];
//    [self.projectOptDict setObject:pendingOpt forKey:optIdentify];
//    
//    [pendingOpt start];
//    return optIdentify;
}
- (void)acceptProjectInvitation:(NXPendingProjectInvitationModel *)invitation withCompletion:(acceptProjectInvitationCompletion)completion
{
    NXPendingProjectInvitationModel *pendingModel = invitation;
    for (NXPendingProjectInvitationModel * model in [self.pendingInvitationSync allPendingInvitations]) {
        if ([invitation.invitationId isEqualToNumber:model.invitationId] && [invitation.code isEqualToString:model.code]) {
            pendingModel = model;
            break;
        }
    }
    [self.pendingInvitationSync acceptInvitation:pendingModel completion:^(NXPendingProjectInvitationModel *projectInvitation, NSError *error) {
        if(!error){
            projectInvitation.projectInfo.lastActionTime = [[NSDate date] timeIntervalSince1970] * 1000;
            NXProject *newProject = [[NXProject alloc] initWithProjectModel:projectInvitation.projectInfo];
            [self.myProjectDict setObject:newProject forKey:newProject.projectId];
            [self project:projectInvitation.projectInfo MetadataWithCompletion:^(NXProjectModel *projectModel, NSError *error) {
              NXProjectModel *acceptProjectModel = nil;
                if (!error) {
                    acceptProjectModel = [projectModel copy];
                    [self.projectInfoSync insertAcceptProjectModeltoStorage:projectModel];
                    NXProject *newProject1 = [[NXProject alloc] initWithProjectModel:acceptProjectModel];
                    [self.myProjectDict setObject:newProject1 forKey:projectModel.projectId];
                    NXLMembership *newMembership = [[NXLMembership alloc] init];
                    newMembership.ID = [projectModel.membershipId copy];
                    newMembership.projectId = [projectModel.projectId copy];
                    newMembership.tenantId = [projectModel.parentTenantId copy];
                    newMembership.type = @1;
                    newMembership.tokenGroupName = [projectModel.tokenGroupName copy];
                    [[NXLoginUser sharedInstance].profile.memberships addObject:newMembership];
                    [NXCommonUtils storeProfile:[NXLoginUser sharedInstance].profile];
                   
                }else{
                    if (newProject.projectId) {
                        [self.projectInfoSync insertAcceptProjectModeltoStorage:projectInvitation.projectInfo];
                        
                        // manually add memebership to user profile
                        NXLMembership *newMembership = [[NXLMembership alloc] init];
                        newMembership.ID = [newProject.membershipId copy];
                        newMembership.projectId = [newProject.projectId copy];
                        newMembership.tenantId = [newProject.parentTenantId copy];
                        newMembership.type = @1;
                        newMembership.tokenGroupName = [newProject.tokenGroupName copy];
                        [[NXLoginUser sharedInstance].profile.memberships addObject:newMembership];
                        [NXCommonUtils storeProfile:[NXLoginUser sharedInstance].profile];
                        acceptProjectModel = projectInvitation.projectInfo;
                    }
                }
                completion(acceptProjectModel, [[NSDate date] timeIntervalSince1970], error);
                dispatch_main_async_safe(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
                });
            }];
            
           
        }
        
    }];
}

- (void)revokeProjectInvitation:(NXPendingProjectInvitationModel *)pendingModel withComoletion:(revokeProjectInvitionCompletion)completion {
    
    NXProject *project = self.myProjectDict[pendingModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return;
    }
    [project revokePendingInvitation:pendingModel withCompletion:^(NSString *statusCode, NSError *error) {
        completion(statusCode, error);
    }];
}
- (void)resendProjectInvitation:(NXPendingProjectInvitationModel *)pendingModel withComoletion:(resendProjectInvitionCompletion)completion {
    
    NXProject *project = self.myProjectDict[pendingModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return;
    }
    [project resendInvitation:pendingModel withCompletion:^(NSString *statusCode, NSError *error) {
        completion(statusCode, error);
    }];
}

- (void)declineProjectInvitation:(NXPendingProjectInvitationModel *)invitation forReason:(NSString *)declineReason withCompletion:(declineProjectInvitationCompletion)completion;
{
    NXPendingProjectInvitationModel *pendingModel = invitation;
    for (NXPendingProjectInvitationModel * model in [self.pendingInvitationSync allPendingInvitations]) {
        if ([invitation.invitationId isEqualToNumber:model.invitationId] && [invitation.code isEqualToString:model.code]) {
            pendingModel = model;
            break;
        }
    }
    [self.pendingInvitationSync declineInvitaiton:pendingModel forReason:declineReason completion:^(NXPendingProjectInvitationModel *projectInvitation, NSError *error) {
        completion(projectInvitation, [[NSDate date] timeIntervalSince1970], error);
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
        });
    }];

}

- (NSString *)allClassificationsForProject:(NXProjectModel *)projectModel withCompletion:(queryProjectClassificationCompletion)completion; {
    if (projectModel ==nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *queryFileMetaDataOpt =  [project getProjectClassificationsWithCompletion:^(NSArray<NXClassificationCategory *> *projectClassifications, NSError *error) {
        StrongObj(self);
        if (self) {
            completion(projectModel, projectClassifications, error);
            [self.projectOptDict removeObjectForKey:optIdentify];
        }
    }];
    if (queryFileMetaDataOpt) {
        [self.projectOptDict setObject:queryFileMetaDataOpt forKey:optIdentify];
        [queryFileMetaDataOpt start];
    }
    return optIdentify;
}



#pragma mark - Help method
+ (NXProjectFolder *)rootFolderForProject:(NXProjectModel *)projectModel
{
    NXProjectFolder *rootFolder = [[NXProjectFolder alloc] init];
    rootFolder.isRoot = YES;
    rootFolder.fullPath = @"/";
    rootFolder.fullServicePath = @"/";
    rootFolder.projectId = projectModel.projectId;
    rootFolder.sorceType = NXFileBaseSorceTypeProject;
    return rootFolder;
}

- (NXProjectModel *)getProjectModelForFile:(NXProjectFile *)projectFile
{
    if (projectFile == nil) {
        return nil;
    }
    NXProject *project = self.myProjectDict[projectFile.projectId];
    if (!project) {
        NSAssert(NO, @"Can not be!!!");
        return nil;
    }
    return [project getProjectModel];
}

- (NXProjectModel *)getProjectModelForFolder:(NXProjectFolder *)projectFolder {
    if (projectFolder == nil) {
           return nil;
       }
       NXProject *project = self.myProjectDict[projectFolder.projectId];
       if (!project) {
           NSAssert(NO, @"Can not be!!!");
           return nil;
       }
       return [project getProjectModel];
}

- (NXProjectModel *)getProjectModelForProjectId:(NSNumber *)projectId
{
    NXProject *project = self.myProjectDict[projectId];
    if (!project) {
        
        return nil;
    }else{
        return [project getProjectModel];
    }
}

- (NXProjectModel *)getProjectModelFromAllProjectForProjectId:(NSNumber *)projectId {
    NXProjectModel *model = nil;
    if (projectId) {
        model = self.allProjectDict[projectId];
    }
    return model;
    
}
- (void)cancelOperation:(NSString *)operationIdentify
{
    if (operationIdentify == nil) {
        return;
    }
    NSOperation *opt = self.projectOptDict[operationIdentify];
    if (opt) {
        [opt cancel];
    }
}

- (void)startSyncProjectInfo
{
    [self.projectInfoSync startSyncProjectInfoWithRMS];
    [self.pendingInvitationSync startSync];
}
- (void)pauseSyncProjectInfo
{
    [self.projectInfoSync pauseSyncProjectInfoWithRMS];
}

- (void)activeProject:(NXProjectModel *)projectModel atLocalTime:(NSTimeInterval)lastActionTime
{
    NXProject *project = self.myProjectDict[projectModel.projectId];
    [project activeProjectAtLocalTime:lastActionTime];
    
}
- (void)inactiveProject:(NXProjectModel *)projectModel
{
    NXProject *project = self.myProjectDict[projectModel.projectId];
    [project inactiveProject];
}

#pragma mark - NXProjectInvitationHelperDelegate
- (void)projectInvitationHelper:(NXProjectInvitationHelper *)invitationHelper didChangedInvitationArray:(NSArray *)invitations
{
   dispatch_async(dispatch_get_main_queue(), ^{
       [[NSNotificationCenter defaultCenter] postNotificationName:NXPrjectInvitationNotifiy object:self userInfo:@{NXProjectInvitationsKey:invitations}];
   });
}

#pragma mark - NXFileChooseFlowDataSorceDelegate
- (void)fileListUnderFolder:(NXFolder *)parentFolder withCallBackDelegate:(id<NXFileChooseFlowDataSorceDelegate>)delegate
{
    self.fileChooseDataSorceDelegate = delegate;
    WeakObj(self);
    [self getFileListUnderParentFolder:(NXProjectFolder *)parentFolder withCompletion:^(NXProjectModel *project, NXProjectFolder *parentFolder, NSArray *fileList, NSError *error) {
        StrongObj(self);
        if (self && self.fileChooseDataSorceDelegate) {
            if (DELEGATE_HAS_METHOD(self.fileChooseDataSorceDelegate, @selector(fileChooseFlowDidGetFileList:underParentFolder:error:))) {
                [self.fileChooseDataSorceDelegate fileChooseFlowDidGetFileList:fileList underParentFolder:parentFolder error:error];
            }
            self.fileChooseDataSorceDelegate = nil;
        }
    }];
}

- (NXFileBase *)queryParentFolderForFolder:(NXFileBase *)folder {
    NXProject *project = self.myProjectDict[((NXProjectFolder *)folder).projectId];
    return [project queryParentFolderForFolder:(NXProjectFolder *)folder];
}

#pragma mark - NXProjectInfoSyncDelegate
- (void)NXProjectInfoSyncDidUpdateProjectInfo:(NSArray *)projectsArray error:(NSError *)error
{
    if (!error) {
        BOOL firstInit = NO;
        if (_myProjectDict == nil) {
            self.myProjectDict = [[NSMutableDictionary alloc] init];
            firstInit = YES;
        }
        BOOL anyChange = NO;
        NSMutableArray *nowProjects = nil;
        if (projectsArray) {
            nowProjects = [[NSMutableArray alloc] initWithArray:projectsArray];
        }
        
        for (NXProjectModel *projectModel in projectsArray) {
            if (self.myProjectDict[projectModel.projectId]) {
                NXProject *project = self.myProjectDict[projectModel.projectId];
                if (![project.owner.name isEqualToString:projectModel.projectOwner.name]) {
                    project.owner = projectModel.projectOwner;
                    anyChange = YES;
                }
                if (project.totalFiles != projectModel.totalFiles) {
                    project.totalFiles = projectModel.totalFiles;
                    anyChange = YES;
                }
                if (project.totalMembers != projectModel.totalMembers ) {
                    project.totalMembers = projectModel.totalMembers;
                    anyChange = YES;
                }
                if (![project.homeShowMembers isEqual:projectModel.homeShowMembers]) {
                    project.homeShowMembers = projectModel.homeShowMembers;
                    anyChange = YES;
                }
                if (![project.watermark isEqualToString:projectModel.watermark]) {
                    project.watermark = projectModel.watermark;
                    anyChange = YES;
                }
                if (![project.validateModel isEqual:projectModel.validateModel]) {
                    project.validateModel = projectModel.validateModel;
                    anyChange = YES;
                }
                if (project.configurationModified != projectModel.configurationModified) {
                    project.configurationModified = projectModel.configurationModified;
                    anyChange = YES;
                }
            }
        }
    
        
        NSMutableArray *localProjectArray = [[NSMutableArray alloc] init];
        for (NXProject *project in [self.myProjectDict allValues]) {
            NXProjectModel *projectModel = [project getProjectModel];
            [localProjectArray addObject:projectModel];
        }
        
        
        NSMutableSet *localProjectToDelMutableSet = [NSMutableSet setWithArray:localProjectArray];
        NSSet *localProjectSet = [NSSet setWithArray:localProjectArray];
        
        NSMutableSet *localProjectToAddMutableSet = [NSMutableSet setWithArray:nowProjects];
        NSSet *nowProjectSet = [NSMutableSet setWithArray:nowProjects];
        
        [localProjectToDelMutableSet minusSet:nowProjectSet];
        [localProjectToAddMutableSet minusSet:localProjectSet];
        
//        NSMutableArray *toDelProjects = [[NSMutableArray alloc] init];
        NSMutableSet *toUpdateProjects = [NSMutableSet set];
        NSMutableSet *toNowUpdateProjects = [NSMutableSet set];
        
        NSMutableArray *toDelProjectIds = [NSMutableArray array];
        
        for (NXProjectModel *toDel in localProjectToDelMutableSet) {
            for (NXProjectModel *nowProjectModel in nowProjectSet) {
                if ([nowProjectModel.projectId isEqualToNumber:toDel.projectId]) {
                    [toUpdateProjects addObject:toDel];
                }
            }
        }
        
        for (NXProjectModel *isAddModel in localProjectToAddMutableSet) {
            for (NXProjectModel *nowProjectModel in localProjectSet) {
                if ([isAddModel.projectId isEqualToNumber:nowProjectModel.projectId]) {
                    [toNowUpdateProjects addObject:isAddModel];
                }
            }
        }
        [localProjectToDelMutableSet minusSet:toUpdateProjects];
        [localProjectToAddMutableSet minusSet:toNowUpdateProjects];
        for (NXProjectModel *delModel in localProjectToDelMutableSet) {
            NXProject *project = self.myProjectDict[delModel.projectId];
            if (project) {
                [project inactiveProject];
                [self.myProjectDict removeObjectForKey:delModel.projectId];
                anyChange = YES;
                [toDelProjectIds addObject:project.projectId];
            }
            
        }


        for (NXProjectModel *toAdd in localProjectToAddMutableSet) {
            NXProject *project = [[NXProject alloc] initWithProjectModel:toAdd];
            [self.myProjectDict setObject:project forKey:toAdd.projectId];
            anyChange = YES;
        }
        
        for (NXProjectModel *toUpdateModel in toNowUpdateProjects) {
            NXProject *updateProject = self.myProjectDict[toUpdateModel.projectId];
            if (updateProject) {
                updateProject.projectName = toUpdateModel.name;
                updateProject.projectDescription = toUpdateModel.projectDescription;
                updateProject.invitationMsg = toUpdateModel.invitationMsg;
                anyChange = YES;
            }
        }
        
        for(NXProjectModel *projectModel in projectsArray){
            NXProject *project = self.myProjectDict[projectModel.projectId];
            if (project) {
                for (NXProjectMemberModel *member in project.homeShowMembers) {
                    for (NXProjectMemberModel *newMember in projectModel.homeShowMembers) {
                        if ([newMember.userId isEqual:member.userId]) {
                            if (![member.displayName isEqualToString:newMember.displayName]) {
                                member.displayName = newMember.displayName;
                                anyChange = YES;
                            }
                            
                        }
                    }
                }
            }
        }
        
        if (anyChange || firstInit) {
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
            });
        }
        
        if(toDelProjectIds.count){
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE object:nil userInfo:@{@"projectId":toDelProjectIds}];
            });
        }
    }
}


#pragma mark - Shared With to project
- (NSString *)getSharedFileListInProject:(NXProjectModel *)projectModel withCompletion:(getSharedWithProjectFileListFromProjectCompletion)completion {
    NXProject *project = self.myProjectDict[projectModel.projectId];
    if (!project) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_NOT_EXISTED userInfo:nil];
        completion(projectModel, nil, error);
        return nil;
    }
    
    NSArray *cacheFileArray = [NXSharedWithProjectFileStorage querySharedFileListFromProject:projectModel];
    if (cacheFileArray.count) {
        completion(projectModel, cacheFileArray, nil);
    }
    
    NSString *optIdentify = [[NSUUID UUID] UUIDString];
    WeakObj(self);
    NSOperation *opt = [project getSharedWithProjectFileListWithCompletion:^(NXProjectModel *projectModel, NSArray *sharedWithProjectFileList, NSError *error) {
        StrongObj(self);
         
         //////////////////////for property "offline" base on local ,not server
         // step1. update coredata
         if (!error) {
             // delete storage exist but server is not exist.
             if (cacheFileArray.count) {
                 NSMutableSet *oldFilesSet = [NSMutableSet setWithArray:cacheFileArray];
                 NSSet *newFilesSet = [NSSet setWithArray:sharedWithProjectFileList];
                 [oldFilesSet minusSet:newFilesSet];
                 for (NXSharedWithProjectFile *fileItem in oldFilesSet) {
                     [NXSharedWithProjectFileStorage deleteSharedWithProjectFile:fileItem];
                 }
             }
             [NXSharedWithProjectFileStorage insertSharedFiles:sharedWithProjectFileList intoProject:projectModel];
         }
        
        // setep2. re-get from coredata
        NSArray *newFileList = [NXSharedWithProjectFileStorage querySharedFileListFromProject:projectModel];
         
         getSharedWithProjectFileListCompletion comp = self.completeBlockDict[optIdentify];
         if (comp) {
             comp(projectModel, newFileList, error);
         }
         [self.completeBlockDict removeObjectForKey:optIdentify];
         [self.projectOptDict removeObjectForKey:optIdentify];
         if(error.code == NXRMC_ERROR_CODE_PROJECT_KICKED){
             [project inactiveProject];
             dispatch_main_async_safe(^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE object:nil userInfo:@{@"projectId":@[projectModel.projectId]}];
             });
         }
    }];
    
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [self.projectOptDict setObject:opt forKey:optIdentify];
    [opt start];
    return optIdentify;
}
@end
