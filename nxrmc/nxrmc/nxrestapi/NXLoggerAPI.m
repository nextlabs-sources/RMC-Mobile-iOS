//
//  NXLoggerAPI.m
//  nxrmc
//
//  Created by 时滕 on 2019/11/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXLoggerAPI.h"

@implementation NXLoggerRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/log", [NXCommonUtils getLoggerURL]]]];
        [self.reqRequest setValue:[NXCommonUtils loadLoggerToken] forHTTPHeaderField:@"Authorization"];
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        NSDictionary *dict = @{@"domainName":@"nenxtlabs.com",
                               @"message":@"error in client application",
                               @"type":@1,
                               @"applicationName":@"rmd",
                               @"level":@"ERROR",
                               @"ipAddress":@"10.63.0.208",
                               @"hostName":@"bukom.nextlabs.com"};
        NSData *bodyData = [dict toJSONFormatData:nil];
        [self.reqRequest setHTTPMethod:@"POST"];
        [self.reqRequest setHTTPBody:bodyData];

    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    return (id)^(NSString *returnData, NSError *error){
        NXLoggerResponse *response = [[NXLoggerResponse alloc] init];
//        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        return response;
    };
}
@end

@implementation NXLoggerResponse



@end
