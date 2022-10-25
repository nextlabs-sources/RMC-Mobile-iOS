//
//  NXSetPasswordAPI.m
//  nxrmc
//
//  Created by nextlabs on 12/16/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSetPasswordAPI.h"

#import "NXCommonUtils.h"
#import "NXLProfile.h"
@interface NXSetPasswordAPI()

@property(nonatomic, strong) NSString *nonce;
@property(nonatomic, strong) NSString *captcha;

@end

@implementation NXSetPasswordAPI

- (instancetype)initWithNonce:(NSString *)nonce captcha:(NSString *)captcha {
    if (self = [super init]) {
        self.nonce = nonce;
        self.captcha = captcha;
    }
    return self;
}

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"rs/usr/forgotPassword"];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *body = [NSString stringWithFormat:@"email=%@&nonce=%@&captcha=%@",[NXLoginUser sharedInstance].profile.email, self.nonce, self.captcha];
    ;
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXSuperRESTAPIResponse *model = [[NXSuperRESTAPIResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end
