//
//  NXUserPreferenceAPITests.m
//  nxrmcTests
//
//  Created by Eren (Teng) Shi on 11/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NXRMCTestCase.h"
#import "NXGetUserPreferenceAPI.h"
#import "NXUpdateUserPreferenceAPI.h"

@interface NXUserPreferenceAPITests : XCTestCase

@end

@implementation NXUserPreferenceAPITests

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

- (void)testGetUserPreferenceAPI {
    NXGetUserPreferenceRequest *getUserPreferenceReq = [[NXGetUserPreferenceRequest alloc] init];
    [getUserPreferenceReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if(response.rmsStatuCode == 200) {
            NXGetUserPreferenceResponse *userPreferenceResponse = (NXGetUserPreferenceResponse *)response;
            NSMutableString *watermarkString = [[NSMutableString alloc] init];
            for (NXWatermarkWord *waterMark in userPreferenceResponse.watermarkPreference) {
                [watermarkString appendString:[waterMark watermarkLocalizedString]];
            }
            NSLog(@"watermark word is %@", watermarkString);
            
            NSLog(@"validate date is %@", userPreferenceResponse.validateDatePreference);
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}

- (void)testUpdateUserPreferenceAPI {
    
}

@end
