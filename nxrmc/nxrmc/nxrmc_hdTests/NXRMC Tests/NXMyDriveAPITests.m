//
//  NXMyDriveAPITests.m
//  nxrmc
//
//  Created by EShi on 3/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NXRMCTestCase.h"
#import "NXMyDriveGetUsageAPI.h"


@interface NXMyDriveAPITests : NXRMCTestCase

@end

@implementation NXMyDriveAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

- (void)testGetStorageUsedAPI
{
    XCTestExpectation *e = [self expectationWithDescription:@"testGetStorageUsedAPI"];
    NXMyDriveGetUsageRequeset*req = [[NXMyDriveGetUsageRequeset alloc] init];
    [req requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXMyDriveGetUsageResponse *myGetInfoResponse = (NXMyDriveGetUsageResponse *)response;
        NSLog(@"The response is %@", myGetInfoResponse);
        [e fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];

}

@end
