//
//  NXListPendingInvitationOperation.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXPendingProjectInvitationModel.h"
typedef void(^listPendingInvitationCompletion)(NSArray *pendingInvitations, NSError *error);
@interface NXListPendingInvitationOperation : NXOperationBase
@property(nonatomic, copy) listPendingInvitationCompletion optCompletion;
@end
