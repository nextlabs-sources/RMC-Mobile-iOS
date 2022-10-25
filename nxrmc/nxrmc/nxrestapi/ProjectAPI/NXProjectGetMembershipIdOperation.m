//
//  NXProjectGetMembershipIdOperation.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 19/04/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXProjectGetMembershipIdOperation.h"
#import "NXGetMemberShipAPI.h"
#import "NXRMCDef.h"


@interface NXProjectGetMembershipIdOperation ()

@property(nonatomic, strong) NXProjectMemberModel *memberDetail;
@property(nonatomic, weak) NXGetMemberShipAPIRequest *getMemebershipIdRequest;

@end

@implementation NXProjectGetMembershipIdOperation

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel
{
    self = [super init];
    if (self) {
        _projectModel = projectModel;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXGetMemberShipAPIRequest *request = [[NXGetMemberShipAPIRequest alloc] init];
    self.getMemebershipIdRequest = request;
    WeakObj(self);
    [request requestWithObject:self.projectModel.projectId Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
             NXGetMemberShipAPIResponse*returnResponse = ( NXGetMemberShipAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _projectModel.membershipId = returnResponse.projectItem.membershipId;
                _projectModel.tokenGroupName = returnResponse.projectItem.tokenGroupName;
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
    if (self.getMembershipIdCompletion)
    {
        self.getMembershipIdCompletion(_projectModel,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.getMemebershipIdRequest cancelRequest];
    if (self.getMembershipIdCompletion)
    {
        self.getMembershipIdCompletion(_projectModel,cancelError);
    }
}
@end
