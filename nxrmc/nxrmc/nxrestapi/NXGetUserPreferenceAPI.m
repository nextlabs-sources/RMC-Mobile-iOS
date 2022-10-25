//
//  NXGetUserPreferenceAPI.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGetUserPreferenceAPI.h"
#import "NSString+NXExt.h"
#import "NXLFileValidateDateModel.h"
@implementation NXGetUserPreferenceRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    //    NSData *bodyData = [self.requestModel generateBodyData];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"rs/usr/preference"]]];
    [request setHTTPMethod:@"GET"];
   
    return request;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXGetUserPreferenceResponse *response = [[NXGetUserPreferenceResponse alloc]init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        NSError *parseError = nil;
        NSDictionary *jsonDict = [[returnData dataUsingEncoding:NSUTF8StringEncoding] toJSONDict:&parseError];
        NSDictionary *results = jsonDict[@"results"];
        if (results) {
            NSString *watermark = results[@"watermark"];
            response.watermarkPreference = [watermark parseWatermarkWords];
            NSDictionary *expiry = results[@"expiry"];
            response.validateDatePreference = [[NXLFileValidateDateModel alloc]initWithDictionaryFromRMS:expiry];
        }
        return  response;
    };
    return analysis;
}

@end

@implementation NXGetUserPreferenceResponse

@end
