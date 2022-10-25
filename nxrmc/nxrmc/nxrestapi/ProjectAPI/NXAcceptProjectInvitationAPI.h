//
//  NXAcceptProjectInvitationAPI.h
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"
#import "NXPendingProjectInvitationModel.h"


@interface NXAcceptProjectInvitationRequest : NXSuperRESTAPIRequest

@end

@interface NXAcceptProjectInvitationResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NXProjectModel *projectInfo;
@property(nonatomic, strong) NSNumber *acceptProjectId;
@property(nonatomic, strong) NSString *projectMemberShipId;
@property(nonatomic, strong) NSString *projectTenantId;
- (instancetype)initWithInvitationModel:(NXProjectModel *)invitationProject;
@end
