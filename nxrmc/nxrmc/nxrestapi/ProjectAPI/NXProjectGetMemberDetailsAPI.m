//
//  NXProjectGetMemberDetailsAPI.m
//  nxrmc
//
//  Created by xx-huang on 26/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectGetMemberDetailsAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@implementation NXProjectGetMemberDetailsAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        
        NSString *memberId = object[MEMBER_ID];
        NSString *projectId = object[PROJECT_ID];
        
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/member/%@",[NXCommonUtils currentRMSAddress],projectId,memberId]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
    
        [request setHTTPMethod:@"GET"];
        [request setValue:@"close" forHTTPHeaderField:@"Connection"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 Produces: application/json
 
 {
 "statusCode": 200,
 "message": "OK",
 "serverTime": 1484905488932,
 "results": {
     "detail": {
         "userId": 1,
         "displayName": "fengchao1993@gmail.com",
         "email": "fengchao1993@gmail.com",
         "creationTime": 1470290028965,
         "inviterDisplayName": "Xifeng",
         "inviterEmail": "xifeng.zheng@nextlabs.com"
               }
            }
 } */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectGetMemberDetailsAPIResponse *response = [[NXProjectGetMemberDetailsAPIResponse alloc] init];
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
            NSDictionary *detailDic = resultDic[@"detail"];
            
            if (detailDic.count > 0)
            {
                NXProjectMemberModel *memberModel = [[NXProjectMemberModel alloc] initWithDictionary:detailDic];
                
                response.memberDetail = memberModel;
            }

        }
        
        return response;
    };
    
    return analysis;
}

@end

@implementation NXProjectGetMemberDetailsAPIResponse

- (NXProjectMemberModel *)memberDetail
{
    if (!_memberDetail)
    {
        _memberDetail = [[NXProjectMemberModel alloc] init];
    }
    return _memberDetail;
}
@end
