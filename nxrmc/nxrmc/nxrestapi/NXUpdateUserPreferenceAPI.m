//
//  NXUpdateUserPreferenceAPI.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXUpdateUserPreferenceAPI.h"
#import "NXLFileValidateDateModel.h"
@implementation NXUpdateUserPreferenceRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    //    NSData *bodyData = [self.requestModel generateBodyData];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"rs/usr/preference"]]];
    [request setHTTPMethod:@"PUT"];
    
    NSDictionary *updatePreferenceDataModel = (NSDictionary *)object;
    NSMutableDictionary *updateInfoDict = [[NSMutableDictionary alloc] init];
    
    NSArray *watermarkArray = updatePreferenceDataModel[kUserPreferenceWatermark];
    if (watermarkArray) {
        NSMutableString *watermarkString = [[NSMutableString alloc] init];
        for (NXWatermarkWord *watermark in watermarkArray) {
            [watermarkString appendString:[watermark watermarkPolicyString]];
        }
        [updateInfoDict setObject:watermarkString forKey:@"watermark"];
    }
    
    NXLFileValidateDateModel *validateDateModel = updatePreferenceDataModel[kUserPreferenceExpireKey];
    if (validateDateModel) {
        NSDictionary *validateDateInfoDict = [validateDateModel getRMSRESTAPIPerferenceFormatDictionary];
        [updateInfoDict setObject:validateDateInfoDict forKey:@"expiry"];
    }
    
    NSDictionary *updateParametersDict = @{@"parameters":updateInfoDict};
    NSData *bodyData = [updateParametersDict toJSONFormatData:nil];
    [request setHTTPBody:bodyData];
    return request;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        NXUpdateUserPreferenceResponse *response = [[NXUpdateUserPreferenceResponse alloc]init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return response;
    };
    
    
    return analysis;
}
@end

@implementation NXUpdateUserPreferenceResponse

@end
