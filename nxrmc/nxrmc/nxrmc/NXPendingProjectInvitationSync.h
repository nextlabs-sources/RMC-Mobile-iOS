//
//  NXPendingProjectInvitationSync.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 9/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXPendingProjectInvitationModel.h"

typedef void(^accpetPendingInvitationCompleteBlock)(NXPendingProjectInvitationModel *projectInvitation, NSError *error);
typedef void(^declinePendingInvitationCompleteBlock)(NXPendingProjectInvitationModel *projectInvitation, NSError *error);
@interface NXPendingProjectInvitationSync : NSObject
- (void)startSync;
- (void)stopSync;

- (void)acceptInvitation:(NXPendingProjectInvitationModel *)projectInvitation completion:(accpetPendingInvitationCompleteBlock)completion;
- (void)declineInvitaiton:(NXPendingProjectInvitationModel *)projectInvitation forReason:(NSString *)reason completion:(declinePendingInvitationCompleteBlock)completion;
- (NSArray *)allPendingInvitations;
@end
