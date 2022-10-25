//
//  NXGetFileMetadataAPI.m
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXGetWorkSpaceFileMetadataAPI.h"
#import "NXWorkSpaceItem.h"
@implementation NXGetWorkSpaceFileMetadataRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXFileBase class]], @"NXGetFileMetadataRequest model should be NXFileBase");
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/file/metadata", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        NSDictionary *parametersDict = @{@"parameters":@{@"pathId":((NXFileBase *)object).fullServicePath}};
        [self.reqRequest setHTTPBody:[parametersDict toJSONFormatData:nil]];
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return self.reqRequest;
}


- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXGetWorkSpaceFileMetadataResponse *response = [[NXGetWorkSpaceFileMetadataResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseData:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        }
        return response;
    };
    return analysis;
}


@end

@implementation NXGetWorkSpaceFileMetadataResponse
- (void)analysisResponseData:(NSData *)responseData {
    [self analysisResponseStatus:responseData];
    if (self.rmsStatuCode == 200) {
        NSError *error = nil;
        NSDictionary *responseDict = [responseData toJSONDict:&error];
        if (error == nil) {
            NSDictionary *resultsDict = responseDict[@"results"];
            if (resultsDict) {
                NSDictionary *fileInfoDict = resultsDict[@"fileInfo"];
                NXWorkSpaceFile *spaceFile = [[NXWorkSpaceFile alloc] initWithDictionary:fileInfoDict];
                self.workSpaceFile = spaceFile;
            }
        }
    }
}

@end
