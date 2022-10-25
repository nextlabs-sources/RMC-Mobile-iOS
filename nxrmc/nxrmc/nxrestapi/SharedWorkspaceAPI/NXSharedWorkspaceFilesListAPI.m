//
//  NXSharedWorkspaceFilesListAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/15.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWorkspaceFilesListAPI.h"
#import "NXCommonUtils.h"
#import "NXSharedWorkspaceFile.h"
#import "NXRepositoryModel.h"
@implementation NXSharedWorkspaceFilesListAPIRequest
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
        NSString *path = object;
        NSString *urlStr = nil;
        if (path) {
            path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,;='\"`<>()[]{}/\\| "].invertedSet];
            urlStr = [NSString stringWithFormat:@"%@/rs/sharedws/v1/%@/files?path=%@",[NXCommonUtils currentRMSAddress],repoId,path];
        }else{
            urlStr = [NSString stringWithFormat:@"%@/rs/sharedws/v1/%@/files",[NXCommonUtils currentRMSAddress],repoId];
           
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis ret = (id)^(NSString *returnData, NSError *error)
       {
            NXSharedWorkspaceFilesListAPIResponse *response = [[NXSharedWorkspaceFilesListAPIResponse alloc] init];
           if (returnData) {
               NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
               [response analysisResponseStatus:data];
               NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS &&!error) {
                   NSMutableArray *fileArray = [NSMutableArray array];
                   NSDictionary *resultDic = returnDic[@"results"];
                   NSArray *detailFiles = resultDic[@"detail"];
                   for (NSDictionary *itemDic in detailFiles) {
                       BOOL isFolder = ((NSNumber *)itemDic[@"isFolder"]).boolValue;
                       NXFileBase *fileItem = isFolder?[[NXSharedWorkspaceFolder alloc] initWithDictionary:itemDic] : [[NXSharedWorkspaceFile alloc] initWithDictionary:itemDic];
                       [fileArray addObject:fileItem];

                   }
                   response.filesArray = fileArray;
               }
                       
           }
           return response;
       };
       
       return ret;
}
@end
@implementation NXSharedWorkspaceFilesListAPIResponse

@end
