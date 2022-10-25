//
//  NXLoggerRouter.m
//  nxrmc
//
//  Created by 时滕 on 2019/11/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXLoggerRouterAPI.h"

@implementation NXLoggerRouterRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *userEnteredServerUrl = object;
        NSString *url;
        url= [NSString stringWithFormat:@"%@/%@",userEnteredServerUrl
                  , @"router/rs/logger"];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    return (id)^(NSString *returnData, NSError *error){
        NXLoggerRouterResponse *response = [[NXLoggerRouterResponse alloc] init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            if(response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
//                 NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                response.loggerURL = @"https://rms-centos7511.qapf1.qalab01.nextlabs.com:8447/logger";
            }
            
        }
        return response;
    };
}
@end


@implementation NXLoggerRouterResponse



@end
