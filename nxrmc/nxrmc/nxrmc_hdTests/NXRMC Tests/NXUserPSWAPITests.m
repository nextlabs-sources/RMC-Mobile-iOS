//
//  NXUserPSWAPITests.m
//  nxrmc
//
//  Created by EShi on 3/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NXRMCTestCase.h"
#import "NXResetPasswordAPI.h"

@interface NXUserPSWAPITests : NXRMCTestCase
@property(nonatomic, strong) NXResetPasswordRequest *restPSWReq;
@end

@implementation NXUserPSWAPITests

- (void)setUp {
    [super setUp];
    _restPSWReq = [[NXResetPasswordRequest alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testRestPSW{
     XCTestExpectation *e = [self expectationWithDescription:@"testListPendingInvitationAPI"];
    [_restPSWReq requestWithObject:@{NXResetPasswordRequestOldPSWKey:@"neww", NXResetPasswordRequestNewPSWKey:@"123blue!"} Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (response) {
            NXResetPasswordResponse *restResponse = (NXResetPasswordResponse *)response;
            NSLog(@"The result code is %ld, message %@", restResponse.rmsStatuCode, restResponse.rmsStatuMessage);
        }
        [e fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}
@end
