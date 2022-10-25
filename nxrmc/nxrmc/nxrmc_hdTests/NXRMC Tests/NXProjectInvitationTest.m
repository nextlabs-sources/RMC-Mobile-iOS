//
//  NXProjectInvitationTest.m
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NXListPendingInvitationsAPI.h"
#import "NXAcceptProjectInvitationAPI.h"
#import "NXDeclineProjectInvitationAPI.h"

@interface NXProjectInvitationTest : XCTestCase
@property(nonatomic, strong) NXListPendingInvitationsRequest *listPendingInvReq;
@property(nonatomic, strong) NXAcceptProjectInvitationRequest *acceptInvReq;
@property(nonatomic, strong) NXDeclineProjectInvitationRequest *declineInvReq;
@end

@implementation NXProjectInvitationTest

- (void)setUp {
    [super setUp];
    _listPendingInvReq = [[NXListPendingInvitationsRequest alloc] init];
    _acceptInvReq = [[NXAcceptProjectInvitationRequest alloc] init];
    _declineInvReq = [[NXDeclineProjectInvitationRequest alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testListPendingInvitationAPI {
    XCTestExpectation *e = [self expectationWithDescription:@"testListPendingInvitationAPI"];
    [_listPendingInvReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if ([response isKindOfClass:[NXListPendingInvitationsResponse class]]) {
            for (NXPendingProjectInvitationModel *model in ((NXListPendingInvitationsResponse *)response).pendingIvitations) {
                NSLog(@"%@ invite you to join %@", model.inviterDisplayName, model.projectInfo.name);
            }
        }
        [e fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}

- (void)testAcceptInvitationAPI{
    XCTestExpectation *e = [self expectationWithDescription:@"testListPendingInvitationAPI"];
    __block NXPendingProjectInvitationModel *invModel = nil;
    [_listPendingInvReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if ([response isKindOfClass:[NXListPendingInvitationsResponse class]]) {
            for (NXPendingProjectInvitationModel *model in ((NXListPendingInvitationsResponse *)response).pendingIvitations) {
                NSLog(@"%@ invite you to join %@", model.inviterDisplayName, model.projectInfo.name);
            }
            
            invModel = (NXPendingProjectInvitationModel *)((NXListPendingInvitationsResponse *)response).pendingIvitations.firstObject;
            
            [_acceptInvReq requestWithObject:invModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                if ([response isKindOfClass:[NXAcceptProjectInvitationResponse class]]) {
                    XCTAssert(((NXAcceptProjectInvitationResponse *)response).rmsStatuCode == 200);
                }
                [e fulfill];
            }];
            
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];

}

- (void)testDeclineInvitationAPI{
    XCTestExpectation *e = [self expectationWithDescription:@"testListPendingInvitationAPI"];
    __block NXPendingProjectInvitationModel *invModel = nil;
    [_listPendingInvReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if ([response isKindOfClass:[NXListPendingInvitationsResponse class]]) {
            for (NXPendingProjectInvitationModel *model in ((NXListPendingInvitationsResponse *)response).pendingIvitations) {
                NSLog(@"%@ invite you to join %@", model.inviterDisplayName, model.projectInfo.name);
            }
            
            invModel = (NXPendingProjectInvitationModel *)((NXListPendingInvitationsResponse *)response).pendingIvitations.firstObject;
            NSDictionary *modelDict = @{PROJECT_INVITATION_MODEL_KEY:invModel, DECLINE_INVITATION_REASON_KEY:@"I do not like you!"};
            [_declineInvReq requestWithObject:modelDict Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                if ([response isKindOfClass:[NXAcceptProjectInvitationResponse class]]) {
                    XCTAssert(((NXAcceptProjectInvitationResponse *)response).rmsStatuCode == 200);
                }
                [e fulfill];
            }];
            
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
