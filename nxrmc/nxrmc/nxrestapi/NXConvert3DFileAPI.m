//
//  NXConvert3DFileRequest.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXConvert3DFileAPI.h"

@implementation NXConvert3DFileModel
@end

@interface NXConvert3DFileRequest()

@end

@implementation NXConvert3DFileRequest

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (!self.reqRequest) {
        if (![object isKindOfClass:[NXConvert3DFileModel class]]) {
            return nil;
        }
        NXConvert3DFileModel *model = (NXConvert3DFileModel *)object;

        NSString *rmsAddress = [NXCommonUtils currentRMSAddress];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[model.originData length]];

        NSString *url = [NSString stringWithFormat:@"%@/rs/convert/v2/file?fileName=%@&toFormat=hsf", rmsAddress, model.fileName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:model.originData];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnString, NSError* error){
        NSData *returnData = nil;
        if ([returnString isKindOfClass:[NSData class]]) {
            returnData = (NSData *)returnString;
        } else {
            returnData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        }
        NXConvert3DFileResponse *response = [[NXConvert3DFileResponse alloc] init];
        response.data = returnData;
        return response;
    };
    return analysis;
}
@end

@implementation NXConvert3DFileResponse

@end
