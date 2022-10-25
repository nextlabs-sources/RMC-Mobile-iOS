//
//  NXGetTenantPreferenceAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/1/15.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXGetTenantPreferenceAPI.h"

@implementation NXGetTenantPreferenceAPIRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    if (!self.reqRequest) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/tenant/v2/%@",[NXCommonUtils currentRMSAddress],object]]];
         [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXGetTenantPreferenceAPIResponse *response = [[NXGetTenantPreferenceAPIResponse alloc]init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        NSError *parseError = nil;
        NSDictionary *jsonDict = [[returnData dataUsingEncoding:NSUTF8StringEncoding] toJSONDict:&parseError];
        NSDictionary *results = jsonDict[@"extra"];
        if (results) {
            response.perenceDic = results;
        }
        return  response;
    };
    return analysis;
}
@end

@implementation NXGetTenantPreferenceAPIResponse

@end
