//
//  NXServiceProviderAPI.m
//  nxrmc
//
//  Created by 时滕 on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXServiceProviderAPI.h"

@implementation NXServiceProviderRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/serviceprovider", [NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
        [req setHTTPMethod:@"GET"];
        self.reqRequest = req;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXServiceProviderResponse *response = [[NXServiceProviderResponse alloc] init];
        if (!error) {
            NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
            [response analysisResponseStatus:resultData];
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (response.rmsStatuCode == 200) {
                response.supportedServiceTypes = [NSMutableArray array];
                NSArray *supportTypes = returnDic[@"results"][@"configuredServiceProviderSettingList"];
                for (NSString *repoType in supportTypes) {
                    if (!([repoType isEqualToString:@"SHAREPOINT_ONLINE"] || [repoType isEqualToString:@"SHAREPOINT_ONPREMISE"])) {
                        NSNumber *rmcRepoType = [NXCommonUtils rmsToRMCRepoType:repoType];
                        if(rmcRepoType){
                         [response.supportedServiceTypes addObject:rmcRepoType];
                        }
                    }
                   
                }
            }
        }else {
            response.supportedServiceTypes = [NSMutableArray arrayWithCapacity:0];
            response.rmsStatuCode = 200;
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXServiceProviderResponse

@end
