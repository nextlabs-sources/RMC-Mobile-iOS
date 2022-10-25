//
//  NXRouterLoginPageURL.m
//  nxrmc
//
//  Created by Kevin on 16/6/29.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXRouterLoginPageURL.h"
#import "NXCommonUtils.h"
#import "NXRMCDef.h"

@interface NXRouterLoginPageURL ()
{
    NSString* tenantName;
}

@end

@implementation NXRouterLoginPageURL

-(instancetype) initWithRequest:(NSString *)tenant
{
    if (self = [super init]) {
        tenantName = tenant;
    }
    
    return self;
}

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *userEnteredServerUrl = object;
        NSString *url;
        if (tenantName && ![tenantName isEqualToString:@""]) {
            url= [NSString stringWithFormat:@"%@/%@/%@",userEnteredServerUrl
                  , @"router/rs/q/tokenGroupName", tenantName];
            
            [[NSUserDefaults standardUserDefaults] setObject:tenantName forKey:SPECIFIC_TENANT];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            url= [NSString stringWithFormat:@"%@/%@",userEnteredServerUrl
                  , @"router/rs/q/defaultTenant"];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SPECIFIC_TENANT];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
        
        [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXRouterLoginPageURLResponse *response = [[NXRouterLoginPageURLResponse alloc] init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  response;
    };
    return analysis;
}

@end


@implementation NXRouterLoginPageURLResponse

- (void)analysisResponseStatus:(NSData *)responseData {
    [self parseRouterLoginResponseJsonData:responseData];
}

- (void)parseRouterLoginResponseJsonData:(NSData *)responseData {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
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
        if ([results objectForKey:@"server"]) {
            self.loginPageURLstr = [results objectForKey:@"server"];
            [NXCommonUtils updateRMSAddress:self.loginPageURLstr];
            NSString *specificTenant = [[NSUserDefaults standardUserDefaults] objectForKey:SPECIFIC_TENANT];
            if (specificTenant.length > 0) {
                   self.loginPageURLstr = [NSString stringWithFormat:@"%@/rs/tenant?tenant=%@", self.loginPageURLstr,specificTenant];
            }
        }
    }
}

@end
