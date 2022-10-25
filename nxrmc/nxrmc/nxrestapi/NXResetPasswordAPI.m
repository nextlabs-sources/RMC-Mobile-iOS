//
//  NXResetPasswordAPI.m
//  nxrmc
//
//  Created by EShi on 3/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXResetPasswordAPI.h"
#import "NSString+Codec.h"

@implementation NXResetPasswordRequest

- (NSMutableURLRequest *)generateRequestObject:(id)object
{
    if(!self.reqRequest){
        NSAssert([object isKindOfClass:[NSDictionary class]], @"NXResetPasswordRequest object should be NSDictionary");
        NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/usr/changePassword", [NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        request.HTTPMethod = @"POST";
        
        NSString *oldPSW = ((NSDictionary *)object)[NXResetPasswordRequestOldPSWKey];
        NSString *newPSW = ((NSDictionary *)object)[NXResetPasswordRequestNewPSWKey];
        NSDictionary *bodyDict = @{@"parameters":@{@"oldPassword":[oldPSW MD5], @"newPassword":[newPSW MD5]}};
        
        NSData *bodyData = [bodyDict toJSONFormatData:nil];
        request.HTTPBody = bodyData;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis retAnalysis = (id)^(NSString *retString, NSError *error){
        NXResetPasswordResponse *response = [[NXResetPasswordResponse alloc] init];
        NSData *retData = [retString dataUsingEncoding:NSUTF8StringEncoding];
        if (retData) {
            [response analysisResponseData:retData];
            if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NSData *resultData=[retString dataUsingEncoding:NSUTF8StringEncoding];
                if (resultData) {
                    NSDictionary *returnDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                    NSDictionary *extraDic = returnDic[@"extra"];
                    if (extraDic) {
                        NSString *ttl = extraDic[@"ttl"];
                        response.ttl = [NSNumber numberWithLongLong:ttl.integerValue];
                        response.ticket = extraDic[@"ticket"];
                    }
                }
            }
        }
        return response;
    };
    return retAnalysis;
}
@end

@implementation NXResetPasswordResponse

- (void)analysisResponseData:(NSData *)responseData
{
    [super analysisResponseStatus:responseData];
}

@end
