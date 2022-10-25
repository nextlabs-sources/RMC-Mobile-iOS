//
//  NXGoogleDriveDownloadAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 06/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGoogleDriveDownloadAPI.h"

@implementation NXGoogleDriveDownloadAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSString *fileId = object;
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?alt=media",fileId]];
        if (_isGoogleDoc == YES) {
            apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@/export?mimeType=%@",fileId,self.mimeType]];
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXGoogleDriveDownloadAPIResponse *apiResponse = [[NXGoogleDriveDownloadAPIResponse alloc]init];
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
            if (error == nil) {
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
@end

@implementation NXGoogleDriveDownloadAPIResponse
@end
