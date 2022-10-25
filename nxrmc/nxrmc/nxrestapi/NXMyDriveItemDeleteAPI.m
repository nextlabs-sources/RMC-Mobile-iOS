//
//  NXMyDriveItemDeleteAPI.m
//  nxrmc
//
//  Created by helpdesk on 9/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXMyDriveItemDeleteAPI.h"
#import "NXCommonUtils.h"
#import "NXLogAPI.h"
@implementation NXMyDriveItemDeleteAPI
-(NSURLRequest *) generateRequestObject:(id) object {
    NSDictionary *jsonDict = @{@"parameters":object};
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/myDrive/delete",[NXCommonUtils currentRMSAddress]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
    [request setHTTPBody:bodyData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.reqRequest=request;
    return  self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error) {
        NXMyDriveItemDeleteAPIResponse *response =[[NXMyDriveItemDeleteAPIResponse  alloc]init];
        NSData *backData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (backData) {
            [response analysisResponseStatus:backData];
            NSDictionary *returnDic =[NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
            NSString *statusCode=[returnDic[@"statusCode"] stringValue];
            if (![statusCode isEqualToString:@"200"]) {
                NSString *message=returnDic[@"message"];
                if (message==nil) {
                    message=@"error";
                    statusCode=@"000";
                }
                response.errorR=[NSError errorWithDomain:message code:[statusCode integerValue] userInfo:nil];
               
            }else{
            NSDictionary *resultDic =returnDic[@"results"];
           [response.deleteItem setValuesForKeysWithDictionary:resultDic];
                   }
        }
        return response;
   
    };
    return analysis;
}
@end
@implementation NXMyDriveItemDeleteAPIResponse

@end
@implementation NXMyDriveDeleteItem

@end
