//
//  NXProjectGetMemberDetailsOperation.m
//  nxrmc
//
//  Created by xx-huang on 06/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectGetMemberDetailsOperation.h"
#import "NXProjectGetMemberDetailsAPI.h"
#import "NXRMCDef.h"

@interface NXProjectGetMemberDetailsOperation ()

@property(nonatomic, strong) NXProjectMemberModel *memberDetail;
@property(nonatomic, weak) NXProjectGetMemberDetailsAPIRequest *getMemeberDetailRequest;

@end

@implementation NXProjectGetMemberDetailsOperation

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
    NXProjectGetMemberDetailsAPIRequest *request = [[NXProjectGetMemberDetailsAPIRequest alloc] init];
    self.getMemeberDetailRequest = request;
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"memberId":_memberId};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
           NXProjectGetMemberDetailsAPIResponse *returnResponse = ( NXProjectGetMemberDetailsAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _memberDetail = returnResponse.memberDetail;
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
    if (self.getMemberDetaisCompletion)
    {
        self.getMemberDetaisCompletion(_memberDetail,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.getMemeberDetailRequest cancelRequest];
    if (self.getMemberDetaisCompletion)
    {
        self.getMemberDetaisCompletion(_memberDetail,cancelError);
    }
}
@end
