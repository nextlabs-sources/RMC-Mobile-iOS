//
//  NXPendingProjectInvitationSync.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 9/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//
#import "NXPendingProjectInvitationSync.h"
#import "NXListPendingInvitationsAPI.h"
#import "NXAcceptProjectInvitationAPI.h"
#import "NXDeclineProjectInvitationAPI.h"
#import "NXProjectListMembersAPI.h"
@interface NXPendingProjectInvitationSync()
@property(nonatomic, strong) dispatch_queue_t pendingProjectInvitationQueue;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, assign) BOOL shouldExitWorkThread;
@property(nonatomic, assign) BOOL isStarted;
@property(nonatomic, strong) NSTimer *workTimer;
@property(nonatomic, assign) NSTimeInterval lastOperationTimeStamp;
@property(nonatomic, strong) NSMutableArray<NXPendingProjectInvitationModel *>* pendingInvitationsArray;
@property(nonatomic, assign) BOOL isWorkerTimerFirstStart;
@end

@implementation NXPendingProjectInvitationSync
#pragma mark - Init/Getter/Setter
- (instancetype)init {
    if (self = [super init]) {
        _pendingProjectInvitationQueue = dispatch_queue_create("com.skydrm.rmc.NXPendingProjectInvitationSync", DISPATCH_QUEUE_CONCURRENT);
        _shouldExitWorkThread = NO;
        _isStarted = NO;
        _isWorkerTimerFirstStart = YES;
    }
    return self;
}

- (NSThread *)workThread {
    if (_workThread == nil) {
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEnterPoint:) object:nil];
        [_workThread start];
    }
    return _workThread;
}

- (void)workThreadEnterPoint:(id)__unused object {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    do{
        @autoreleasepool {
            [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
            if (self.shouldExitWorkThread) {
                break;
            }
            [NSThread sleepForTimeInterval:2.0];
        }
    }while (true);
}

#pragma mark - Sync
- (void)startSync {
    if (!self.isStarted) {
        
        [self startTimer];
        self.isStarted = YES;
    }
}

- (void)stopSync {
    self.shouldExitWorkThread = YES;
    self.isStarted = NO;
    self.workThread = nil;
    [self.workTimer invalidate];
    self.lastOperationTimeStamp = 0;
    [self.pendingInvitationsArray removeAllObjects];
}

#pragma mark - Invitation
- (void)acceptInvitation:(NXPendingProjectInvitationModel *)projectInvitation completion:(accpetPendingInvitationCompleteBlock)completion {
    self.lastOperationTimeStamp = [[NSDate date] timeIntervalSince1970];
    NXAcceptProjectInvitationRequest *acceptInvitationReq = [[NXAcceptProjectInvitationRequest alloc] init];
    [acceptInvitationReq requestWithObject:projectInvitation Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
         #define KStatusCode_InviteExpired 4001
        if(error){
            NSError *retError = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_ACCEPT_PROJECT_INVITATION_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_ACCEPT_INVITATION_FAILED", nil)}];
            completion(projectInvitation, retError);
        }else{
            NSError *retError = nil;
            if (response.rmsStatuCode == KStatusCode_InviteExpired) {
                retError = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_ACCEPT_PROJECT_INVITATION_EXPIRED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_INVITATION_EXPIRED",NULL)}];
                [self.pendingInvitationsArray removeObject:projectInvitation];
            } else if(response.rmsStatuCode == NXRMS_PROJECT_INVITATION_MISMATCH){
                retError = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_INVITATION_MISMATCH userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_INVITATION_MISMATCH", nil)}];
            } else if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
            // accept success or invitation expired, remove the pending info
                [self.pendingInvitationsArray removeObject:projectInvitation];
                NXAcceptProjectInvitationResponse *invitationResponse = (NXAcceptProjectInvitationResponse *)response;
                projectInvitation.projectId = invitationResponse.acceptProjectId;
                projectInvitation.projectInfo.parentTenantId = [invitationResponse.projectTenantId copy];
                projectInvitation.projectInfo.membershipId = [invitationResponse.projectMemberShipId copy];
                // get list member
                NXProjectListMembersAPIRequest * memberRequest =[[NXProjectListMembersAPIRequest alloc]init];
                NSDictionary *paraDic = @{@"projectId":projectInvitation.projectId,@"page":@(1),@"size":@(1000),@"orderBy":[NSNumber numberWithUnsignedInteger:ListMemberOrderByTypeCreateTimeDescending],@"picture":[NSNumber numberWithBool:YES]};
                [memberRequest requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                    if (!error) {
                        NXProjectListMembersAPIResponse *lastResponse = (NXProjectListMembersAPIResponse*)response;
                        NSMutableArray *memberArray = lastResponse.membersItems;
                        projectInvitation.projectInfo.homeShowMembers = memberArray;
                        completion(projectInvitation, retError);
                    }
                }];
                return ;

            } else {
                retError = [[NSError alloc]initWithDomain:NX_ERROR_PROJECT_DOMAIN code:response.rmsStatuCode userInfo:@{NSLocalizedDescriptionKey:response.rmsStatuMessage}];
            }
            
            completion(projectInvitation, retError);
        }
    }];
}
- (void)declineInvitaiton:(NXPendingProjectInvitationModel *)projectInvitation forReason:(NSString *)reason completion:(declinePendingInvitationCompleteBlock)completion {
    self.lastOperationTimeStamp = [[NSDate date] timeIntervalSince1970];
    NXDeclineProjectInvitationRequest *declineInvitationReq = [[NXDeclineProjectInvitationRequest alloc] init];
    NSDictionary *model = @{PROJECT_INVITATION_MODEL_KEY:projectInvitation, DECLINE_INVITATION_REASON_KEY:@""};
    [declineInvitationReq requestWithObject:model Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if(error){
            NSError *retError = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_DECLINE_PROJECT_INVITATION_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_FAILED", nil)}];
            completion(projectInvitation, retError);
        }else{
            NSError *retError = nil;
            if (response.rmsStatuCode == KStatusCode_InviteExpired) {
                retError = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_ACCEPT_PROJECT_INVITATION_EXPIRED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_INVITATION_EXPIRED",NULL)}];
                 [self.pendingInvitationsArray removeObject:projectInvitation];
                
            } else if(response.rmsStatuCode == NXRMS_PROJECT_INVITATION_MISMATCH){
                retError = [[NSError alloc] initWithDomain:NX_ERROR_PROJECT_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_INVITATION_MISMATCH userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_INVITATION_MISMATCH", nil)}];
            } else if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS || response.rmsStatuCode == KStatusCode_InviteExpired) {
                 // accept success or invitation expired, remove the pending info
                [self.pendingInvitationsArray removeObject:projectInvitation];
            } else {
                retError = [[NSError alloc]initWithDomain:NX_ERROR_PROJECT_DOMAIN code:response.rmsStatuCode userInfo:@{NSLocalizedDescriptionKey:response.rmsStatuMessage}];
            }

            completion(projectInvitation, retError);
        }
    }];

}


- (NSArray *)allPendingInvitations {
    @synchronized (self) {
        if (_pendingInvitationsArray == nil) {
            _pendingInvitationsArray = [[NSMutableArray alloc] init];
        }
        return _pendingInvitationsArray;
    }
}

#pragma mark - Private
- (void)startTimer
{
    [self performSelector:@selector(scheduleSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
}

- (void)scheduleSyncTimer
{
     // NSLog(@"get project pending list ++++++++++");
    [self.workTimer invalidate];
    if (!self.shouldExitWorkThread) {
        self.workTimer = [NSTimer scheduledTimerWithTimeInterval:PROJECT_PENDING_INVITATION_SYNC_INTERVAL target:self selector:@selector(syncPendingInvitationFromRMS:) userInfo:nil repeats:NO];
        if (_isWorkerTimerFirstStart) {
              [self.workTimer fire];
            _isWorkerTimerFirstStart = NO;
        }
    }
}

- (void)syncPendingInvitationFromRMS:(NSTimer *)timer {
    NSTimeInterval syncTimeStamp = [[NSDate date] timeIntervalSince1970];
    NXListPendingInvitationsRequest *listPendingInvitationReq = [[NXListPendingInvitationsRequest alloc] init];
    WeakObj(self);
    [listPendingInvitationReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (self) {
            if (syncTimeStamp < self.lastOperationTimeStamp) {
                [self startTimer];
                return;
            }
            
            if(error){
                [self startTimer];
                return;
            }
            
            NXListPendingInvitationsResponse *listPendingInvitationsResponse = (NXListPendingInvitationsResponse *)response;
            if (listPendingInvitationsResponse.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
                [self startTimer];
                return;
            }
            
            
           
            NSMutableSet *localPendingInvitations = [[NSMutableSet alloc] initWithArray:self.pendingInvitationsArray];
            NSMutableSet *rmsPendingInvitations = [[NSMutableSet alloc] initWithArray:listPendingInvitationsResponse.pendingIvitations];
            NSSet *rmsPendingInvitations2 = [NSSet setWithSet:rmsPendingInvitations];
            
            BOOL anyChange = NO;
            // Get Added invitations
            [rmsPendingInvitations minusSet:localPendingInvitations];
            
            // Get del invitations
            [localPendingInvitations minusSet:rmsPendingInvitations2];
            
            for (NXPendingProjectInvitationModel *addItem in rmsPendingInvitations) {
                anyChange = YES;
                [self.pendingInvitationsArray addObject:addItem];
            }
            
            for (NXPendingProjectInvitationModel *delItem in localPendingInvitations) {
                anyChange = YES;
                [self.pendingInvitationsArray removeObject:delItem];
            }
            
            if (anyChange) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_PENDING_INVITATION_CHANGED object:nil];
            }
            
            [self startTimer];
        }
    }];
    
}
@end
