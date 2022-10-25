//
//  NXMyDriveFileDownloadAPI.m
//  nxrmc
//
//  Created by helpdesk on 2/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXMyDriveFileDownloadAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
@implementation NXMyDriveFileDownloadAPI
-(NSURLRequest *) generateRequestObject:(id) object {
    if (self.reqRequest==nil) {
    NSDictionary *jsonDict = @{@"parameters":object};
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/myDrive/download",[NXCommonUtils currentRMSAddress]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
    [request setHTTPBody:bodyData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
          self.reqRequest=request;
}
    return self.reqRequest;
}
- (Analysis)analysisReturnData{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXMyDriveFileDownloadAPIResponse *response =[[NXMyDriveFileDownloadAPIResponse alloc]init];
        if(error.code == NXRMS_ERROR_CODE_EMPTY_CONTENT){
            response.resultData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
            return response;
        }

        NSData *contentData=nil;
        if ([returnData isKindOfClass:[NSString class]]) {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }else {
            contentData =(NSData*)returnData;
        }
        

    if (contentData) {
            [response analysisResponseStatus:contentData];
        }
        response.resultData=contentData;
        return response;
        
    };
    return analysis;
}


@end
@implementation NXMyDriveFileDownloadAPIResponse
- (NSData*)resultData {
    if (!_resultData) {
        _resultData=[[NSData alloc]init];
    }
    return _resultData;
}

@end
