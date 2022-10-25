//
//  NXAllProjectListAPI.m
//  nxrmc
//
//  Created by Sznag on 2020/3/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXAllProjectListAPI.h"

@implementation NXAllProjectListAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/allProjects",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXAllProjectListAPIResponse *response = [[NXAllProjectListAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSArray *projectsArr = resultsDic[@"detail"];
            NSMutableArray *itemsArr = [NSMutableArray array];
            NSString *systemProjectTenantID = [NXLoginUser sharedInstance].profile.tenantPrefence.SYSTEM_DEFAULT_PROJECT_TENANTID;
            for (NSDictionary *itemDic in projectsArr) {
                NXProjectModel *projectItem = [[NXProjectModel alloc] initWithDictionary:itemDic];
                // manually add tenantId and memebershipId
                NXLMembership *membership = [[NXLoginUser sharedInstance].profile memberShipForProject:projectItem.projectId];
                if (membership) {
                    projectItem.membershipId = [membership.ID copy];
                }
                if (![projectItem.parentTenantId isEqualToString:systemProjectTenantID]) {
                     [itemsArr addObject:projectItem];
                }
            }
            response.itemsArray = itemsArr;
        }
        return response;
    };
    return analysis;
}
@end
@implementation NXAllProjectListAPIResponse
-(NSMutableArray*)itemsArray {
    if (!_itemsArray) {
        _itemsArray = [NSMutableArray array];
    }
    return _itemsArray;
}

@end
