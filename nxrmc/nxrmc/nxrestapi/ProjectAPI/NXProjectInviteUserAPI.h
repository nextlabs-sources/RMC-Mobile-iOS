//
//  NXProjectInviteUserAPI.h
//  nxrmc
//
//  Created by xx-huang on 20/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define PROJECT_ID @"projectId"
#define EMAILS     @"emails"
#define INVITATION_MSG @"invitationMsg"
@interface NXProjectInviteUserAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXProjectInviteUserAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong)NSDictionary *resultsDic;

@end

