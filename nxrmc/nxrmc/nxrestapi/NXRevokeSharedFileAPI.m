//
//  NXRevokeSharedFileAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXRevokeSharedFileAPI.h"

@implementation NXRevokeSharedFileRequest
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/%@/revoke", [NXCommonUtils currentRMSAddress],object]]];
        request.HTTPMethod = @"DELETE";
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXRevokeSharedFileResponse *response = [[NXRevokeSharedFileResponse alloc] init];
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:resultData];
//        NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
        if (response.rmsStatuCode == 200) {
          
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXRevokeSharedFileResponse

@end
