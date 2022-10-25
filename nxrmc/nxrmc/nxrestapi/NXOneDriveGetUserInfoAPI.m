//
//  NXOneDriveGetUserInfoAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOneDriveGetUserInfoAPI.h"

@implementation NXOneDriveGetUserInfoAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSURL *url = [[NSURL alloc]initWithString:@"https://api.onedrive.com/v1.0/drive"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];;
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXOneDriveGetUserInfoAPIResponse *apiResponse = [[NXOneDriveGetUserInfoAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (!error) {
            if (resultData) {
                [apiResponse analysisResponseStatus:resultData];
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                apiResponse.userInfo = returnDic;
            }
        }else if (error.code == 401) {
            apiResponse.isAccessTokenExpireError = YES;
        }
        return apiResponse;
    };
    return analysis;
}
@end
@implementation NXOneDriveGetUserInfoAPIResponse
@end
