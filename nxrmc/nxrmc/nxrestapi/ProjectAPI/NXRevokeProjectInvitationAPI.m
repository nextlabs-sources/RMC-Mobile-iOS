//
//  NXRevokeProjectInvitationAPI.m
//  nxrmc
//
//  Created by helpdesk on 22/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXRevokeProjectInvitationAPI.h"

@implementation NXRevokeProjectInvitationAPIRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (!self.reqRequest) {
        if ([object isKindOfClass:[NXPendingProjectInvitationModel class]]) {
            NXPendingProjectInvitationModel *model = (NXPendingProjectInvitationModel *)object;
            NSString *inviteeId =[NSString stringWithFormat:@"%@",model.invitationId];
            NSURL *reqURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/project/revokeInvite", [NXCommonUtils currentRMSAddress]]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:reqURL];
            NSDictionary *jsonDict=@{@"parameters":@{@"invitationId":inviteeId}};
            NSError *error;
            NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:bodyData];
            self.reqRequest = request;
        }
       
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXRevokeProjectInvitationAPIResponse *response = [[NXRevokeProjectInvitationAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            
        }
        
        return response;
    };
    
    return analysis;
}

@end







@implementation NXRevokeProjectInvitationAPIResponse


@end
