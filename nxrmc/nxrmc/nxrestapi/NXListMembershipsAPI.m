//
//  NXListMembershipsAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 20/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXListMembershipsAPI.h"
#import "NXCommonUtils.h"

@implementation NXListMembershipsResultModel
@end

@implementation NXListMembershipsAPIRequest

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSString *projectId = object;
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/usr/memberships?q=%@",[NXCommonUtils currentRMSAddress],projectId]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXListMembershipsAPIResponse *response = [[NXListMembershipsAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSArray *membershipsArray = resultsDic[@"memberships"];
            NSMutableArray *resultArray = [NSMutableArray new];
            for (NSDictionary *itemDic in membershipsArray) {
                NXListMembershipsResultModel *model = [[NXListMembershipsResultModel alloc] init];
                model.userId = itemDic[@"id"];
                model.type = itemDic[@"type"];
                model.tenantId = itemDic[@"tenantId"];
                model.projectId = itemDic[@"projectId"];
                [resultArray addObject:model];
            }
            
            response.resultArray = [resultArray copy];
        }
        return response;
    };
    return analysis;
}

@end

@implementation NXListMembershipsAPIResponse
- (instancetype)init
{
    self = [super init];
    if (self) {
        _resultArray = [[NSArray alloc] init];
    }
    return self;
}
@end

