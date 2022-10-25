//
//  NXSharedWithProjectFileMatadataAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/1.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFileMatadataAPI.h"
#import "NXSharedWithProjectFile.h"
@implementation NXSharedWithProjectFileMatadataAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isMemberOfClass:[NXSharedWithProjectFile class]], @"NXSharedWithProjectFilesRequest modle should be NXSharedWithProjectFile");
        NXSharedWithProjectFile *fileItem = (NXSharedWithProjectFile *)object;
        NSString * apiStr = [NSString stringWithFormat:@"%@/rs/sharedWithMe/metadata/%@/%@?spaceId=%@",[NXCommonUtils currentRMSAddress],fileItem.transactionId,fileItem.transactionCode,fileItem.sharedProject.projectId];
        NSURL *apiUrl  = [[NSURL alloc] initWithString:apiStr];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiUrl];
//        NSDictionary *dict = @{@"spaceId":fileItem.sharedProject.projectId};
//        NSError *error;
//        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return  self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSharedWithProjectFileMatadataAPIResponse *response = [[NXSharedWithProjectFileMatadataAPIResponse alloc] init];
        NSData *contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            if (response.rmsStatuCode == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
                           NSDictionary *resultsDic = dic[@"results"][@"detail"];
                           NXSharedWithProjectFile *item = [[NXSharedWithProjectFile alloc] initWithDictionary:resultsDic];
                           response.fileItem = item;
            }
           
        }
        
        return response;

    };
    return analysis;
}
@end
@implementation NXSharedWithProjectFileMatadataAPIResponse

@end
