//
//  NXOneDriveSmallFileUploadRequest.m
//  nxrmc
//
//  Created by 时滕 on 2020/5/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOneDriveSmallFileUploadAPI.h"
#import "NSString+Utility.h"

@implementation NXOneDriveSmallFileUploadRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NSDictionary class]], @"NXOneDriveSmallFileUploadRequest model should be NSDictionary");
        NSDictionary *modelDict = (NSDictionary *)object;
        NXFolder *parentFolder = modelDict[ONE_DRIVE_SMALL_UPLOAD_PARENT_FOLDER_KEY];
        NSString *uploadFileName = modelDict[ONE_DRIVE_SMALL_UPLOAD_FILE_NAME_KEY];
        NSString *uploadFilePath =modelDict[ONE_DRIVE_SMALL_UPLOAD_FILE_LOCAL_PATH_KEY];
        NSString *urlStr = [[NSString stringWithFormat:@"https://api.onedrive.com/v1.0/drive/items/%@:/%@:/content", parentFolder.fullServicePath, uploadFileName] toHTTPURLString];
        NSURL *smallFileUploadURL = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:smallFileUploadURL];
        [request setHTTPBody:[NSData dataWithContentsOfFile:uploadFilePath]];
        [request setHTTPMethod:@"PUT"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

-(Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXOneDriveSmaillFileUploadResponse *response =[[NXOneDriveSmaillFileUploadResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            if (!error) {
                NSDictionary *fileDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                NXOneDriveFileItem *item = [[NXOneDriveFileItem alloc] initWithDictionary:fileDict];
                response.uploadedFile = item;
            }
        }
        return response;
    };
    return analysis;
}

@end


@implementation NXOneDriveSmaillFileUploadResponse


@end
