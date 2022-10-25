//
//  NXProjectCreateFolderAPI.m
//  nxrmc
//
//  Created by xx-huang on 18/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectCreateFolderAPI.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"
@interface NXProjectCreateFolderAPIRequest ()
@property (nonatomic,strong) NSNumber *projectId;
@end
@implementation NXProjectCreateFolderAPIRequest

/**
 Request Object Format Is Just Like Follows:
 
 "parameters":
 {
 "path": "/folder/"
 "autorename":"false"
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSError *error;
        
        NSString *autorename = object[AUTO_RENAME];
        NSNumber *projectId = object[PROJECT_ID];
        NSString *filePath = object[FILE_PATH];
        NSString *folderName = object[FOLDER_NAME];
        self.projectId = projectId;
        NSDictionary *jDict = @{@"parameters":@{@"parentPathId":filePath,@"name":folderName,@"autorename":autorename}};
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/createFolder",[NXCommonUtils currentRMSAddress],projectId]];
        
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
"serverTime":1477637785817,
"results":
{
"folderName":"Folder"
}
}
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectCreateFolderAPIResponse *response = [[NXProjectCreateFolderAPIResponse alloc] init];
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
            NSDictionary *entryDic = resultDic[@"entry"];
            NXProjectFolder *folderItem = [[NXProjectFolder alloc]initFileFromResultProjectFileListDic:entryDic];
            folderItem.projectId = self.projectId;
            response.createFolder = folderItem;
        }
        
        return response;
    };
    
    return analysis;
}

@end

@implementation NXProjectCreateFolderAPIResponse

-(instancetype)init
{
    self = [super init];
    if (self) {
        _folderName = @"";
    }
    return self;
}
@end
