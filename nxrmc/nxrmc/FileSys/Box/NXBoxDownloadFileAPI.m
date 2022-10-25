//
//  NXBoxDownloadFileAPI.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 12/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXBoxDownloadFileAPI.h"

@implementation NXBoxDownloadFileRequest
-(NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        if (object)
        {
            NXFileBase *file = (NXFileBase *)object;
            NSString *downloadString = [NSString stringWithFormat:@"https://api.box.com/2.0/files/%@/content", file.fullServicePath];
            NSURL *apiURL = [[NSURL alloc] initWithString:downloadString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            self.reqRequest = request;
            
        }
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        
        NXBoxDownloadFileResponse *response = [[NXBoxDownloadFileResponse alloc] init];
        if(error == nil && returnData) {
            if ([returnData isKindOfClass:[NSData class]]) {
                response.fileData = (NSData *)returnData;
            }else {
                response.fileData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
            }
            
        }else if(error && error.code == 401) {
            response.isAccessTokenExpireError = YES;
        }
        return response;
    };
    
    return analysis;
}

@end

#pragma mark -NXLFetchLogInfoParameterModelResponse

@implementation NXBoxDownloadFileResponse

@end

