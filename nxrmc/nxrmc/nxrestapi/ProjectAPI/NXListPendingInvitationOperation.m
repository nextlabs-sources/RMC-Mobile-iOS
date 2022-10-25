//
//  NXListPendingInvitationOperation.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXListPendingInvitationOperation.h"
#import "NXListPendingInvitationsAPI.h"
@interface NXListPendingInvitationOperation()
@property(nonatomic, weak) NXListPendingInvitationsRequest *request;
@property(nonatomic, strong) NSMutableArray *pendingInvitations;
@property(nonatomic, strong) NSError *error;
@end
@implementation NXListPendingInvitationOperation
- (instancetype)init
{
    if (self = [super init]) {
        _pendingInvitations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
}
// need overwrite by subclasses
/**
 Purpose: called when operation started, do really task logic
 
 @param error The error return if there is any error during task logic.
 */
- (void)executeTask:(NSError **)error
{
    NXListPendingInvitationsRequest *request = [[NXListPendingInvitationsRequest alloc] init];
    self.request = request;
    WeakObj(self);
    [request requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *restError) {
        if ([response isKindOfClass:[NXListPendingInvitationsResponse class]]) {
            NXListPendingInvitationsResponse *listPendingResponse = (NXListPendingInvitationsResponse *)response;
            StrongObj(self);
            if (self) {
                if (!restError) {
                    if(listPendingResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS){
                        self.pendingInvitations = listPendingResponse.pendingIvitations;
                    }else{
                        restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
                    }
                }
                
                [self finish:restError];
            }
        }
    }];
    
    
}

/**
 Purpose: called when operation finished, do yourself work end
 
 @param error The error happened when doing operation logic.
 */
- (void)workFinished:(NSError *)error
{
    if (self.optCompletion) {
        self.optCompletion(self.pendingInvitations, error);
    }
}

/**
 Purpose: called when operation to be canceled, do yourself work cancel
 
 @param error The error stand for cancell error.
 */
- (void)cancelWork:(NSError *)cancelError
{
    [self.request cancelRequest];
}
@end
