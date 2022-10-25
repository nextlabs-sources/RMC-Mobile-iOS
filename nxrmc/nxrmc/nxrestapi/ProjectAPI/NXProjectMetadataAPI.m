//
//  NXProjectMetadataAPI.m
//  nxrmc
//
//  Created by helpdesk on 17/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectMetadataAPI.h"
#import "NXProjectModel.h"
#import "NXCommonUtils.h"
@implementation NXProjectMetadataAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@",[NXCommonUtils currentRMSAddress],object]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
     Analysis analysis = (id)^(NSString *returnData, NSError* error){
         NXProjectMetadataAPIResponse *response =[[NXProjectMetadataAPIResponse alloc]init];
         NSData *resultData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
         if (resultData) {
             [response analysisResponseStatus:resultData];
             NSDictionary *dic =[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
             NSDictionary *resultsDic = dic[@"results"];
             NSDictionary *detailDic =resultsDic[@"detail"];
             NXProjectModel *projectItem =[[NXProjectModel alloc] initWithDictionary:detailDic];
             response.projectItem = projectItem;
         }
         return response;
     };
    return analysis;
}

@end

@implementation NXProjectMetadataAPIResponse
- (NXProjectModel*)projectItem {
    if (!_projectItem) {
        _projectItem =[[NXProjectModel alloc]init];
    }
    return _projectItem;
}


@end
