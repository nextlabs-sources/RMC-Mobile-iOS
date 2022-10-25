//
//  NXMyVaultUploadAPITests.m
//  nxrmc
//
//  Created by xx-huang on 09/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NXRMCTestCase.h"
#import "NXMyVaultFileUploadAPI.h"
#import "NXProjectDeleteFileAPI.h"
#import "NXProjectFileMetaDataAPI.h"
#import "NXProjectSearchAPI.h"
#import "NXProjectListAPI.h"
#import "NXProjectCreateFolderAPI.h"
#import "NXProjectDownloadFileAPI.h"
#import "NXProjectInviteUserAPI.h"
#import "NXProjectListMembersAPI.h"
#import "NXGetClassificationProfileAPI.h"
#import "NXPerformPolicyEvaluationAPI.h"
#import "NXClassificationCategory.h"
#import "NXClassificationLab.h"
#import "NXListMembershipsAPI.h"


@interface NXMyVaultUploadAPITests : NXRMCTestCase

@property (nonatomic,strong) NXMyVaultFileUploadAPIRequest *request;

@property (nonatomic,strong) NXProjectDeleteFileAPIRequest *request1;


@property (nonatomic,strong) NXProjectFileMetaDataAPIRequest *request2;

@property (nonatomic,strong) NXProjectSearchAPIRequest *request3;

@property (nonatomic,strong) NXProjectListAPIRequest *request4;

@property (nonatomic,strong) NXProjectCreateFolderAPIRequest *request5;

@property (nonatomic,strong) NXProjectDownloadFileAPIRequest *request6;

@property (nonatomic,strong) NXProjectInviteUserAPIRequest *request7;

@property (nonatomic,strong) NXProjectListMembersAPIRequest *request8;

@property (nonatomic,strong) NXGetClassificationProfileAPIRequest *request9;

@property (nonatomic,strong) NXPerformPolicyEvaluationAPIRequest *request10;

@property (nonatomic,strong) NXListMembershipsAPIRequest *request11;


@property (nonatomic,strong) XCTestExpectation *expectation;

@end

@implementation NXMyVaultUploadAPITests

- (void)setUp
{
    _request = [[NXMyVaultFileUploadAPIRequest alloc] init];
    
    _request1 = [[NXProjectDeleteFileAPIRequest alloc] init];
    
    _request2 = [[NXProjectFileMetaDataAPIRequest alloc] init];
    
    _request3 = [[NXProjectSearchAPIRequest alloc] init];
    
    _request4 = [[NXProjectListAPIRequest alloc] init];
    
    _request5 = [[NXProjectCreateFolderAPIRequest alloc] init];
    
    _request6 = [[NXProjectDownloadFileAPIRequest alloc] init];
    
    _request7 = [[NXProjectInviteUserAPIRequest alloc] init];
    
    _request8 = [[NXProjectListMembersAPIRequest alloc] init];
    _request9 = [[NXGetClassificationProfileAPIRequest alloc] init];
    _request10 = [[NXPerformPolicyEvaluationAPIRequest alloc] init];
    _request11 = [[NXListMembershipsAPIRequest alloc] init];
}

- (void)testMyVaultUploadAPI {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"sdkTest" ofType:@"pdf.nxl"];
//    NSData *fileData = [NSData dataWithContentsOfFile:path];
//    
//    XCTAssertNotNil(path,@"path can not be nil");
//    XCTAssertNotNil(fileData,@"fileData can not be nil");
//    
//    NSDictionary *model = @{@"fileName":self.fileName, @"fileData":fileData};
    
//    NSDictionary *model2 = @{@"filePath":@"/testdeleteapi/nxlfetchactivityloginfodatamodel-2017-01-18-08-08-06.h.nxl", @"projectId":@"11"};
    
//    NSDictionary *model2 = @{@"filePath":@"huangxinxin", @"projectId":@"11",@"autorename":@"false"};
    
//     NSString *model22 = @"true";
    
//    NSDictionary *model2 = @{@"query":@"model",@"projectId":@"11"};
    
//     NSDictionary *model2 = @{@"emails":@[@"510853361@qq.com"], @"projectId":@"11",@"projectName":@"xx-huang",@"projectDescription":@"xx-huang"};
//
//
//    NSDictionary*model8 = @{@"page":@1,@"size":@10,@"orderBy":@1,@"picture":@1,@"projectId":@11};

    
    // 1 declares objects of XCTestExpectation
    XCTestExpectation *e = [self expectationWithDescription:@"test async uploadAPI"];
    
    // 2 refernce object
    self.expectation = e;
    
//    [_request requestWithObject:model Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
//        
//        XCTAssertNotNil(error, @"error not nil");
//        [self.expectation fulfill];
//
//    }];
    
  //  NSString*prjectId = @"3733";
    
//    NSString *memberShipId = [dic objectForKey:MEMBER_SHIP_ID];
//    NSString *resourceName = [dic objectForKey:RESOURCE_NAME];
//    NSString *duid = [dic objectForKey:DUID];
//    NSNumber *rights = [dic objectForKey:RIGHTS];
//    NSString *userId = [dic objectForKey:USERID];
//    NSNumber *evalType = [dic objectForKey:EVALTYPE];
//    NSArray *categoriesArray = [dic objectForKey:CATEGORIES_ARRAY];
    
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    NSMutableArray *labsArray = [[NSMutableArray alloc] init];
    NSMutableArray *labsArray1 = [[NSMutableArray alloc] init];
    
    NXClassificationLab *lab = [[NXClassificationLab alloc] init];
    lab.name = @"jack";
    lab.defaultLab = YES;
    
    NXClassificationLab *lab1 = [[NXClassificationLab alloc] init];
    lab1.name = @"henrry";
    lab1.defaultLab = NO;
    
    NXClassificationLab *lab2 = [[NXClassificationLab alloc] init];
    lab2.name = @"stepanoval";
    lab2.defaultLab = YES;
    
    NXClassificationLab *lab3 = [[NXClassificationLab alloc] init];
    lab3.name = @"eren";
    lab3.defaultLab = NO;
    
    [labsArray addObject:lab];
    [labsArray addObject:lab1];
    
    [labsArray1 addObject:lab2];
    [labsArray1 addObject:lab3];
    
    NXClassificationCategory *category = [[NXClassificationCategory alloc] init];
    category.name = @"itar";
    category.multiSelect = YES;
    category.mandatory = YES;
    category.selectedLabs = [labsArray copy];
    
    NXClassificationCategory *category1 = [[NXClassificationCategory alloc] init];
    category1.name = @"identify";
    category1.multiSelect = YES;
    category1.mandatory = NO;
    category1.selectedLabs = [labsArray1 copy];
    
    [categoryArray addObject:category];
    [categoryArray addObject:category1];
    
    NSDictionary *paraDic = @{MEMBER_SHIP_ID:@"nextlabs@skydrm.com",
                              RESOURCE_NAME:@"i like it",
                              DUIDKEY:@"12312312312",
                              RIGHTS:[NSNumber numberWithInteger:1],
                              USERID:@"stepanoval.huang@gmail.com",
                              EVALTYPE:[NSNumber numberWithInteger:2],
                              CATEGORIES_ARRAY:[categoryArray copy],
                              };
    
    [_request10 requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        XCTAssertNil(error, @"error not nil");
        [self.expectation fulfill];
    }];
    
//    [_request9 requestWithObject:prjectId Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
//        XCTAssertNil(error, @"error not nil");
//        [self.expectation fulfill];
//
//    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}

@end
