//
//  NXProjectInvitationHelper.h
//  nxrmc
//
//  Created by EShi on 2/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXPendingProjectInvitationModel.h"

typedef void(^projectInvitationHelperAcceptProjectInvitationCompletion)(NXProjectModel *project,NSTimeInterval serverTime,NSInteger statusCode,NSError *error);
typedef void(^projectInvitationHelperRevokeProjectInvitationCompletion)(NSString *statusCode, NSError *error);
typedef void(^projectInvitationHelperResendProjectInvitationCompletion)(NSString *statusCode, NSError *error);
typedef void(^projectInvitationHelperDeclineProjectInvitationCompletion)(NXPendingProjectInvitationModel *pendingInvitation,NSTimeInterval serverTime,NSInteger statusCode,NSError *error);
typedef void(^projectInvitationHelperAllInvitationCompletion)(NSArray *invitations);

@class NXProjectInvitationHelper;
@class NXLProfile;
@protocol NXProjectInvitationHelperDelegate <NSObject>
- (void)projectInvitationHelper:(NXProjectInvitationHelper *)invitationHelper didChangedInvitationArray:(NSArray *)invitations;
@end

@interface NXProjectInvitationHelper : NSObject
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, weak)id<NXProjectInvitationHelperDelegate> delegate;
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile;
- (void)bootUp;  // start sync invitation message
- (void)shutDown; // stop sync invitation message

// all invitations
- (void)allPendingInvitationsWithCompletion:(projectInvitationHelperAllInvitationCompletion)completion;
// accept invitation
- (void)acceptInvitation:(NXPendingProjectInvitationModel *)invitation withCompletion:(projectInvitationHelperAcceptProjectInvitationCompletion)completion;
// revoke invitation
- (void)revokeInvitation:(NXPendingProjectInvitationModel *)pendingModel withCompletion:(projectInvitationHelperRevokeProjectInvitationCompletion)completion;
// resend invitation
- (void)resendInvitation:(NXPendingProjectInvitationModel *)pendingModel withCompletion:(projectInvitationHelperResendProjectInvitationCompletion)completion;
// decline invitation
- (void)declineInvitation:(NXPendingProjectInvitationModel *)invitation forReason:(NSString *)declineReason withCompletion:(projectInvitationHelperDeclineProjectInvitationCompletion) completion;
@end
