//
//  NXProjectInvitationHelper.m
//  nxrmc
//
//  Created by EShi on 2/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectInvitationHelper.h"
#import "NXListPendingInvitationsAPI.h"
#import "NXAcceptProjectInvitationAPI.h"
#import "NXDeclineProjectInvitationAPI.h"
#import "NXRevokeProjectInvitationAPI.h"
#import "NXResendProjectInvitationAPI.h"
#import "NXLProfile.h"
#define SYNC_INTERVAL 5.0

@interface NXProjectInvitationHelper()
@property(nonatomic, strong) NSMutableDictionary *invitationDict;
@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, strong) NSTimer *syncInvitationTimer;
@property(nonatomic, assign) BOOL exited;
@property(nonatomic, strong) dispatch_queue_t serialQueue;
@end

@implementation NXProjectInvitationHelper
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile
{
    self = [super init];
    if (self) {
        _userProfile = userProfile;
        _exited = NO;
        _invitationDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)bootUp
{
    if (!self.workThread) {
        _exited = NO;
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntity:) object:nil];
        [_workThread start];
        _serialQueue = dispatch_queue_create("com.skydrm.rmcent.NXProjectInvitationHelper.serialQueue", DISPATCH_QUEUE_SERIAL);
        
        [self performSelector:@selector(setUpSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
    }
}

- (void)setUpSyncTimer
{
    if (self.exited) {
        return;
    }
    
    [self.syncInvitationTimer invalidate];
    self.syncInvitationTimer = [NSTimer scheduledTimerWithTimeInterval:SYNC_INTERVAL target:self selector:@selector(fetchUserPendingInvitations:) userInfo:nil repeats:NO];
}

- (void)fetchUserPendingInvitations:(NSTimer *)timer
{
    WeakObj(self);
    NXListPendingInvitationsRequest *request = [[NXListPendingInvitationsRequest alloc] init];
    [request requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if ([response isKindOfClass:[NXListPendingInvitationsResponse class]]) {
            StrongObj(self);
            if (self.exited || self == nil) {
                return ;
            }
            dispatch_async(self.serialQueue, ^{
                // step1. update local data
                BOOL didChange = NO;
                for (NXPendingProjectInvitationModel *invitation in ((NXListPendingInvitationsResponse *)response).pendingIvitations) {
                    if (!self.invitationDict[invitation.invitationId]) {
                        didChange = YES;
                    }
                    [self.invitationDict setObject:invitation forKey:invitation.invitationId];
                }
                // step2. notificate delegate invitation info changed
                if (didChange && DELEGATE_HAS_METHOD(self.delegate, @selector(projectInvitationHelper:didChangedInvitationArray:))) {
                    [self.delegate projectInvitationHelper:self didChangedInvitationArray:[[NSMutableArray alloc] initWithArray:[self.invitationDict allValues] copyItems:YES]];
                }
                
                // step3. start next fetch timer
                [self performSelector:@selector(setUpSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
            });
        }
    }];
}
- (void)shutDown
{
    self.exited = YES;
    self.workThread = nil;
    [self.syncInvitationTimer invalidate];
    self.syncInvitationTimer = nil;
    self.serialQueue = nil;
}

- (void)dealloc
{
    DLog();
}

- (void)workThreadEntity:(id)__unused userInfo
{
    NSRunLoop* loop = [NSRunLoop currentRunLoop];
    do
    {
        @autoreleasepool
        {
            [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
            if (self.exited) {
                break;
            }
            
            [NSThread sleepForTimeInterval:1.0f];
        }
    }while (true);
}

- (void)allPendingInvitationsWithCompletion:(projectInvitationHelperAllInvitationCompletion)completion
{
    WeakObj(self);
    dispatch_async(self.serialQueue, ^{
        StrongObj(self);
        if (self.exited) {
            NSAssert(NO, @"should bootUp before get all pending invitations");
        }
        completion([self.invitationDict allValues]);
    });
}

- (void)acceptInvitation:(NXPendingProjectInvitationModel *)invitation withCompletion:(projectInvitationHelperAcceptProjectInvitationCompletion)completion
{
    NXAcceptProjectInvitationRequest *request = [[NXAcceptProjectInvitationRequest alloc] init];
    NXProjectModel *project = [invitation.projectInfo copy];
   __block NSTimeInterval serverTime;
    __block NSInteger statusCode;
    WeakObj(self);
    [request requestWithObject:invitation Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        serverTime = ((NXAcceptProjectInvitationResponse *)response).serverTime;
        statusCode = ((NXAcceptProjectInvitationResponse *)response).rmsStatuCode;
        if([response isKindOfClass:[NXAcceptProjectInvitationResponse class]] && ((NXAcceptProjectInvitationResponse *)response).rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS){
            project.projectId = ((NXAcceptProjectInvitationResponse *)response).acceptProjectId;
            project.isOwnedByMe = NO;
        }
        StrongObj(self);
        dispatch_async(self.serialQueue, ^{
            [self.invitationDict removeObjectForKey:invitation.invitationId];
            if (completion) {
                completion(project,serverTime,statusCode,error);
            }
        });
       
    }];
}
- (void)revokeInvitation:(NXPendingProjectInvitationModel *)pendingModel withCompletion:(projectInvitationHelperRevokeProjectInvitationCompletion)completion {
    NXRevokeProjectInvitationAPIRequest *request = [[NXRevokeProjectInvitationAPIRequest alloc]init];
    WeakObj(self);
    [request requestWithObject:pendingModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
         NSString *resultStr = nil;
        NXRevokeProjectInvitationAPIResponse *resultResponse = (NXRevokeProjectInvitationAPIResponse *)response;
        resultStr = [NSString stringWithFormat:@"%ld",resultResponse.rmsStatuCode];
        StrongObj(self);
        dispatch_async(self.serialQueue, ^{
            [self.invitationDict removeObjectForKey:pendingModel.invitationId];
            completion(resultStr, error);
//            if (DELEGATE_HAS_METHOD(self.delegate, @selector(projectInvitationHelper:didChangedInvitationArray:))) {
//                [self.delegate projectInvitationHelper:self didChangedInvitationArray:[[NSMutableArray alloc] initWithArray:[self.invitationDict allValues] copyItems:YES]];
//            }
        });
        
    }];

}
- (void)resendInvitation:(NXPendingProjectInvitationModel *)pendingModel withCompletion:(projectInvitationHelperResendProjectInvitationCompletion)completion {
    NXResendProjectInvitationAPIRequest *request = [[NXResendProjectInvitationAPIRequest alloc]init];
    WeakObj(self);
    [request requestWithObject:pendingModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NSString *resultStr = nil;
        NXResendProjectInvitationAPIResponse *resultResponse = (NXResendProjectInvitationAPIResponse *)response;
        resultStr = [NSString stringWithFormat:@"%ld",resultResponse.rmsStatuCode];
        StrongObj(self);
        dispatch_async(self.serialQueue, ^{
            [self.invitationDict removeObjectForKey:pendingModel.invitationId];
            completion(resultStr, error);
//            if (DELEGATE_HAS_METHOD(self.delegate, @selector(projectInvitationHelper:didChangedInvitationArray:))) {
//                [self.delegate projectInvitationHelper:self didChangedInvitationArray:[[NSMutableArray alloc] initWithArray:[self.invitationDict allValues] copyItems:YES]];
//            }
        });
        
    }];
    
}

- (void)declineInvitation:(NXPendingProjectInvitationModel *)invitation forReason:(NSString *)declineReason withCompletion:(projectInvitationHelperDeclineProjectInvitationCompletion) completion
{
    NXDeclineProjectInvitationRequest *request = [[NXDeclineProjectInvitationRequest alloc] init];
    NSDictionary *modelDict = @{PROJECT_INVITATION_MODEL_KEY:invitation, DECLINE_INVITATION_REASON_KEY:declineReason?declineReason:@""};
    WeakObj(self);
    [request requestWithObject:modelDict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        NSTimeInterval serverTime = ((NXDeclineProjectInvitationResponse*)response).serverTime;
        NSInteger statusCode = ((NXAcceptProjectInvitationResponse *)response).rmsStatuCode;
        dispatch_async(self.serialQueue, ^{
            [self.invitationDict removeObjectForKey:invitation.invitationId];
            if (completion) {
                completion(invitation,serverTime,statusCode,error);
            }
           
//            if (DELEGATE_HAS_METHOD(self.delegate, @selector(projectInvitationHelper:didChangedInvitationArray:))) {
//                [self.delegate projectInvitationHelper:self didChangedInvitationArray:[[NSMutableArray alloc] initWithArray:[self.invitationDict allValues] copyItems:YES]];
//            }
        });
    }];
}


@end
