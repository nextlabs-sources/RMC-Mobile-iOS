//
//  NXSharedWithProjectFileDownloadAPI.m
//  nxrmc
//
//  Created by 时滕 on 2020/1/10.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFileDownloadAPI.h"

@implementation NXSharedWithProjectFileDownloadRequest
- (instancetype)initWithDownloadSize:(NSUInteger)downloadSize isForView:(BOOL)forView
{
    self = [super init];
    if (self) {
        _forViewer = forView;
        _downloadSize = downloadSize;
    }
    return self;
}

/**
 Request Object Format Is Just Like Follows:
 
 {
 "parameters": {
 "transactionCode":"07A8D85154920D18437C9D0DC488A7A0E300D917B8EA21787F4443C73ACF3225",
 "transactionId":"9e239ccb-65f1-4786-bf45-5084ae24a14e"
 }
 } */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest==nil) {
        
        NXSharedWithProjectFile *sharedWithProjectFile = (NXSharedWithProjectFile *)object;
        self.sharedWithProjectfile = sharedWithProjectFile;
        NSDictionary *paraDic = nil;
        if (self.downloadSize == 0) {
            paraDic = @{@"transactionCode":sharedWithProjectFile.transactionCode,@"transactionId":sharedWithProjectFile.transactionId,@"forViewer":self.forViewer?@"true":@"false", @"spaceId":sharedWithProjectFile.spaceId};
        }else{
            paraDic = @{@"transactionCode":sharedWithProjectFile.transactionCode,@"transactionId":sharedWithProjectFile.transactionId,@"forViewer":self.forViewer?@"true":@"false", @"start":@0, @"length":[NSNumber numberWithUnsignedInteger:self.downloadSize], @"spaceId":sharedWithProjectFile.spaceId};
        }
        NSDictionary *jsonDict = @{@"parameters":paraDic};
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/download",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;

}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXSharedWithProjectFileDownloadResponse *response = [[NXSharedWithProjectFileDownloadResponse alloc] init];
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
            if(response.rmsStatuCode == -1){ // God RMS API, only return error status code, but no success status code -_-|||
                response.rmsStatuCode = 200;
            }
        }
        
        response.fileData = contentData;
        response.file = self.sharedWithProjectfile;
        return response;
    };
    
    return analysis;
}
@end

@implementation NXSharedWithProjectFileDownloadResponse

@end
