//
//  NXProjectPendingMemberSync.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXProjectModel.h"
#import "NXPendingProjectInvitationModel.h"

typedef void(^projectPendingMemberSyncInviteMemberInProjectCompletion)(NXProjectModel *project, NSDictionary *resultDic, NSError *error);
typedef void(^projectPendingMemberSyncInviteRevokeProjectInvitionCompletion)(NSString *statusCode, NSError *error);
typedef void(^projectPendingMemberSyncInviteResendProjectInvitionCompletion)(NSString *statusCode, NSError *error);

@protocol NXProjectPendingMemberSyncDelegate <NSObject>
- (void)projectPendingMembersSyncDidUpdatePendingMembers:(NSArray *)pendingMembers;
@end
@interface NXProjectPendingMemberSync : NSObject
@property(nonatomic, weak) id<NXProjectPendingMemberSyncDelegate> delegate;

- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel pendingMembers:(NSArray *)pendingMembers;
- (void)startSyncProjectPendingMember;
- (void)stopSyncProjectPendingMember;
- (void)destory;
+ (void)syncFromRMSPendingMemebers:(NSArray *)pendingMembers toProject:(NXProjectModel *)project;
+ (NSArray *)currentPendingMembersFromStorageOfProject:(NXProjectModel *)projectModel;
- (NSArray *)currentPendingProjectMembers;
- (void)inviteMemebers:(NSArray *)projectMembers invitationMsg:(NSString *)invitationMsg withCompletion:(projectPendingMemberSyncInviteMemberInProjectCompletion)completion;
- (void)resendInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectPendingMemberSyncInviteResendProjectInvitionCompletion)completion;
- (void)revokeInvitation:(NXPendingProjectInvitationModel *)pendingInvitation withCompletion:(projectPendingMemberSyncInviteRevokeProjectInvitionCompletion)completion;

@end
