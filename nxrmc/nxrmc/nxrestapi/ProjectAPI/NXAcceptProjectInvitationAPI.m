//
//  NXAcceptProjectInvitationAPI.m
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXAcceptProjectInvitationAPI.h"

@implementation NXAcceptProjectInvitationRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object
{
    NSAssert([object isKindOfClass:[NXPendingProjectInvitationModel class]], @"NXAcceptProjectInvitationRequest request object should be NXPendingProjectInvitationModel");
    if (!self.reqRequest) {
        NXPendingProjectInvitationModel *invitationModel = (NXPendingProjectInvitationModel *)object;
        NSURL *requestURL = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"%@/rs/project/accept?id=%@&code=%@", [NXCommonUtils currentRMSAddress], invitationModel.invitationId, invitationModel.code]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
         self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis) analysisReturnData
{
    Analysis analysis = (id)^(NSString *retString, NSError *error){
        NXAcceptProjectInvitationResponse *response = [[NXAcceptProjectInvitationResponse alloc] init];
        NSData *retData = [retString dataUsingEncoding:NSUTF8StringEncoding];
        if (retData) {
            [response analysisResponseData:retData];
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:retData options:NSJSONReadingMutableContainers error:nil];
            response.acceptProjectId = jsonDic[@"results"][@"projectId"];
            NSDictionary *membership = jsonDic[@"results"][@"membership"];
            response.projectMemberShipId = membership[@"id"];
            response.projectTenantId = membership[@"tenantId"];
            
        }
        return response;
    };
    return analysis;
}
@end



@implementation NXAcceptProjectInvitationResponse
- (instancetype)initWithInvitationModel:(NXProjectModel *)invitationProject
{
    self = [super init];
    if (self) {
        _projectInfo = [invitationProject copy];
    }
    return self;
}
- (void)analysisResponseJSONDict:(NSDictionary *)jsonDict
{
    if(jsonDict){
        if (jsonDict[@"results"]) {
            self.projectInfo.projectId = jsonDict[@"results"][@"projectId"];
        }
    }
}
@end
