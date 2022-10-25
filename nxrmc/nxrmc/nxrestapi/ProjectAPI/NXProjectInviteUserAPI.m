//
//  NXProjectInviteUserAPI.m
//  nxrmc
//
//  Created by xx-huang on 20/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectInviteUserAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@implementation NXProjectInviteUserAPIRequest

/**
 Request Object Format Is Just Like Follows:
 
 {
 "parameters":
 {
 "emails": ["example@gmail.com"]
 }
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSError *error;
        
        NSArray *emails = object[EMAILS];
        NSString *projectId = object[PROJECT_ID];
        
        NSString *invitationMsg = object[INVITATION_MSG];
        NSDictionary *jDict = nil;
        if ([invitationMsg isEqualToString:@""]) {
             jDict = @{@"parameters":@{@"emails":emails}};
        }else {
            jDict = @{@"parameters":@{@"emails":emails,@"invitationMsg":invitationMsg}};
        }
    
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/invite",[NXCommonUtils currentRMSAddress],projectId]];
        
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
 "statusCode": 200,
 "message": "OK",
 "serverTime": 1484060079827,
 "results": {
 "alreadyInvited": [],
 "nowInvited": [
 "example@gmail.com"
 ],
 "alreadyMembers": []
 }
 }
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectInviteUserAPIResponse *response = [[NXProjectInviteUserAPIResponse alloc] init];
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
            
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultDic = returnDic[@"results"];
            
//            if (resultDic.count > 0)
//            {
//                // TODO
//            }
            response.resultsDic = resultDic;
        }
        
        return response;
    };
    
    return analysis;
}

@end

@implementation NXProjectInviteUserAPIResponse

@end
