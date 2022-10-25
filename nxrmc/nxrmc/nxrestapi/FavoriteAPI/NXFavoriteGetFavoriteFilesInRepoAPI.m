//
//  NXFavoriteGetFavoriteFilesInRepoAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteGetFavoriteFilesInRepoAPI.h"

@implementation NXFavoriteGetFavoriteFilesInRepoAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NXFileBase *fileBase = object[@"fileBase"];
       // NSString *lastModifiedTime = [NSString stringWithFormat:@"%lld",[self getDateTimeTOMilliSeconds:fileBase.lastModifiedDate]];
       // NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/favorite/%@?lastModified=%@",[NXCommonUtils currentRMSAddress],fileBase.repoId,lastModifiedTime]];
        
         NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/favorite/%@",[NXCommonUtils currentRMSAddress],fileBase.repoId]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 {
 "statusCode":200,
 "message":"Files successfully unmarked as favorite",
 "serverTime":1474591551519
 }
 */

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXFavoriteGetFavoriteFilesInRepoAPIResponse *response = [[NXFavoriteGetFavoriteFilesInRepoAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSArray *markedFavoriteFilesArr = resultsDic[@"markedFavoriteFiles"];
            NSMutableArray *itemsArr = [NSMutableArray array];
            for (NSDictionary *itemDic in markedFavoriteFilesArr) {
                if (itemDic.count > 0) {
                    NSNumber *fromMyVault = itemDic[@"fromMyVault"];
                    NSString *pathId = itemDic[@"pathId"];
                    NSString *pathDisplay = itemDic[@"pathDisplay"];
                    
                    if ([fromMyVault boolValue] == true) {
                        NXMyVaultFile *file = [[NXMyVaultFile alloc] init];
                        file.fullServicePath = pathId;
                        file.fullPath = pathDisplay;
                        [itemsArr addObject:file];
                    }
                    else
                    {
                        NXFile *file = [[NXFile alloc] init];
                        file.fullServicePath = pathId;
                        file.fullPath = pathDisplay;
                        [itemsArr addObject:file];
                    }
                }
            }
            response.favoriteFilesList = itemsArr;
        }
        
        return response;
    };
    
    return analysis;
}

-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    NSLog(@"转换的时间戳=%f",interval);
    long long totalMilliseconds = interval*1000 ;
    NSLog(@"totalMilliseconds=%llu",totalMilliseconds);
    return totalMilliseconds;
}

@end

@implementation NXFavoriteGetFavoriteFilesInRepoAPIResponse

-(NSMutableArray*)favoriteFilesList {
    if (!_favoriteFilesList) {
        _favoriteFilesList = [NSMutableArray array];
    }
    return _favoriteFilesList;
}

@end

