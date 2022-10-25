//
//  NXProjectInvitationOperation.m
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectInvitationOperation.h"
#import "NXRMCDef.h"
#import "NXProjectInviteUserAPI.h"

@interface NXProjectInvitationOperation ()

@property(nonatomic,strong) NSDictionary *resultDic;
@property(nonatomic, weak) NXProjectInviteUserAPIRequest *inviteRequest;
@end

@implementation NXProjectInvitationOperation

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel emailsArray:(NSArray *)emailsArray invitationMsg:(NSString *)invitationMsg
{
    self = [super init];
    if (self) {
        _resultDic = [[NSDictionary alloc] init];
        
        _prjectModel = projectModel;
        _emailsArray = emailsArray;
        _invitationMsg = invitationMsg?:_prjectModel.invitationMsg;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXProjectInviteUserAPIRequest *request = [[NXProjectInviteUserAPIRequest alloc] init];
    self.inviteRequest = request;
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"emails":_emailsArray,@"invitationMsg":_invitationMsg?:@""};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
             NXProjectInviteUserAPIResponse *returnResponse = ( NXProjectInviteUserAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _resultDic = returnResponse.resultsDic;
                [self finish:nil];
            }
            else
            {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                [self finish:restError];
            }
        }
        else
        {
            [self finish:error];
        }
    }];
}

- (void)workFinished:(NSError *)error
{
    if (self.inviteProjectMemberCompletion)
    {
        self.inviteProjectMemberCompletion(_resultDic,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.inviteRequest cancelRequest];
    if (self.inviteProjectMemberCompletion)
    {
        self.inviteProjectMemberCompletion(nil,cancelError);
    }
}
@end
