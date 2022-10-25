//
//  NXOneDriveBigFileUploadAPI.m
//  nxrmc
//
//  Created by 时滕 on 2020/5/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOneDriveBigFileUploadAPI.h"

@implementation NXOneDriveBigFileUploadRequest

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (!self.reqRequest) {
        NSDictionary *modelDict = (NSDictionary *)object;
        NSString *uploadFilePath = modelDict[ONE_DRIVE_BIG_FILE_UPLOAD_FILE_KEY];
        NSURL *uploadSessionURL = modelDict[ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_URL_KEY];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:uploadSessionURL];
        [req setHTTPMethod:@"PUT"];
        [req setHTTPBody:[NSData dataWithContentsOfFile:uploadFilePath]];
        self.reqRequest = req;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXOneDriveBigFileUploadResponse *response = [[NXOneDriveBigFileUploadResponse alloc] init];
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:resultData];
        NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
        response.uploadedFile = [[NXOneDriveFileItem alloc] initWithDictionary:returnDic];
        return response;
    };
    return analysis;;
}

@end

@implementation NXOneDriveBigFileUploadResponse


@end
