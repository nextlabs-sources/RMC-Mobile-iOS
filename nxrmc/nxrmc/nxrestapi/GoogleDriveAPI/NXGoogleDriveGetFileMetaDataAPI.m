//
//  NXGoogleDriveGetFileMetaDataAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 28/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGoogleDriveGetFileMetaDataAPI.h"


@implementation NXGoogleDriveGetFileMetaDataQuery
- (id)init
{
    self = [super init];
    if (self) {
        _fields = @"mimeType,id,kind,name,modifiedTime,size";
    }
    return self;
}

+ (instancetype)query
{
    NXGoogleDriveGetFileMetaDataQuery *query = [[NXGoogleDriveGetFileMetaDataQuery alloc] init];
    return query;
}
@end

@implementation NXGoogleDriveGetFileMetaDataAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSString *fileId = object;
        NXGoogleDriveGetFileMetaDataQuery *query = [NXGoogleDriveGetFileMetaDataQuery query];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?fields=%@",fileId,query.fields]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXGoogleDriveGetFileMetaDataAPIResponse *apiResponse = [[NXGoogleDriveGetFileMetaDataAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            if (!error) {
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                apiResponse.mimeType = returnDic[@"mimeType"];
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

@implementation NXGoogleDriveGetFileMetaDataAPIResponse
@end


