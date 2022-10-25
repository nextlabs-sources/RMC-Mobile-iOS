//
//  NXProjectDeleteFileAPI.m
//  nxrmc
//
//  Created by xx-huang on 16/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectDeleteFileAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@implementation NXProjectDeleteFileAPIRequest

/**
 Request Object Format Is Just Like Follows:
 
 "parameters":
 {
 "path": "/folder/"
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSError *error;
        
        NSString *filePath = object[FILE_PATH];
        NSString *projectId = object[PROJECT_ID];
        
        NSDictionary *jDict = @{@"parameters":@{@"pathId":filePath}};
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/delete",[NXCommonUtils currentRMSAddress],projectId]];
        
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
 "serverTime": 1477623263276,
 "results": {
 "path": "/folder/",
 "name": "folder"
 }
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
       NXProjectDeleteFileAPIResponse *response = [[NXProjectDeleteFileAPIResponse alloc] init];
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
            
            if (resultDic.count > 0)
            {
                response.path = [resultDic objectForKey:@"path"];
                response.name = [resultDic objectForKey:@"name"];
            }
        }
        
        return response;
    };
    
    return analysis;
}

@end

@implementation NXProjectDeleteFileAPIResponse

-(instancetype)init
{
    self = [super init];
    if (self) {
        _path = @"";
        _name = @"";
    }
    return self;
}
@end
