//
//  NXSharedWorkspaceGetFileMetaDataAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/15.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWorkspaceGetFileMetaDataAPI.h"
#import "NXSharedWorkspaceFile.h"
@implementation NXSharedWorkspaceGetFileMetaDataAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo {
     self = [super init];
    if (self) {
        _repo = repo;
    }
    return self;
}
- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSString *repoId = self.repo.service_id;
        NSString *path;
        if (object) {
            path = ((NXSharedWorkspaceFile *)object).fullPath;
        }
        if (!path) {
            NSDictionary *jsonDict = @{@"parameters":@{@"path":path}};
               NSError *error;
               NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
            NSURL *apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedws/v1/%@/metadata",[NXCommonUtils currentRMSAddress],repoId]];

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:bodyData];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis ret = (id)^(NSString *returnData, NSError *error)
       {
            NXSharedWorkspaceGetFileMetaDataAPIResponse *response = [[NXSharedWorkspaceGetFileMetaDataAPIResponse alloc] init];
           if (returnData) {
               NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
               [response analysisResponseStatus:data];
               NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS &&!error) {
                   NSDictionary *resultDic = returnDic[@"results"];
                   NSDictionary *fileInfoDic = resultDic[@"fileInfo"];
                   NXSharedWorkspaceFile *fileItem = [[NXSharedWorkspaceFile alloc] initWithDictionary:fileInfoDic];
                   response.fileItem = fileItem;
               }
                       
           }
           return response;
       };
       
       return ret;
}
@end
@implementation NXSharedWorkspaceGetFileMetaDataAPIResponse



@end
