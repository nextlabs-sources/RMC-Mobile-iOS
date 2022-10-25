//
//  NXSharedWithMeReshareFileAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSharedWithMeReshareFileAPI.h"
#import "NXSharedWithMeFile.h"
#import "NXShareWithMeReshareResponseModel.h"
@implementation NXSharedWithMeReshareFileAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isMemberOfClass:[NXSharedWithMeFile class]]) {
            NXSharedWithMeFile *fileModel = (NXSharedWithMeFile *)object;
            if (!fileModel.shareWith) {
                return nil;
            }
            NSDictionary *parameterDic = @{@"parameters":@{@"transactionId":fileModel.transactionId,@"transactionCode":fileModel.transactionCode,@"shareWith":fileModel.shareWith,@"comment":fileModel.reshareComment}}.copy;
            
            NSData *parameterData = [NSJSONSerialization dataWithJSONObject:parameterDic options:NSJSONWritingPrettyPrinted error:nil];
            
            NSURL *apiUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/reshare",[NXCommonUtils currentRMSAddress]]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:apiUrl];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:parameterData];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            self.reqRequest = request;
            
        }
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error) {
        NXSharedWithMeReshareFileAPIResponse *response = [[NXSharedWithMeReshareFileAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (returnData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dict[@"results"];
            NXShareWithMeReshareResponseModel *model = [[NXShareWithMeReshareResponseModel alloc]initWithNSDictionary:resultsDic];
            response.responseModel = model;
        }
        return response;
    };
    return analysis;
}

@end


@implementation NXSharedWithMeReshareFileAPIResponse



@end
