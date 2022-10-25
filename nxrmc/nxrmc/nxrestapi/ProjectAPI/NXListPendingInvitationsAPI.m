//
//  NXListPendingInvitationsAPI.m
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXListPendingInvitationsAPI.h"
#import "NXPendingProjectInvitationModel.h"

@implementation NXListPendingInvitationsRequest
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (!self.reqRequest) {
        NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/project/user/invitation/pending", [NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnString, NSError* error){
        NSData *returnData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        NXListPendingInvitationsResponse *response = [[NXListPendingInvitationsResponse alloc] init];
        if (returnData) {
            [response analysisResponseData:returnData];
        }
        return response;
    };
    return analysis;
}
@end


@interface NXListPendingInvitationsResponse()
@property(nonatomic, strong, readwrite) NSMutableArray *pendingIvitations;
@end

@implementation NXListPendingInvitationsResponse
- (NSMutableArray *)pendingIvitations
{
    if (_pendingIvitations == nil) {
        _pendingIvitations = [[NSMutableArray alloc] init];
    }
    return _pendingIvitations;
}
- (void) analysisResponseData:(NSData *) responseData
{
    if (responseData) {
        [self analysisResponseStatus:responseData];
    }
    NSError *error = nil;
    NSDictionary *resultDict = [responseData toJSONDict:&error];
    if (!error) {
        NSDictionary *pendingInvitationsDict = resultDict[@"results"];
        if (pendingInvitationsDict) {
            NSArray *pendingInvitations = pendingInvitationsDict[@"pendingInvitations"];
            for (NSDictionary *pendingInvitationInfo in pendingInvitations) {
                NXPendingProjectInvitationModel *model = [[NXPendingProjectInvitationModel alloc] initWithDictionary:pendingInvitationInfo];
                [self.pendingIvitations addObject:model];
            }
        }
    }
}
@end
