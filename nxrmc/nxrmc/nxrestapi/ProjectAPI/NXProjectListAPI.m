//
//  NXProjectListAPI.m
//  nxrmc
//
//  Created by helpdesk on 16/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
// 2CDD75F23995FF677027CACD3F0307B0
// 132
// https://rmtest.nextlabs.solutions/rms


#import "NXProjectListAPI.h"
#import "NXCommonUtils.h"
#import "NXProjectModel.h"
#import "NXProjectsListParameterModel.h"
#import "NXLProfile.h"

@implementation NXProjectListAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isKindOfClass:[NXProjectsListParameterModel class]]) {
            NXProjectsListParameterModel * parameterModel = (NXProjectsListParameterModel *)object;
            NSString *orderByType = @"";
            switch (parameterModel.orderByType) {
                case NXProjectsListOrderByTypeNameAscending:
                    orderByType = @"name";
                    break;
                    case NXProjectsListOrderByTypeNameDescending:
                    orderByType = @"-name";
                    break;
                    case NXProjectsListOrderByTypeLastActionTimeAscending:
                    orderByType = @"lastActionTime";
                    break;
                    case NXProjectsListOrderByTypeLastActionTimeDescending:
                    orderByType = @"-lastActionTime";
                    break;
                default:
                    orderByType = @"-lastActionTime";
                    break;
            }
            
            NSString * ownerByType = nil;
            switch (parameterModel.ownerByType) {
                case NXProjectsListOwnerByTypeforAll:
                    ownerByType = nil;
                    break;
                    case NXProjectsListOrderByTypeForMe:
                    ownerByType = @"true";
                    break;
                    case NXProjectsListOwnerByTypeForOther:
                    ownerByType = @"false";
                    break;
                default:
                    break;
            }
            NSURL *apiURL = nil;
            if (ownerByType == nil) {
                apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project?page=%@&size=%@&orderBy=%@",[NXCommonUtils currentRMSAddress],parameterModel.page,parameterModel.size,orderByType]];
            }else {
                apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project?page=%@&size=%@&orderBy=%@&ownedByMe=%@",[NXCommonUtils currentRMSAddress],parameterModel.page,parameterModel.size,orderByType,ownerByType]];
            }
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"GET"];
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXProjectListAPIResponse *response = [[NXProjectListAPIResponse alloc]init];
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

@implementation NXProjectListAPIResponse
-(NSMutableArray*)itemsArray {
    if (!_itemsArray) {
        _itemsArray = [NSMutableArray array];
    }
    return _itemsArray;
}

@end

