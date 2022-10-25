//
//  NXProjectDownloadFileAPI.m
//  nxrmc
//
//  Created by xx-huang on 18/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectDownloadFileAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@implementation NXProjectDownloadFileAPIRequest

/**
 Request Object Format Is Just Like Follows:
 {
     "parameters":
     {
     "start":0,
     "length":1000,
     "path":"/user-guide.2016-12-25-14-23-14.xlsx.nxl"
     }
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSError *error;
        
        NSNumber *start     = object[START];
        NSNumber *length    = object[LENGTH];
        NSString *filePath  = object[FILE_PATH];
        NSString *projectId = object[PROJECT_ID];
        NSNumber *downloadType = object[DOWNLOAD_TYPE];
        NSDictionary *jDict;
        
        if ([length integerValue] == 0)
        {
            jDict = @{@"parameters":@{@"pathId":filePath,@"type":downloadType}};
        }
        else
        {
            jDict = @{@"parameters":@{@"pathId":filePath,@"start":start,@"length":length,@"type":downloadType}};
            
        }
        
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/v2/download",[NXCommonUtils currentRMSAddress],projectId]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXProjectDownloadFileAPIResponse *response =[[NXProjectDownloadFileAPIResponse alloc]init];
        NSData *contentData=nil;
        if ([returnData isKindOfClass:[NSString class]]) {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }else {
            contentData =(NSData*)returnData;
        }
        
        if (contentData) {
            [response analysisResponseStatus:contentData];
        }
        if(error){
            response.rmsStatuCode = error.code;
            response.resultData = nil;
        }else{
            response.rmsStatuCode = 200;
            response.resultData = contentData;
        }
        return response;
        
    };
    return analysis;
}

@end

@implementation NXProjectDownloadFileAPIResponse

- (NSData*)resultData {
    if (!_resultData) {
        _resultData=[[NSData alloc]init];
    }
    return _resultData;
}

@end
