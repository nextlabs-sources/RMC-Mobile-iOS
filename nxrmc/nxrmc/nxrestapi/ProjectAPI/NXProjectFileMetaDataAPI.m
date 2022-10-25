//
//  NXProjectFileMetaDataAPI.m
//  nxrmc
//
//  Created by xx-huang on 16/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectFileMetaDataAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXProjectFile.h"

#pragma mark -NXProjectFileMetaDataInfo

#pragma mark -NXProjectFileMetaDataAPIRequest
@interface NXProjectFileMetaDataAPIRequest ()
@property (nonatomic, strong) NSNumber *projectId;
@end
@implementation NXProjectFileMetaDataAPIRequest

/**
 Request Object Format Is Just Like Follows:
 
 "parameters":
 {
 "path": "/folder/"
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSError *error;
        
        NSString *filePath = object[FILE_PATH];
        NSNumber *projectId = object[PROJECT_ID];
        self.projectId=projectId;
        NSDictionary *jDict = @{@"parameters":@{@"pathId":filePath}};
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/file/metadata",[NXCommonUtils currentRMSAddress],projectId]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 Produces: application/json
 
{
     "statusCode":200,
        "message":"OK",
     "serverTime":1484201956960,
        "results":
        {
             "fileInfo":
             {
                 "filePath":"/folder/draft.doc.nxl",
                 "fileName":"draft.doc.nxl",
                 "fileSize":52736,
                 "lastModifiedTime":1484104394000,
                 "rights":[
                 "VIEW"
                 ]
             }
         }
 }
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectFileMetaDataAPIResponse *response = [[NXProjectFileMetaDataAPIResponse alloc] init];
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
            
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultDic = returnDic[@"results"];
            NSDictionary *fileInfoDic = resultDic[@"fileInfo"];
            
            if (fileInfoDic.count > 0)
            {
                NXProjectFile *fileInfo = [[NXProjectFile alloc] initFileFromResultProjectFileMetadataDic:fileInfoDic];
                fileInfo.projectId=self.projectId;
                response.fileInfo = fileInfo;
            }
        }
        
        return response;
    };
    
    return analysis;
}

@end

#pragma mark -NXProjectFileMetaDataAPIResponse

@implementation NXProjectFileMetaDataAPIResponse

- (NXProjectFile *)fileInfo
{
    if (!_fileInfo)
    {
        _fileInfo = [[NXProjectFile alloc] init];
    }
    return _fileInfo;
}
@end
