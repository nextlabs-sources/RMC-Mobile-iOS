//
//  NXProjectPendingMemberSync.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectPendingMemberSync.h"
#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "NXProjectListPendingOperation.h"
#import "NXResendProjectInvitationAPI.h"
#import "NXRevokeProjectInvitationAPI.h"
#import "NXProjectInvitationOperation.h"
#import "NXProjectStorage.h"
#import "NXRMCDef.h"
@interface NXProjectPendingMemberSync()
@property(nonatomic, strong) dispatch_queue_t pendingMemberInfoSerialQueue;
@property(nonatomic, strong) NSMutableArray *pendingMembers;
@property(nonatomic, strong) NSTimer *workTimer;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, assign) BOOL shouldExitWorkThread;
@property(nonatomic, assign) BOOL isStarted;
@property(nonatomic, strong) NSOperationQueue *workOptQueue;
@property(nonatomic, strong) NXProjectModel *projectModel;
@property(nonatomic, strong) NXSyncHelper *syncHelper;
@property(nonatomic, strong) NSMutableDictionary *operatonDict;
@property(nonatomic, assign) NSTimeInterval operationTime;
@property(nonatomic, assign) BOOL isWorkTimerFirstStart;
@end

@implementation NXProjectPendingMemberSync
- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel pendingMembers:(NSArray *)pendingMembers
{
    if (self = [super init]) {
        _pendingMemberInfoSerialQueue = dispatch_queue_create("com.skydrm.rmcent.NXProjectPendingMemberSync", DISPATCH_QUEUE_SERIAL);
        if (pendingMembers) {
            _pendingMembers = [[NSMutableArray alloc] initWithArray:pendingMembers];
        }else{
            _pendingMembers = [[NSMutableArray alloc] init];
        }
        _projectModel = projectModel;
        _syncHelper = [[NXSyncHelper alloc] init];
        _workOptQueue = [[NSOperationQueue alloc] init];
        _operatonDict = [[NSMutableDictionary alloc] init];
        _isWorkTimerFirstStart = YES;
    }
    return self;
}

- (void)destory
{
    [self stopSyncProjectPendingMember];
    self.pendingMembers = nil;
    [self.workOptQueue cancelAllOperations];
    self.workOptQueue = nil;
    DLog(@"NXProjectPendingMemberSync dealloc")
}

- (NSMutableArray *)getPendingMembers{
    @synchronized (self) {
        return _pendingMembers;
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
    DLog(@"Exit the project pending member sync runloop");
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
    // NSLog(@"NXProjectPendingMemberSync start sync ++++++++++");
    [self.workTimer invalidate];
    self.workTimer = [NSTimer scheduledTimerWithTimeInterval:PROJECT_PENDING_MEMBER_SYNC_INTERVAL target:self selector:@selector(syncProjectPendingMembers:) userInfo:nil repeats:NO];
    if (_isWorkTimerFirstStart) {
        [self.workTimer fire];
        _isWorkTimerFirstStart = NO;
    }
}

- (void)startSyncProjectPendingMember
{
    if (!self.isStarted) {
        self.shouldExitWorkThread = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [self syncProjectPendingMembers:nil]; // here we call sync function directly to make sure sync operation will fired at once
        });
        
        
       
    }
    
}

- (void)stopSyncProjectPendingMember
{
    self.shouldExitWorkThread = YES;
    self.isStarted = NO;
    
    [self.workTimer invalidate];
    self.workThread = nil;
    
    [self.workOptQueue cancelAllOperations];
}

- (void)syncProjectPendingMembers:(NSTimer *)timer
{
    WeakObj(self);
    NSTimeInterval syncTimeStamp = [[NSDate date] timeIntervalSince1970];
    NXProjectListPendingOperation *listPendingOperaton = [[NXProjectListPendingOperation alloc] initWithProjectModel:self.projectModel page:1 size:1000 orderBy:ListPendingOrderByTypeCreateTimeAscending];
    listPendingOperaton.projecListPendingCompletion = ^(NXProjectModel *projectModel, NSMutableArray *totalPendings, NSError *error) {
        StrongObj(self);
        if (self) {
            if (self.operationTime > syncTimeStamp) {
                return;
            }
            if (!error) {
                dispatch_async(self.pendingMemberInfoSerialQueue, ^{
                    [self.pendingMembers removeAllObjects];
                    self.pendingMembers = totalPendings;
                    // update storage
                    [NXProjectStorage insertPendingMembers:totalPendings toProject:self.projectModel];
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(projectPendingMembersSyncDidUpdatePendingMembers:))) {
                        [self.delegate projectPendingMembersSyncDidUpdatePendingMembers:[self.pendingMembers copy]];
                    }
                });
            }
        }
       
    };
    [self.workOptQueue addOperations:@[listPendingOperaton] waitUntilFinished:YES];
    [self startTimer];
}
+ (NSArray *)currentPendingMembersFromStorageOfProject:(NXProjectModel *)projectModel {
    return [NXProjectStorage quertAllPendingMembersFromProject:projectModel];
}
+ (void)syncFromRMSPendingMemebers:(NSArray *)pendingMembers toProject:(NXProjectModel *)project {
    [NXProjectStorage insertPendingMembers:pendingMembers toProject:project];
}
#pragma mark - operaton interface
- (NSArray *)currentPendingProjectMembers
{
    return [self.pendingMembers copy];;
}
- (void)inviteMemebers:(NSArray *)projectMembers invitationMsg:(NSString *)invitationMsg withCompletion:(projectPendingMemberSyncInviteMemberInProjectCompletion)completion
{
    self.operationTime = [[NSDate date] timeIntervalSince1970];
    NXProjectInvitationOperation *inviteUserOpera = [[NXProjectInvitationOperation alloc] initWithProjectModel:self.projectModel  emailsArray:projectMembers invitationMsg:invitationMsg];
    NSString *optId = [[NSUUID alloc] UUIDString];
    WeakObj(self);
    inviteUserOpera.inviteProjectMemberCompletion = ^(NSDictionary *resultDic,NSError *error){
        StrongObj(self);
        [self.operatonDict removeObjectForKey:optId];
        
         NXProjectListPendingOperation *listPendingOperaton = [[NXProjectListPendingOperation alloc] initWithProjectModel:self.projectModel page:1 size:1000 orderBy:ListPendingOrderByTypeCreateTimeAscending];
        listPendingOperaton.projecListPendingCompletion = ^(NXProjectModel *projectModel, NSMutableArray *totalPendings, NSError *error) {
            [NXProjectStorage insertPendingMembers:totalPendings toProject:projectModel];
             completion(self.projectModel, resultDic, error);
        };
        [listPendingOperaton start];
    };
    [self.operatonDict setObject:inviteUserOpera forKey:optId];
    [inviteUserOpera start];
}

- (void)resendInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectPendingMemberSyncInviteResendProjectInvitionCompletion)completion
{
    self.operationTime = [[NSDate date] timeIntervalSince1970];
    NXResendProjectInvitationAPIRequest *request = [[NXResendProjectInvitationAPIRequest alloc]init];
    WeakObj(self);
    [request requestWithObject:pendingInvitation Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NSString *resultStr = nil;
            NXResendProjectInvitationAPIResponse *resultResponse = (NXResendProjectInvitationAPIResponse *)response;
            resultStr = [NSString stringWithFormat:@"%ld",resultResponse.rmsStatuCode];
            if (resultResponse.rmsStatuCode != 200) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:resultResponse.rmsStatuMessage forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:NX_ERROR_PROJECT_DOMAIN code:resultResponse.rmsStatuCode userInfo:userInfo];
            }
            StrongObj(self);
            if (self) {
                completion(resultStr,error);
            }
        }else{
            completion(nil, error);
        }
    }];

}

- (void)revokeInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectPendingMemberSyncInviteRevokeProjectInvitionCompletion)completion
{
    self.operationTime = [[NSDate date] timeIntervalSince1970];
    NXRevokeProjectInvitationAPIRequest *request = [[NXRevokeProjectInvitationAPIRequest alloc]init];
    WeakObj(self);
    [request requestWithObject:pendingInvitation Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NSString *resultStr = nil;
            NXRevokeProjectInvitationAPIResponse *resultResponse = (NXRevokeProjectInvitationAPIResponse *)response;
            resultStr = [NSString stringWithFormat:@"%ld",resultResponse.rmsStatuCode];
            StrongObj(self);
            if (self) {
                if (resultResponse.rmsStatuCode == 200) {
                    dispatch_async(self.pendingMemberInfoSerialQueue, ^{
                        [NXProjectStorage deletePendingMember:pendingInvitation fromProject:self.projectModel];
                        if (DELEGATE_HAS_METHOD(self.delegate, @selector(projectPendingMembersSyncDidUpdatePendingMembers:))) {
                            [self.delegate projectPendingMembersSyncDidUpdatePendingMembers:[self.pendingMembers copy]];
                        }
                    });
                }else{
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:resultResponse.rmsStatuMessage forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:NX_ERROR_PROJECT_DOMAIN code:resultResponse.rmsStatuCode userInfo:userInfo];
                }
                 completion(resultStr,error);
            }
        }else{
            completion(nil, error);
        }        
    }];
}

@end
