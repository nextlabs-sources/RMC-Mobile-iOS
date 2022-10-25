//
//  NXWorkSpaceDeleteItemAPI.m
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceDeleteItemAPI.h"

@implementation NXWorkSpaceDeleteItemRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXFileBase class]], @"NXWorkSpaceDeleteItemRequest model should be NXFileBase");
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/delete", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        NSDictionary *parametersDict = @{@"parameters":@{@"pathId":((NXFileBase *)object).fullServicePath}};
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setHTTPBody:[parametersDict toJSONFormatData:nil]];
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXWorkSpaceDeleteItemResponse *response = [[NXWorkSpaceDeleteItemResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXWorkSpaceDeleteItemResponse


@end
