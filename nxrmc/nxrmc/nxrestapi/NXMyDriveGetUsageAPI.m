//
//  NXMyDriveGetUsageAPI.m
//  nxrmc
//
//  Created by EShi on 3/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMyDriveGetUsageAPI.h"
#import "NXLProfile.h"
@implementation NXMyDriveGetUsageRequeset
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (!self.reqRequest) {
        NSURL *reqURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/myDrive/getUsage", [NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:reqURL];
        req.HTTPMethod = @"POST";
        NSDictionary *bodyDict  = @{@"parameters":@{@"userId":@([NXLoginUser sharedInstance].profile.userId.integerValue), @"ticket":[NXLoginUser sharedInstance].profile.ticket}};
        req.HTTPBody = [bodyDict toJSONFormatData:nil];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = req;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXMyDriveGetUsageResponse *response = [[NXMyDriveGetUsageResponse alloc] init];
        NSData *retData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (returnData) {
            [response analysisResponseData:retData];
        }
        return response;
    };
    return analysis;
}
@end



@implementation NXMyDriveGetUsageResponse
- (void)analysisResponseJSONDict:(NSDictionary *)jsonDict
{
    if (jsonDict) {
        if (jsonDict[@"results"]) {
            self.usage = jsonDict[@"results"][@"usage"];
            self.quota = jsonDict[@"results"][@"quota"];
            self.vaultQuota = jsonDict[@"results"][@"vaultQuota"];
            self.myVaultUsage = jsonDict[@"results"][@"myVaultUsage"];
        }
    }
}

@end
