//
//  NXGoogleDriveGetUserInfoAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGoogleDriveGetUserInfoAPI.h"

@implementation NXGoogleDriveGetUserInfoQuery

- (id)init
{
    self = [super init];
    if (self) {
        _fields = @"user(displayName,emailAddress),storageQuota(limit,usage)";
    }
    return self;
}

+ (instancetype)query
{
    NXGoogleDriveGetUserInfoQuery *query = [[NXGoogleDriveGetUserInfoQuery alloc] init];
    return query;
}
@end

@implementation NXGoogleDriveGetUserInfoAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NXGoogleDriveGetUserInfoQuery *query = [NXGoogleDriveGetUserInfoQuery query];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/about?fields=%@",query.fields]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXGoogleDriveGetUserInfoAPIResponse *apiResponse = [[NXGoogleDriveGetUserInfoAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            
            if (!error) {
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                
                NSDictionary *storageQuotaDic = [returnDic objectForKey:@"storageQuota"];
                NSDictionary *userDic = [returnDic objectForKey:@"user"];
                if (storageQuotaDic) {
                    apiResponse.limit = [storageQuotaDic objectForKey:@"limit"];
                    apiResponse.usage = [storageQuotaDic objectForKey:@"usage"];
                }
                
                if (userDic) {
                    apiResponse.displayName = [userDic objectForKey:@"displayName"];
                    apiResponse.emailAddress = [userDic objectForKey:@"emailAddress"];
                }
            }
            else if (error.code == 401)
            {
                apiResponse.isAccessTokenExpireError = YES;
            }
        }
        return apiResponse;
        
    };
    return analysis;
}
@end

@implementation NXGoogleDriveGetUserInfoAPIResponse
@end

