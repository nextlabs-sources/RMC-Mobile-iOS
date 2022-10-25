//
//  NXProjectMemberSync.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectMemberSync.h"
#import "NXRMCDef.h"
#import "NXProjectListMembersOperation.h"
#import "NXProjectRemoveMemberAPI.h"
#import "NXProjectInviteUserAPI.h"
#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "NXProjectStorage.h"

@interface NXProjectMemberSync()
@property(nonatomic, strong) dispatch_queue_t memberInfoSerialQueue;
@property(nonatomic, strong) NSMutableArray *projectMembers;
@property(nonatomic, strong) NSTimer *workTimer;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, assign) BOOL shouldExitWorkThread;
@property(nonatomic, assign) BOOL isStarted;
@property(nonatomic, strong) NSOperationQueue *workOptQueue;
@property(nonatomic, strong) NXProjectModel *projectModel;
@property(nonatomic, strong) NXSyncHelper *syncHelper;
@property(nonatomic, assign) NSTimeInterval optTime;
@property(nonatomic, assign) BOOL isWorkTimerFirstStart;
@end

@implementation NXProjectMemberSync
- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel members:(NSArray *)members
{
    if (self = [super init]) {
        _memberInfoSerialQueue = dispatch_queue_create("com.skydrm.rmcent.NXProjectMemberSync", DISPATCH_QUEUE_SERIAL);
        if (members) {
            _projectMembers = [[NSMutableArray alloc] initWithArray:members];
        }else{
            _projectMembers = [[NSMutableArray alloc] init];
        }
        _projectModel = projectModel;
        _syncHelper = [[NXSyncHelper alloc] init];
        _workOptQueue = [[NSOperationQueue alloc] init];
        _isWorkTimerFirstStart = YES;
        
    }
    
    return self;
}

- (void)dealloc{
    DLog(@"NXProjectMemberSync dealloc");
}

- (void)destory
{
    [self stopSyncProjectMember];
    self.projectMembers = nil;
    [self.workOptQueue cancelAllOperations];
    self.workOptQueue = nil;
}

- (NSMutableArray *)getProjectMembers{
    @synchronized (self) {
        return _projectMembers;
    }
}

#pragma mark - Timer runloop
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
    DLog(@"Exit the project member sync runloop");
}


#pragma mark - Timer
-(void)startTimer
{
    if (self.shouldExitWorkThread) {
        return;
    }
    [self performSelector:@selector(scheduleSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
}

-(void)scheduleSyncTimer
{
   //  NSLog(@"NXProjectMemberSync start sync ++++++++++");
    
    [self.workTimer invalidate];
    self.workTimer = [NSTimer scheduledTimerWithTimeInterval:PROJECT_MEMBER_SYNC_INTERVAL target:self selector:@selector(syncProjectMembers:) userInfo:nil repeats:NO];
    if (_isWorkTimerFirstStart) {
        [self.workTimer fire];
        _isWorkTimerFirstStart = NO;
    }
}

- (void)startSyncProjectMember
{
    if (!self.isStarted) {
        self.shouldExitWorkThread = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self syncProjectMembers:nil]; // here we call sync function directly to make sure sync operation will fired at once
        });
        
    }
    
}

- (void)stopSyncProjectMember
{
    self.shouldExitWorkThread = YES;
    self.isStarted = NO;
    
    [self.workTimer invalidate];
    self.workThread = nil;
    
    [self.workOptQueue cancelAllOperations];
}

#pragma mark - sync function
- (void)syncProjectMembers:(NSTimer *)timer
{
    WeakObj(self);
    NSTimeInterval syncTime = [[NSDate date] timeIntervalSince1970];
    self.optTime = syncTime;
    [self.syncHelper uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getProjectMembersRESTCacheURL] mustAllSuccess:YES Complection:^(id object, NSError *error) {
            StrongObj(self);
            if(self){
                
                if (syncTime < self.optTime) { // means the call back is lag behind, so discard it
                    [self startTimer];
                    return;
                }
                NXProjectListMembersOperation *listMemberOpt = [[NXProjectListMembersOperation alloc] initWithProjectModel:self.projectModel page:1 size:2000 orderBy:ListMemberOrderByTypeCreateTimeAscending shouldReturnUserPicture:YES];
                listMemberOpt.projecListMembersCompletion = ^(NSMutableArray *membersArray, NSInteger totalMembers, NSError *error) {
                    if(!error){
                        [self.projectMembers removeAllObjects];
                        self.projectMembers = membersArray;
                        // update storage
                        [NXProjectStorage insertMembers:membersArray toProject:self.projectModel];
                        if (DELEGATE_HAS_METHOD(self.delegate, @selector(projectMemberSyncDidUpdateMembers:))) {
                            [self.delegate projectMemberSyncDidUpdateMembers:[self.projectMembers copy]];
                        }
                    }else{
                        if (error.code == 400) { // means you are kicked
                            dispatch_main_async_safe(^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_YOU_ARE_KICKED_INSIDE object:nil userInfo:@{@"projectId":@[self.projectModel.projectId]}];
                            });
                        }
                    }
                };
                [self.workOptQueue addOperations:@[listMemberOpt] waitUntilFinished:YES];
                
                [self startTimer];
            }
        }
     ];
}

#pragma mark - interface
- (NSArray *)currentProjectMembers
{
    return [self.projectModel copy];
}
+ (void)syncFromRMSMemebers:(NSArray *)members toProject:(NXProjectModel *)project {
    [NXProjectStorage insertMembers:members toProject:project];
}
+ (NSArray *)getMemberListFromStorageOfProject:(NXProjectModel *)projectModel {
    NSArray *membersArray = [[NXProjectStorage queryMemberByProjectId:projectModel.projectId] allObjects];
    return membersArray;
}
- (void)removeProjectMember:(NXProjectMemberModel *)memberModel completion:(projectMemberSyncRemoveMemberCompletion)completion {
    self.optTime = [[NSDate date] timeIntervalSince1970];
    NXProjectRemoveMemberAPIRequest *request = [[NXProjectRemoveMemberAPIRequest alloc] init];
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":memberModel.projectId,@"memberId":memberModel.userId};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
            NSError *restError = nil;
            NXProjectRemoveMemberAPIResponse *returnResponse = (NXProjectRemoveMemberAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS || returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS_NO_NEED_REFRESH)
            {
                [NXProjectStorage deleteProjectMember:memberModel fromProject:self.projectModel];
                dispatch_async(self.memberInfoSerialQueue, ^{
                    [self.projectMembers removeObject:memberModel];
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(projectMemberSyncDidUpdateMembers:))) {
                        [self.delegate projectMemberSyncDidUpdateMembers:[self.projectMembers copy]];
                    }
                });
                completion(nil);
            }
            else
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:returnResponse.rmsStatuMessage};
                restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:userInfo];
                completion(restError);
            }
        }
        else
        {
            completion(error);
        }
    }];
}
@end
