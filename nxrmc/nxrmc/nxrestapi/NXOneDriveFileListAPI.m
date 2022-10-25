//
//  NXOneDriveFileListAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 25/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOneDriveFileListAPI.h"
#import "NXOneDriveFileItem.h"
@implementation NXOneDriveFileListAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSDictionary *dict = (NSDictionary*)object;
        NSString *fileId = dict[@"fileId"];
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://api.onedrive.com/v1.0/drive/items/%@/children",fileId]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];;
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXOneDriveFileListAPIResponse *apiResponse = [[NXOneDriveFileListAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            if (!error) {
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                NSMutableArray *itemArray = [NSMutableArray array];
                NSArray *drvieFiles = returnDic[@"value"];
                for (NSDictionary *fileDict in drvieFiles) {
                    NXOneDriveFileItem *item = [[NXOneDriveFileItem alloc] initWithDictionary:fileDict];
                    [itemArray addObject:item];
                }
                apiResponse.fileList = itemArray;
            }else if (error.code == 401) {
                apiResponse.isAccessTokenExpireError = YES;
            }
        }
        return apiResponse;
    };
    return analysis;
}
@end
@implementation NXOneDriveFileListAPIResponse

- (id)init
{
    self = [super init];
    if (self) {
        _fileList = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
