//
//  NXProjectListMembersOperation.m
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectListMembersOperation.h"
#import "NXProjectDeleteFileAPI.h"
#import "NXRMCDef.h"
#import "NXProjectListMembersAPI.h"

@interface NXProjectListMembersOperation ()

@property(nonatomic,strong) NSMutableArray *membersArray;
@property(nonatomic,strong) NSNumber *totalMembers;
@property(nonatomic, weak) NXProjectListMembersAPIRequest *listMemeberRequest;

@end

@implementation NXProjectListMembersOperation


-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel page:(NSUInteger)page size:(NSUInteger)size orderBy:(ListMemberOrderByType)orderBy shouldReturnUserPicture:(BOOL)shouldReturnUserPicture
{
    self = [super init];
    if (self) {
        _membersArray = [[NSMutableArray alloc] init];
        
        _prjectModel = projectModel;
        _page = page;
        _size = size;
        _orderBy = orderBy;
        _shouldReturnUserPicture = shouldReturnUserPicture;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXProjectListMembersAPIRequest *request = [[NXProjectListMembersAPIRequest alloc] init];
    self.listMemeberRequest = request;
    
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"page":[NSNumber numberWithUnsignedInteger:_page],@"size":[NSNumber numberWithUnsignedInteger:_size],@"orderBy":[NSNumber numberWithUnsignedInteger:_orderBy],@"picture":[NSNumber numberWithBool:_shouldReturnUserPicture]};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
            NXProjectListMembersAPIResponse *returnResponse = (NXProjectListMembersAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _membersArray = returnResponse.membersItems;
                _totalMembers = returnResponse.totalMembers;
                
                [self finish:nil];
            }else if (returnResponse.rmsStatuCode == 400){ // means you are kicked
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_PROJECT_KICKED userInfo:nil];
                [self finish:restError];
            }else{
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
    if (self.projecListMembersCompletion)
    {
        for (NXProjectMemberModel *memberModel in _membersArray) {
            memberModel.projectId = self.prjectModel.projectId;
        }
        
        self.projecListMembersCompletion(_membersArray,_totalMembers.integerValue,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.listMemeberRequest cancelRequest];
    if (self.projecListMembersCompletion)
    {
        self.projecListMembersCompletion(nil,0,cancelError);
    }
}
@end
