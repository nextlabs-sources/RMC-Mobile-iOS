//
//  NXRMCTestCase.m
//  nxrmc
//
//  Created by xx-huang on 09/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRMCTestCase.h"

@implementation NXRMCTestCase

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

#pragma mark -

- (NSString *)filePath {
    // should be override by subclass
    return @"";
}

- (NSString *)fileName {
    // should be override by subclass
    return @"NXRMCTestFile";
}

@end
