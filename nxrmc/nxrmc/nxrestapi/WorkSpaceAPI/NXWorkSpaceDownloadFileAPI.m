//
//  NXWorkSpaceDownloadFileAPI.m
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceDownloadFileAPI.h"

@implementation NXWorkSpaceDownloadFileRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil && object) {
        NSNumber *start     = object[START];
        NSNumber *length    = object[LENGTH];
        NSString *filePath  = object[FILE_PATH];
        NSNumber *downloadType = object[DOWNLOAD_TYPE];
        NSDictionary *jDict = nil;
        if ([length integerValue] == 0)
        {
            jDict = @{@"parameters":@{@"pathId":filePath,@"type":downloadType}};
        }
        else
        {
            jDict = @{@"parameters":@{@"pathId":filePath,@"start":start,@"length":length,@"type":downloadType}};
            
        }
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/v2/download", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        NSDictionary *parametersDict = jDict;
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setHTTPBody:[parametersDict toJSONFormatData:nil]];
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXWorkSpaceDownloadFileResponse *response =[[NXWorkSpaceDownloadFileResponse alloc]init];
        NSData *contentData = nil;
        if ([returnData isKindOfClass:[NSString class]]) {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }else {
            contentData =(NSData*)returnData;
        }
        
        if (contentData) {
            [response analysisResponseStatus:contentData];
            response.resultData = contentData;
        }
        if(error){
            response.rmsStatuCode = error.code;
        }else{
            response.rmsStatuCode = 200;
        }
        return response;
        
    };
    return analysis;
}
@end

@implementation NXWorkSpaceDownloadFileResponse

- (NSData*)resultData {
    if (!_resultData) {
        _resultData=[[NSData alloc]init];
    }
    return _resultData;
}

@end
