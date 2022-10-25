//
//  NXProjectRemoveMemberOperation.m
//  nxrmc
//
//  Created by xx-huang on 06/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectRemoveMemberOperation.h"
#import "NXProjectRemoveMemberAPI.h"
#import "NXRMCDef.h"

@interface NXProjectRemoveMemberOperation ()
@property(nonatomic, weak) NXProjectRemoveMemberAPIRequest *removeMemeberRequest;
@end

@implementation NXProjectRemoveMemberOperation

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel memberId:(NSString *)memberId;
{
    self = [super init];
    if (self) {
        
        _prjectModel = projectModel;
        _memberId = memberId;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXProjectRemoveMemberAPIRequest *request = [[NXProjectRemoveMemberAPIRequest alloc] init];
    self.removeMemeberRequest = request;
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"memberId":_memberId};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
            NXProjectRemoveMemberAPIResponse *returnResponse = (NXProjectRemoveMemberAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS || returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS_NO_NEED_REFRESH)
            {
                [self finish:nil];
            }
            else
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:returnResponse.rmsStatuMessage};
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:userInfo];
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
    if (self.removeProjectMemberCompletion)
    {
        self.removeProjectMemberCompletion(error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.removeMemeberRequest cancelRequest];
    if (self.removeProjectMemberCompletion)
    {
        self.removeProjectMemberCompletion(cancelError);
    }
}
@end

