//
//  NXProjectListPendingOperation.m
//  nxrmc
//
//  Created by helpdesk on 21/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectListPendingOperation.h"
#import "NXProjectGetListPendingInvitationsAPI.h"
@interface NXProjectListPendingOperation ()
@property (nonatomic, strong)NSMutableArray *pendingLists;
@property (nonatomic, strong)NXProjectModel *projectModel;
@property (nonatomic, weak)NXProjectGetListPendingInvitationsAPIRequest *pendingRequest;

@end
@implementation NXProjectListPendingOperation
-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel page:(NSUInteger)page size:(NSUInteger)size orderBy:(ListPendingOrderByType)orderBy {
    self = [super init];
    if (self) {
        _pendingLists = [NSMutableArray array];
        _prjectModel = projectModel;
        _page = page;
        _size = size;
        _orderBy = orderBy;
    }
    return  self;
}

- (void)executeTask:(NSError **)error
{
    NXProjectGetListPendingInvitationsAPIRequest *request = [[NXProjectGetListPendingInvitationsAPIRequest alloc] init];
    self.pendingRequest = request;
    
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"page":[NSNumber numberWithUnsignedInteger:_page],@"size":[NSNumber numberWithUnsignedInteger:_size],@"orderBy":[NSNumber numberWithUnsignedInteger:_orderBy],@"searchString":@""};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
            NXProjectGetListPendingInvitationsAPIResponse *returnResponse = (NXProjectGetListPendingInvitationsAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _pendingLists = returnResponse.pendingArray;
                
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
    if (self.projecListPendingCompletion)
    {
        for (NXPendingProjectInvitationModel *pendModel in _pendingLists) {
            pendModel.projectId = self.prjectModel.projectId;
        }
        
        self.projecListPendingCompletion(_prjectModel,_pendingLists,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.pendingRequest cancelRequest];
    if (self.projecListPendingCompletion)
    {
        self.projecListPendingCompletion(nil,nil,cancelError);
    }
}

@end
