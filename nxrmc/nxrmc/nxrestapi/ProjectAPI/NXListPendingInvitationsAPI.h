//
//  NXListPendingInvitationsAPI.h
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

@interface NXListPendingInvitationsRequest : NXSuperRESTAPIRequest

@end

@interface NXListPendingInvitationsResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong, readonly) NSMutableArray *pendingIvitations;

-(void) analysisResponseData:(NSData *) responseData;
@end
