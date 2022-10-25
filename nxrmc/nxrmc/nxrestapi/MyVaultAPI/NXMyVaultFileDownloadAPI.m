//
//  NXMyVaultFileDownloadAPI.m
//  nxrmc
//
//  Created by xx-huang on 29/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultFileDownloadAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"


@interface NXMyVaultFileDownloadAPIRequest ()

@property (nonatomic,strong) NSString *fileName;

@end

@implementation NXMyVaultFileDownloadAPIRequest


/**
 Request Object Format Is Just Like Follows:
 
 "parameters":
 {
 "path": "/finance/expense-report.xls",
 "start": 0,
 "length": 1000
 "forViewer"
 }
 */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSError *error;
        NSString *fileName = [(NSDictionary *)object objectForKey:PATH];
        
        if(fileName.length > 0)
        {
            fileName = [fileName  componentsSeparatedByString:@"/"].lastObject;
            _fileName = fileName;
        }
        
        // just temp
         //START:((NSDictionary *)object)[START], LENGTH:((NSDictionary *)object)[LENGTH]
        NSDictionary *jDict = @{@"parameters":@{PATH:[(NSDictionary *)object objectForKey:PATH],DOWNLOAD_TYPE:[(NSDictionary *)object objectForKey:DOWNLOAD_TYPE]}};
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/myVault/v2/download",[NXCommonUtils currentRMSAddress]]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXMyVaultFileDownloadAPIResponse *response = [[NXMyVaultFileDownloadAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            response.rmsStatuCode = 200;
        }
        
        response.fileData = contentData;
        response.fileName = self.fileName; // JUST FOR TEMP USE, need RMS header info
        
        return response;
        
    };
    
    return analysis;
}

@end

@implementation NXMyVaultFileDownloadAPIResponse

- (NSData*)resultData
{
    if (!_fileData)
    {
        _fileData = [[NSData alloc] init];
    }
    
    return _fileData;
}

@end

