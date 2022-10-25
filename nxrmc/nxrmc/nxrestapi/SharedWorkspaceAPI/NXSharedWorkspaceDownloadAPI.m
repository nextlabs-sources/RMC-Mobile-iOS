//
//  NXSharedWorkspaceDownloadAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWorkspaceDownloadAPI.h"

@implementation NXSharedWorkspaceDownloadAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo {
    self = [super init];
    if (self) {
        _repo = repo;
    }
    return self;
}
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil && object) {
        NSNumber *start     = object[START];
        NSNumber *length    = object[LENGTH];
        NSString *filePath  = object[FILE_PATH];
        NSNumber *downloadType = object[DOWNLOAD_TYPE];
        NSString *repoId  = self.repo.service_id;
//        bool isnxl = [object[ISNXL] boolValue];
//        if ([downloadType integerValue] == 0) {
//            downloadType = @1;
//        }
        NSDictionary *jDict = nil;
        
            jDict = @{@"parameters":@{@"path":filePath,@"start":start,@"length":length,@"type":downloadType}};
            
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/sharedws/v1/%@/download", [NXCommonUtils currentRMSAddress],repoId]]];
        self.reqRequest.HTTPMethod = @"POST";
        NSDictionary *parametersDict = jDict;
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setHTTPBody:[parametersDict toJSONFormatData:nil]];
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSharedWorkspaceDownloadAPIResponse *response =[[NXSharedWorkspaceDownloadAPIResponse alloc]init];
        NSData *contentData=nil;
        if ([returnData isKindOfClass:[NSString class]]) {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }else {
            contentData =(NSData*)returnData;
        }
        
        if (contentData) {
            [response analysisResponseStatus:contentData];
        }
        if(error){
            response.rmsStatuCode = error.code;
            response.resultData = nil;
        }else{
            response.rmsStatuCode = 200;
            response.resultData = contentData;
        }
        return response;
        
    };
    return analysis;
}
@end

@implementation NXSharedWorkspaceDownloadAPIResponse

- (NSData*)resultData {
    if (!_resultData) {
        _resultData=[[NSData alloc]init];
    }
    return _resultData;
}

@end

