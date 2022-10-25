//
//  NXDenyProjectInvitationAPI.h
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"
#import "NXPendingProjectInvitationModel.h"

#define PROJECT_INVITATION_MODEL_KEY @"INVITATION_KEY"
#define DECLINE_INVITATION_REASON_KEY @"DECLINE_INVITATION_REASON_KEY"

@interface NXDeclineProjectInvitationRequest : NXSuperRESTAPIRequest

@end

@interface NXDeclineProjectInvitationResponse : NXSuperRESTAPIResponse

@end


