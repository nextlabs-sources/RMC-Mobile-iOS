//
//  NXPerformPolicyEvaluationAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 15/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"
#import "NXClassificationCategory.h"
#import "NXClassificationLab.h"

#define MEMBER_SHIP_ID    @"membershipId"
#define RESOURCE_NAME     @"resourceName"
#define DUIDKEY           @"duid"
#define RIGHTS            @"rights"
#define USERID            @"id"
#define EVALTYPE          @"evalType"
#define CATEGORIES_ARRAY  @"categories_array"
#define EVAL_NAME  @"name"
@class NXLRights;
@interface NXPerformPolicyEvaluationAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end

@interface NXPerformPolicyEvaluationAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NSArray *adhocObligations;
@property (nonatomic, strong) NSArray *obligations;
@property (nonatomic, strong) NSNumber *rights;
@property (nonatomic, strong) NXLRights *evaluationRight;
@end
