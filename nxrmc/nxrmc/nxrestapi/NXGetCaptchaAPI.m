//
//  NXGetCaptchaAPI.m
//  nxrmc
//
//  Created by nextlabs on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGetCaptchaAPI.h"
#import "NXCommonUtils.h"

@implementation NXGetCaptchaAPI

- (NSMutableURLRequest *)generateRequestObject:(id)object {
//    NSData *bodyData = [self.requestModel generateBodyData];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"rs/usr/captcha"]]];
    [request setHTTPMethod:@"GET"];
    [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
    
    return request;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXGetCaptchaResponse *model = [[NXGetCaptchaResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end

@implementation NXGetCaptchaResponse

- (void)analysisResponseStatus:(NSData *)responseData {
    [self parseEncrypTokenResponseJsonData:responseData];
}

- (void)parseEncrypTokenResponseJsonData:(NSData *)data {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"parse data failed:%@", error.localizedDescription);
        return;
    }
    
    if ([result objectForKey:@"statusCode"]) {
        self.rmsStatuCode = [[result objectForKey:@"statusCode"] integerValue];
    }
    
    if ([result objectForKey:@"message"]) {
        self.rmsStatuMessage = [result objectForKey:@"message"];
    }
    
    if ([result objectForKey:@"results"]) {
        NSDictionary *results = [result objectForKey:@"results"];
        if ([results objectForKey:@"captcha"]) {
            self.captcha = [results objectForKey:@"captcha"];
        }
        if ([results objectForKey:@"nonce"]) {
            self.nonce = [results objectForKey:@"nonce"];
        }
    }
}

@end
