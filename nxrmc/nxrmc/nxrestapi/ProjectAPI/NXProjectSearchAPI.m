//
//  NXProjectSearchAPI.m
//  nxrmc
//
//  Created by xx-huang on 16/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectSearchAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

#pragma mark -NXProjectFileMetaDataInfo

@implementation NXProjectMatchedFileItem

-(instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self){
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end

#pragma mark -NXProjectSearchAPIRequest

@implementation  NXProjectSearchAPIRequest

/**
 Request Object Format Is Just Like Follows:
 
 "parameters":
 {
    "query": "draft"
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSString *query = object[QUERY];
        NSString *projectId = object[PROJECT_ID];
        
        NSDictionary *jDict = @{@"parameters":@{@"query":query}};
        
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/search",[NXCommonUtils currentRMSAddress],projectId]];
        
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
 "serverTime":1484038603084,
 "results":{
 
     "matches":[
     {
     "filePathDisplay":"/folder/draft.docx.nxl",
     "filePath":"/folder/draft.docx.nxl",
     "fileName":"draft.docx.nxl",
     "fileSize":396800,
     "folder":false
     },
     {
     "filePathDisplay":"/folder1/draft.docx.nxl",
     "filePath":"/folder1/draft.docx.nxl",
     "fileName":"draft.docx.nxl",
     "fileSize":396800,
     "folder":false
     }
     ]
 }
 }
 */

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectSearchAPIResponse *response = [[ NXProjectSearchAPIResponse alloc] init];
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
            
            NSArray *matchedFileItemsArray = resultDic[@"matches"];
            NSMutableArray *fileItemsArray = [[NSMutableArray alloc] init];
            
            for (NSMutableDictionary *matchsDic in matchedFileItemsArray)
            {
                NXProjectMatchedFileItem *fileItem = [[NXProjectMatchedFileItem alloc] initWithDictionary:matchsDic];
                [fileItemsArray addObject:fileItem];
            }
            response.matchedFileList = fileItemsArray;
        }
        
        return response;
    };
    
    return analysis;
}

@end

#pragma mark -NXProjectSearchAPIResponse

@implementation NXProjectSearchAPIResponse

- (NSMutableArray*)matchedFileList{
    if (!_matchedFileList)
    {
        _matchedFileList = [[NSMutableArray alloc] init];
    }
    return _matchedFileList;
}
@end
