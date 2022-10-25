//
//  NXProjectRemoveMemberAPI.m
//  nxrmc
//
//  Created by xx-huang on 26/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectRemoveMemberAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@implementation NXProjectRemoveMemberAPIRequest

/**
 Request Object Format Is Just Like Follows:

 {
     "parameters":
     {
     "memberId": 10
     }
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSError *error;
        
        NSString *memberId = object[MEMBER_ID];
        NSString *projectId = object[PROJECT_ID];
        
        NSDictionary *jDict = @{@"parameters":@{@"memberId":memberId}};
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/members/remove",[NXCommonUtils currentRMSAddress],projectId]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 Produces: application/json
 
 {
 "statusCode": 204,
 "message": "Member successfully removed",
 "serverTime": 1484060079827
 }
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectRemoveMemberAPIResponse *response = [[NXProjectRemoveMemberAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
        }
        
        return response;
    };
    
    return analysis;
}

@end

@implementation NXProjectRemoveMemberAPIResponse

@end

