//
//  NXMyVaultFileUploadAPI.m
//  nxrmc
//
//  Created by xx-huang on 29/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultFileUploadAPI.h"
#import "NXMultipartFormDataMaker.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMyVaultFile.h"

#define Name @"name"
#define LastModified @"lastModified"
#define Size @"size"


@implementation NXMyVaultFileUploadAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSData *fileData = object[@"fileData"];
        NSString *fileName = object[@"fileName"];
        NSDictionary *parameters = object[@"parameters"];
        
        NSData *jsonData = [self toJSONData:parameters];
        
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/myVault/upload",[NXCommonUtils currentRMSAddress]]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",@"boundaryLine"]forHTTPHeaderField:@"Content-Type"];
        
        NXMultipartFormDataMaker *formDataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:@"boundaryLine"];
        
        [formDataMaker addFileParameter:@"file" fileName:fileName fileData:fileData];
        [formDataMaker addTextParameter:@"API-input" parameterJsonDataValue:jsonData];
        [formDataMaker endFormData];
        
        request.HTTPBody = [formDataMaker getFormData];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[request.HTTPBody length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 Produces: application/json
 
 {
 "statusCode": 200,
 "message": "OK",
 "serverTime": 1477623263276,
 "results": {
 "name": "expense-report.xls.nxl",
 "lastModified": 1477637785817,
 "size": 7212
 }
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXMyVaultFileUploadAPIResponse *response = [[NXMyVaultFileUploadAPIResponse alloc]init];
        NSData *backData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        
        if (backData)
        {
            [response analysisResponseStatus:backData];
            // 1DC90349FD6DF2861F00CBC69AA3213D;
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
            
            NSDictionary *resultDic = returnDic[@"results"];
            
            if (resultDic.count > 0)
            {
                response.fileItem.name = [resultDic objectForKey:Name];
                response.fileItem.size = [[resultDic objectForKey:Size] intValue];
                response.fileItem.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:[[resultDic objectForKey:LastModified] longLongValue] / 1000];
                response.fileItem.fullServicePath = [resultDic objectForKey:@"pathId"];
                response.fileItem.duid = [resultDic objectForKey:@"duid"];
                response.fileItem.fullPath = [resultDic objectForKey:@"pathDisplay"];
            }
        }
        
        return response;
    };
    
    return analysis;
}

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] != 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

@end

@implementation NXMyVaultFileUploadAPIResponse

- (NXMyVaultFile *)fileItem
{
    if (!_fileItem)
    {
        _fileItem = [[NXMyVaultFile alloc] init];
    }
    
    return _fileItem;
}

@end
