//
//  NXDenyProjectInvitationAPI.m
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDeclineProjectInvitationAPI.h"


@implementation NXDeclineProjectInvitationRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (!self.reqRequest) {
        NSAssert([object isKindOfClass:[NSDictionary class]], @"NXDeclineProjectInvitationRequest :The object should be NSDictionary");
        NXPendingProjectInvitationModel *invitationModel = ((NSDictionary *)object)[PROJECT_INVITATION_MODEL_KEY];
        NSString *reason = ((NSDictionary *)object)[DECLINE_INVITATION_REASON_KEY];
        NSURL *reqURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/project/decline", [NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:reqURL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *bodyString = [NSString stringWithFormat:@"id=%@&code=%@%@", invitationModel.invitationId, invitationModel.code, reason?[NSString stringWithFormat:@"&declineReason=%@", reason]:@""];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *retString, NSError *error)
    {
        NXDeclineProjectInvitationResponse *response = [[NXDeclineProjectInvitationResponse alloc] init];
        NSData *retData = [retString dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseData:retData];
        return response;
    };
    return analysis;
}

@end

@implementation NXDeclineProjectInvitationResponse
- (void)analysisResponseJSONDict:(NSDictionary *)jsonDict
{
    //nothing to do
}
@end
