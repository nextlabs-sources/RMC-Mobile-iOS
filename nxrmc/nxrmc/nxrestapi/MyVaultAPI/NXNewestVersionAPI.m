//
//  NXNewestVersionAPI.m
//  nxrmc
//
//  Created by helpdesk on 5/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//https://itunes.apple.com/cn/app/skydrm/id1148196131?mt=8

#import "NXNewestVersionAPI.h"

@implementation NXNewestVersionAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSString *urlStr = nil;
        if (buildFromSkyDRMEnterpriseTarget) {
            urlStr = @"https://itunes.apple.com/lookup?id=1440353931";
        }else{
            urlStr = @"https://itunes.apple.com/lookup?id=1148196131";
        }
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [request setHTTPMethod:@"GET"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
    NXNewestVersionAPIResponse *response =[[NXNewestVersionAPIResponse alloc]init];
        if (returnData) {
            NSData *resultData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
            [response analysisResponseStatus:resultData];
            NSError *aerror;
            id jsonObject =[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:&aerror];
            NSDictionary *appInfoDic=(NSDictionary*)jsonObject;
            NSArray *infoContents=[appInfoDic objectForKey:@"results"];
            NSString *version =[[infoContents objectAtIndex:0]objectForKey:@"version"];
            response.version=version;
        }
        return response;
        
    };
    return analysis;
}
@end
@implementation NXNewestVersionAPIResponse

@end
