//
//  NXOneDriveBigFileUploadCreateSessionAPI.m
//  nxrmc
//
//  Created by 时滕 on 2020/5/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOneDriveBigFileUploadCreateSessionAPI.h"

@implementation NXOneDriveBigFileUploadCreateSessionRequest

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSDictionary *modelDict = (NSDictionary *)object;
        NSString *fileName = modelDict[ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_FILE_NAME_KEY];
        NSString *conflictBehavior = modelDict[ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_CONFLICT_BEHAVIOR_KEY] ?: @"replace";
        NXFolder *targetFolder = modelDict[ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_TARGET_FOLDER_KEY];
        NSString *urlString = [NSString stringWithFormat:@"https://api.onedrive.com/v1.0/drive/items/%@:/%@:/createUploadSession", [targetFolder.fullServicePath toHTTPURLString], [fileName toHTTPURLString]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        NSDictionary *paramDict = @{
            @"@microsoft.graph.conflictBehavior":conflictBehavior,
            @"name":fileName,
        };
        [request setHTTPBody:[paramDict toJSONFormatData:nil]];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXOneDriveBigFileUploadCreateSessionResponse *response = [[NXOneDriveBigFileUploadCreateSessionResponse alloc] init];
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:resultData];
        if (!error) {
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSString *uploadSessionStr = returnDic[@"uploadUrl"];
            response.uploadSessionURL = [NSURL URLWithString:uploadSessionStr];
        }
        return response;
    };
    return analysis;
}

@end

@implementation NXOneDriveBigFileUploadCreateSessionResponse

@end
