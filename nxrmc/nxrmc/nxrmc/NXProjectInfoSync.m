//
//  NXProjectInfoSync.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectInfoSync.h"
#import "NXProjectModel.h"
#import "NXProjectsListParameterModel.h"
#import "NXRMCDef.h"
#import "NXProjectListAPI.h"
#import "NXProjectListMembersAPI.h"
#import "NXProjectInvitationHelper.h"
#import "NXProjectListOperation.h"
#import "NXListPendingInvitationOperation.h"

#import "NXProjectListPendingOperation.h"
#import "NXProjectListMembersOperation.h"

#import "NXAcceptProjectInvitationAPI.h"
#import "NXDeclineProjectInvitationAPI.h"
#import "NXCacheManager.h"
#import "NXSyncHelper.h"
#import "NXRevokeProjectInvitationAPI.h"
#import "NXResendProjectInvitationAPI.h"
#import "NXProjectInviteUserAPI.h"
#import "NXProjectRemoveMemberAPI.h"
#import "NXProjectStorage.h"
#import "NXLProfile.h"

typedef NS_ENUM(NSInteger, NXProjectInfoSyncState){
    NXProjectInfoSyncStateReady = 1,
    NXProjectInfoSyncStateRunning,
    NXProjectInfoSyncStatePaused,
    NXProjectInfoSyncStateDestroy,
};

@interface NXProjectInfoSync()
@property(nonatomic, strong) dispatch_queue_t projectInfoSerialQueue;
@property(nonatomic, strong) NSMutableArray *projectArray;
@property(nonatomic, strong) NSTimer *workTimer;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, strong) NXProjectInvitationHelper *projectInvitationHelper;
@property(nonatomic, assign)BOOL shouldExitWorkThread;
@property(nonatomic, strong) NSOperationQueue *workOptQueue;
@property(nonatomic, strong) NSOperationQueue *fetchProjectInfoOptQueue;
@property(nonatomic, strong) NSError *lastError;
@property(nonatomic, assign) NXProjectInfoSyncState workState;
@property(nonatomic, assign) BOOL isWorkTimerFirstStart;
@end
@implementation NXProjectInfoSync
- (instancetype)init
{
    if (self = [super init]) {
        _projectInfoSerialQueue = dispatch_queue_create("com.skydrm.rmcent.NXProjectInfoSync", DISPATCH_QUEUE_SERIAL);
        _projectArray = [NXProjectStorage queryProjectListFromStorageWhichType:NXProjectListTypeByAll];
        _workOptQueue = [[NSOperationQueue alloc] init];
        _fetchProjectInfoOptQueue = [[NSOperationQueue alloc] init];
        _timeStamp = 0;
        _workState = NXProjectInfoSyncStateReady;
        _isWorkTimerFirstStart = YES;
    }
    return self;
}

- (void)dealloc
{
    DLog(@"NXRepoFileFavOfflineSync dealloc");
}

- (NSError *)getLastError
{
    @synchronized (self) {
        return _lastError;
    }
}

#pragma mark - Timer thread
-(NSThread *)workThread
{
    if (_workThread == nil) {
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
    }
    
    return _workThread;
}

-(void)workThreadEntryPoint:(id)__unused object
{
    NSRunLoop* loop = [NSRunLoop currentRunLoop];
    do
    {
        @autoreleasepool
        {
            [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
            if (self.shouldExitWorkThread) {
                break;
            }
            
            [NSThread sleepForTimeInterval:1.0f];
        }
    }while (true);
    NSLog(@"Exit the project info sync runloop");
}

#pragma mark - Sync
-(void)startTimer
{
    if (self.shouldExitWorkThread) {
        return;
    }
    self.lastError = nil;
    [self performSelector:@selector(scheduleSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
}

-(void)scheduleSyncTimer
{
   // NSLog(@"get project list ++++++++++");
    [self.workTimer invalidate];
    if (self.workState == NXProjectInfoSyncStateRunning) {
        self.workTimer = [NSTimer scheduledTimerWithTimeInterval:PROJECT_LIST_SYNC_INTERVAL target:self selector:@selector(syncProjectInfoWithRMS:) userInfo:nil repeats:NO];
        if (_isWorkTimerFirstStart) {
              [self.workTimer fire];
            _isWorkTimerFirstStart = NO;
        }
    }
}

- (void)startSyncProjectInfoWithRMS
{
    if (self.workState != NXProjectInfoSyncStateRunning) {
        self.shouldExitWorkThread = NO;
        [self startTimer];
        self.workState = NXProjectInfoSyncStateRunning;
    }
    
}

- (void)pauseSyncProjectInfoWithRMS
{
    [self.workTimer invalidate];
    self.workState = NXProjectInfoSyncStatePaused;
}

- (void)destroy
{
    self.shouldExitWorkThread = YES;
    
    [self.workTimer invalidate];
    self.workTimer = nil;
    self.workThread = nil;
    
    self.projectInfoSerialQueue = nil;
    self.projectArray = nil;
    self.workOptQueue = nil;
    self.fetchProjectInfoOptQueue = nil;
    self.timeStamp = 0;
    self.workState = NXProjectInfoSyncStateDestroy;
}

- (void)syncProjectInfoWithRMS:(NSTimer *)timer
{
    // step1. record the sync time(In case the async return data is out of date)
    NSTimeInterval syncTimeStamp = [[NSDate date] timeIntervalSince1970];
  
    // step2. get all my project
    WeakObj(self);
    NSMutableArray *projectArray = [[NSMutableArray alloc] init];
    NXProjectsListParameterModel *parameterModel = [[NXProjectsListParameterModel alloc]init];
    NXProjectListOperation *listPorjectOpt = [[NXProjectListOperation alloc]initWithProjectListParameterModel:parameterModel];
    listPorjectOpt.getProjectListCompletion = ^(NSArray *projectList, NSString *kindType, NSError *error){
        if (!error) {
            StrongObj(self);
            if (self) {
                [projectArray addObjectsFromArray:projectList];
            }
        }else{
            self.lastError = error;
        }
    };
    
    // wait get all project(project + pending invitation)
    if (self.timeStamp > syncTimeStamp || self.workState != NXProjectInfoSyncStateRunning ) {
        [self startTimer];
        return;
    }
    [self.workOptQueue addOperations:@[listPorjectOpt] waitUntilFinished:YES];
    if (self.timeStamp > syncTimeStamp || self.workState != NXProjectInfoSyncStateRunning) {
        [self startTimer];
        return;
    }
  
    // step3. OK, now we get all projects
    // THEN update local data
    dispatch_async(self.projectInfoSerialQueue, ^{
        StrongObj(self);
        
        if (self && !self.lastError) {
            self.projectArray = projectArray;
            [NXProjectStorage insertProjectModels:projectArray];
        }
        
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXProjectInfoSyncDidUpdateProjectInfo:error:)) && self.workState == NXProjectInfoSyncStateRunning && self.timeStamp < syncTimeStamp) {
            [self.delegate NXProjectInfoSyncDidUpdateProjectInfo:[self.projectArray mutableCopy] error:[self.lastError copy]];
            self.lastError = nil;
        }
        [self startTimer];
    });
}

#pragma mark - project operation
- (void)createProject:(NXProjectCreateParmetersMD *)projectMD withCompletion:(projectInfoSyncCreateProjectCompletion)completion
{
    self.timeStamp = [[NSDate date] timeIntervalSince1970];
    NXProjectCreateAPIRequest *request = [[NXProjectCreateAPIRequest alloc] init];
    [request requestWithObject:projectMD Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if(error){
            completion(nil, error);
        }else{
            if ([response isKindOfClass:[NXProjectCreateAPIResponse class]] && ((NXProjectCreateAPIResponse *)response).rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NXProjectModel *projectModel = [[NXProjectModel alloc] init];
                projectModel.projectDescription = projectMD.projectDescription;
                projectModel.isOwnedByMe = YES;
                projectModel.name = projectMD.projectName;
                projectModel.displayName = projectMD.projectName;
                NXProjectOwnerItem *owner = [[NXProjectOwnerItem alloc] init];
                owner.userId = [NSNumber numberWithInteger:[NXLoginUser sharedInstance].profile.userId.integerValue];
                owner.name = [[NXLoginUser sharedInstance].profile.userName copy];
                owner.email = [[NXLoginUser sharedInstance].profile.email copy];
                projectModel.projectOwner = owner;
                projectModel.parentTenantId = ((NXProjectCreateAPIResponse *)response).ProjectModel.parentTenantId;
                projectModel.membershipId = ((NXProjectCreateAPIResponse *)response).ProjectModel.membershipId;
                projectModel.projectId = ((NXProjectCreateAPIResponse *)response).ProjectModel.projectId;
                projectModel.createdTime = ((NXProjectCreateAPIResponse *)response).ProjectModel.createdTime;
                NXProjectMemberModel *member =[[NXProjectMemberModel alloc]init];
                member.userId = owner.userId;
                member.displayName = owner.name;
                member.email = owner.email;
                member.joinTime = projectModel.createdTime/1000;
                member.isProjectOwner = YES;
                projectModel.homeShowMembers = @[member].mutableCopy;
                if (self) {
                    if (projectMD.userEmails.count) {
                        // step2. Get pending members
                        NXProjectListPendingOperation *listPendingMembersOpt = [[NXProjectListPendingOperation alloc]initWithProjectModel:projectModel page:1 size:1000 orderBy:ListPendingOrderByTypeCreateTimeAscending];
                        listPendingMembersOpt.projecListPendingCompletion = ^(NXProjectModel *projectModel, NSMutableArray *totalPendings, NSError *error) {
                            if (!error) {
                                [NXProjectStorage insertPendingMembers:totalPendings toProject:projectModel];
                            }
                        };
                        [self.fetchProjectInfoOptQueue addOperations:@[listPendingMembersOpt] waitUntilFinished:YES];
                    }
                    dispatch_async(self.projectInfoSerialQueue, ^{
                        [self.projectArray insertObject:projectModel atIndex:0];
                        if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXProjectInfoSyncDidUpdateProjectInfo:error:))) {
                            [self.delegate NXProjectInfoSyncDidUpdateProjectInfo:[self.projectArray mutableCopy] error:nil];
                        }
                        // step4. call back
                        completion(projectModel, nil);
                        [NXProjectStorage insertProjectModel:projectModel];
                    });
                }
                
            }else if ([response isKindOfClass:[NXProjectCreateAPIResponse class]] && ((NXProjectCreateAPIResponse *)response).rmsStatuCode == NXRMS_ERROR_CODE_UNAUTHENTICATED) {
                NSError *operationError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_OPERATION_UNAUTHORIZED", nil)}];
                completion(nil, operationError);
            }else{
                NSError *operationError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_OPERATION_FAILED", nil)}];
                completion(nil, operationError);
            }
        }
    }];

}
- (void)updateProject:(NXProjectModel *)projectModel withParmetersMD:(NXProjectUpdateParmetersMD *)parmetersMD withCompletion:(projectInfoSyncUpdateProjectCompletion)completion {
    self.timeStamp = [[NSDate date] timeIntervalSince1970];
    NXProjectModel *projectItem = projectModel;
    NXProjectUpdateAPIRequest *request = [[NXProjectUpdateAPIRequest alloc]init];
    [request requestWithObject:parmetersMD Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            completion (projectItem,error);
        } else {
            NXProjectUpdateAPIResponse *apiResponse = (NXProjectUpdateAPIResponse *)response;
            if (apiResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS){
            __block  NSInteger currentIndex = 0;
                dispatch_async(self.projectInfoSerialQueue, ^{
                    for (NSInteger i = 0; i < self.projectArray.count; i++) {
                        NXProjectModel *model = self.projectArray[i];
                        if ([model.projectId isEqualToNumber:projectModel.projectId]) {
                            currentIndex = i;
                            break;
                        }
                    }
                    [self.projectArray replaceObjectAtIndex:currentIndex withObject:projectModel];
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXProjectInfoSyncDidUpdateProjectInfo:error:))) {
                        [self.delegate NXProjectInfoSyncDidUpdateProjectInfo:[self.projectArray mutableCopy] error:nil];
                    }
                    // step call back
                    completion (projectItem,nil);
                    [NXProjectStorage insertProjectModel:projectItem];
                });
            }else {
                NSError *otherrror = [[NSError alloc]initWithDomain:NX_ERROR_PROJECT_DOMAIN code:apiResponse.rmsStatuCode userInfo:@{NSLocalizedDescriptionKey:apiResponse.rmsStatuMessage}];;
                completion (projectItem,otherrror);
            }
        }
    }];
   }
- (void)insertAcceptProjectModeltoStorage:(NXProjectModel *)projectModel {
    self.timeStamp = [[NSDate date] timeIntervalSince1970];
    [NXProjectStorage insertProjectModel:projectModel];
}
- (void)getMyProjectWithCompletion:(queryAllMyProjectInfoCompletion)completion
{
    WeakObj(self);
    dispatch_async(self.projectInfoSerialQueue, ^{
        StrongObj(self);
        completion([self.projectArray mutableCopy], self.lastError);
    });
}

@end
