//
//  NXLoggerAuthentication.m
//  nxrmc
//
//  Created by 时滕 on 2019/11/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXLoggerAuthenticationAPI.h"

@implementation NXLoggerAuthenticateRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSString *loggerURL = (NSString *)object;
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/authenticate", loggerURL]]];
        [self.reqRequest setHTTPMethod:@"POST"];
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        NSDictionary *paramDict = @{@"username":@"ios", @"password":@"iosnext!"};
        NSData *bodyData = [paramDict toJSONFormatData:nil];
        [self.reqRequest setHTTPBody:bodyData];
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    return (id)^(NSString *returnData, NSError *error){
        NXLoggerAuthenticateResponse *response = [[NXLoggerAuthenticateResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if(resultData) {
            NSDictionary *retDict = [resultData toJSONDict:nil];
            response.loggerToken = retDict[@"token"];
        }
        return response;
    };
}
@end

@implementation NXLoggerAuthenticateResponse


@end
