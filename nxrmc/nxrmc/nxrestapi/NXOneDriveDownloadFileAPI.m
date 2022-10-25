//
//  NXOneDriveDownloadFileAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 25/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOneDriveDownloadFileAPI.h"

@implementation NXOneDriveDownloadFileAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSString *fileId = ((NSDictionary *)object)[@"fileId"];
        NSURL *downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.onedrive.com/v1.0/drive/items/%@/content",fileId]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:downloadURL];;
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXOneDriveDownloadFileAPIResponse *apiResponse = [[NXOneDriveDownloadFileAPIResponse alloc]init];
        if (!error) {
            NSData *contentData = nil;
            if ([returnData isKindOfClass:[NSString class]]) {
                contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
            }else {
                contentData = (NSData*)returnData;
            }
            if (contentData) {
                [apiResponse analysisResponseStatus:contentData];
            }
            apiResponse.fileData = contentData;
        }else if (error.code == 401) {
            apiResponse.isAccessTokenExpireError = YES;
        }
        
        return apiResponse;
    };
    return analysis;
}
@end

@implementation NXOneDriveDownloadFileAPIResponse
- (NSData*)fileData {
    if (!_fileData) {
        _fileData = [[NSData alloc]init];
    }
    return _fileData;
}
@end
