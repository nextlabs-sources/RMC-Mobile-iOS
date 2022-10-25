//
//  NXGetProjectAdminAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2019/4/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXGetProjectAdminAPI.h"

@implementation NXGetProjectAdminAPIRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    if (!self.reqRequest) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/tenant/%@/projectAdmin",[NXCommonUtils currentRMSAddress],object]]];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXGetProjectAdminAPIResponse *response = [[NXGetProjectAdminAPIResponse alloc]init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        NSError *parseError = nil;
        NSDictionary *jsonDict = [[returnData dataUsingEncoding:NSUTF8StringEncoding] toJSONDict:&parseError];
        NSDictionary *results = jsonDict[@"results"];
        if (results) {
            NSArray *projectAdminArr = results[@"projectAdmin"];
            NSMutableArray *tenantAdminArray = [NSMutableArray new];
            NSMutableArray *projectAdminArray = [NSMutableArray new];
            for (NSDictionary *itemDic in projectAdminArr) {
                if (itemDic.count > 0) {
                    NSNumber *isTenantAdmin = itemDic[@"tenantAdmin"];
                    NSString *projectAdminEmail = itemDic[@"email"];
                    if (projectAdminEmail) {
                        [projectAdminArray addObject:projectAdminEmail];
                        if (isTenantAdmin && isTenantAdmin.boolValue == true) {
                            [tenantAdminArray addObject:projectAdminEmail];
                        }
                    }
                }
            }
            response.projectAdminArr = [projectAdminArray copy];
            response.tenantAdminArr = [tenantAdminArray copy];
        }
        return  response;
    };
    return analysis;
}
@end

@implementation NXGetProjectAdminAPIResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        _projectAdminArr = [[NSArray alloc] init];
        _tenantAdminArr = [[NSArray alloc] init];
    }
    return self;
}

@end
