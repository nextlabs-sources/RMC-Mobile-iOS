//
//  NXGetProfileAPI.m
//  nxrmc
//
//  Created by nextlabs on 12/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGetProfileAPI.h"
#import "NXCommonUtils.h"
#import "NXLProfile.h"
@implementation NXGetProfileAPI

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"rs/usr/v2/profile"]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NXLoginUser sharedInstance].profile.ticket forHTTPHeaderField:@"ticket"];
    [request setValue:[NXLoginUser sharedInstance].profile.userId forHTTPHeaderField:@"userId"];
    [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
    
    return request;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXGetProfileResponse *model = [[NXGetProfileResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end

@implementation NXGetProfileResponse

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
    
    if ([result objectForKey:@"extra"]) {
        self.result = [result objectForKey:@"extra"];
    }
}

@end
