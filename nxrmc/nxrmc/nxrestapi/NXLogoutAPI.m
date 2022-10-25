//
//  NXLogoutAPI.m
//  nxrmc
//
//  Created by 时滕 on 2020/3/4.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXLogoutAPI.h"

@implementation NXLogoutRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSURL *apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/usr/logout",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        req.HTTPMethod = @"GET";
        self.reqRequest = req;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXLogoutResponse *apiResponse=[[NXLogoutResponse alloc]init];
        
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
        }
        return apiResponse;
        
    };
    return analysis;
}
@end

@implementation NXLogoutResponse



@end
