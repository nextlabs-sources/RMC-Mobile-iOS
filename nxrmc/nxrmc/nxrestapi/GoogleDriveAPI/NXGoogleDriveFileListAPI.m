//
//  NXGoogleDriveFileListAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 06/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGoogleDriveFileListAPI.h"
#import "NXCommonUtils.h"
#import "NXGoogleDriveFileListQuery.h"

@implementation NXGoogleDriveFileListAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NXGoogleDriveFileListQuery *query = [NXGoogleDriveFileListQuery query];
        NSString *path = object;
        query.q = [NSString stringWithFormat:@"trashed = false and '%@' IN parents",path];
        NSString* encodedString = [query.q stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files?corpora=%@&fields=%@&includeTeamDriveItems=%@&orderBy=%@&spaces=%@&supportsTeamDrives=%@&q=%@&pageSize=%lu",query.corpora,query.fields,@"false",query.orderBy,query.spaces,@"false",encodedString,query.pageSize]];
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
        NXGoogleDriveFileListAPIResponse *apiResponse = [[NXGoogleDriveFileListAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            if (error == nil) {
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                
                NSArray *filseArray = returnDic[@"files"];
                for (NSDictionary *fileItemDic in filseArray) {
                    @autoreleasepool {
                        if (fileItemDic.count > 0) {
                            NXGoogleDriveFileBase *item = [[NXGoogleDriveFileBase alloc] init];
                            item.fileId = fileItemDic[@"id"];
                            item.name = fileItemDic[@"name"];
                            item.kind = fileItemDic[@"kind"];
                            item.mimeType = fileItemDic[@"mimeType"];
                            
                            NXGoogleDateTime *GTime = [NXGoogleDateTime dateTimeWithRFC3339String:fileItemDic[@"modifiedTime"]];
                            item.lastModifiedTime = GTime.date;
                            item.size = fileItemDic[@"size"];
                            [apiResponse.files addObject:item];
                        }
                    }
                }
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

@implementation NXGoogleDriveFileListAPIResponse

- (id)init
{
    self = [super init];
    if (self) {
        _files = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NXGoogleDriveFileListAPIResponse *response = [[[self class] allocWithZone:zone] init];
    response.kind = self.kind;
    response.nextPageToken = self.nextPageToken;
    response.files = self.files;
    response.incompleteSearch = self.incompleteSearch;
    return response;
}

@end
