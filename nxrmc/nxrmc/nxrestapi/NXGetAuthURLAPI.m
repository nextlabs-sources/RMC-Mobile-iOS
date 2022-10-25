//
//  NXGetAuthURLAPI.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/15/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGetAuthURLAPI.h"
#import "NXLProfile.h"
@implementation NXGetAuthURLRequest
- (NSURLRequest*) generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSString *rmsRepoType = [NXCommonUtils rmcToRMSRepoType:[NSNumber numberWithInteger:self.repoType]];
        NSDictionary *jsonDict;
        if (self.repoType == kServiceSharepointOnline) {
              jsonDict = @{@"parameters":@{@"type":rmsRepoType, @"name":self.repoName, @"platformId":[NXCommonUtils getPlatformId].stringValue,@"siteURL":self.sharepointOnlineSiteUrl}};
        }else{
              jsonDict = @{@"parameters":@{@"type":rmsRepoType, @"name":self.repoName, @"platformId":[NXCommonUtils getPlatformId].stringValue}};
        }
      
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/repository/authURL",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXGetAuthURLResponse *apiResponse=[[NXGetAuthURLResponse alloc]init];
        
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            NSDictionary *returnDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if(returnDic[@"results"]) {
                NSString *currentRMSAddress = [NXCommonUtils currentRMSAddress];
                currentRMSAddress = [currentRMSAddress stringByDeletingLastPathComponent];
                NSString *authURL = returnDic[@"results"][@"authURL"];
                authURL = [NSString stringWithFormat:@"%@%@", currentRMSAddress, authURL];
//                [request setValue:[NXLoginUser sharedInstance].profile.userId forHTTPHeaderField:@"userId"];
//                [request setValue:[NXLoginUser sharedInstance].profile.ticket forHTTPHeaderField:@"ticket"];
//                [request setValue:[NXCommonUtils getPlatformId].stringValue forHTTPHeaderField:@"platformId"];
//
//                [request setValue:[NXCommonUtils currentTenant] forHTTPHeaderField:@"tenant"];
//                [request setValue:[NXCommonUtils deviceID] forHTTPHeaderField:@"clientId"];
                authURL = [NSString stringWithFormat:@"%@&userId=%@&ticket=%@&platformId=%@&clientId=%@",
                           authURL,
                           [NXLoginUser sharedInstance].profile.userId,
                           [NXLoginUser sharedInstance].profile.ticket,
                           [NXCommonUtils getPlatformId].stringValue,
                           [NXCommonUtils deviceID]];
                apiResponse.authURL = authURL;
            }
        }
        return apiResponse;
        
    };
    return analysis;
}
@end

@implementation NXGetAuthURLResponse

@end
