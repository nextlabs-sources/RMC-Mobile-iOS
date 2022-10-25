//
//  NXDropboxDownloadFileAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 07/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDropboxDownloadFileAPI.h"
#import "NXCommonUtils.h"

@implementation NXDropboxDownloadFileAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSString *filePathOrId = object;
        NSDictionary *jDict = @{@"path":filePathOrId};
        NSData *bodyData =  [self jsonDataWithJsonObj:jDict];
        NSString *headerStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://content.dropboxapi.com/2/files/download"]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:headerStr forHTTPHeaderField:@"Dropbox-API-Arg"];
       
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxDownloadFileAPIResponse *apiResponse = [[NXDropboxDownloadFileAPIResponse alloc]init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [apiResponse analysisResponseStatus:contentData];
            if (!error) {
                 apiResponse.rmsStatuCode = 200;
                 apiResponse.fileData = (NSData *)returnData;
            }
            else if (error.code == 401)
            {
                apiResponse.isAccessTokenExpireError = YES;
            }
        }
        
        return apiResponse;
        
    };
    return analysis;
}

- (NSData *)jsonDataWithJsonObj:(id)jsonObj {
    if (!jsonObj) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing dictionary: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}

@end

@implementation NXDropboxDownloadFileAPIResponse
@end
