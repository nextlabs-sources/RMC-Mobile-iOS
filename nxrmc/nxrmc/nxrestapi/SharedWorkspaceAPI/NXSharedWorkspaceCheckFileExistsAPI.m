//
//  NXSharedWorkspaceCheckFileExistsAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWorkspaceCheckFileExistsAPI.h"

@implementation NXSharedWorkspaceCheckFileExistsAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil && object) {
          NSString *filePath  = object[FILE_PATH];
          NSString *repoId  = object[REPO_ID];
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/sharedws/v1/%@/file/checkIfExists", [NXCommonUtils currentRMSAddress],repoId]]];
        self.reqRequest.HTTPMethod = @"POST";
        NSDictionary *jDict = @{@"parameters":@{@"path":filePath}};;
            
        NSDictionary *parametersDict = jDict;
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setHTTPBody:[parametersDict toJSONFormatData:nil]];
    }
      return self.reqRequest  ;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSharedWorkspaceCheckFileExistsAPIResponse *response =[[NXSharedWorkspaceCheckFileExistsAPIResponse alloc]init];
          NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
            if (resultData) {
                [response analysisResponseStatus:resultData];
                if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                    NSDictionary *resultsDic = dic[@"results"];
                    NSNumber *isExist = resultsDic[@"fileExists"];
                    response.isFileExist = isExist.boolValue;
                }
            }
            return response;
    };
    return analysis;
}
@end

@implementation NXSharedWorkspaceCheckFileExistsAPIResponse

@end
