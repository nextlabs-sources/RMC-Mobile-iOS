//
//  NXGetMemberShipAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 19/04/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXGetMemberShipAPI.h"
#import "NXProjectModel.h"
#import "NXCommonUtils.h"

@implementation NXGetMemberShipAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/membership",[NXCommonUtils currentRMSAddress],object]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXGetMemberShipAPIResponse *response =[[NXGetMemberShipAPIResponse alloc]init];
        NSData *resultData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic =[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSDictionary *memberShipDic =resultsDic[@"membership"];
            if (memberShipDic.count >0) {
                NXProjectModel *projectItem =[[NXProjectModel alloc]init];
               
                projectItem.membershipId = memberShipDic[@"id"];
                projectItem.projectId = memberShipDic[@"projectId"];
                NSNumber *accountType = memberShipDic[@"type"];
                projectItem.accountType = accountType.stringValue;
                projectItem.tokenGroupName = memberShipDic[@"tokenGroupName"];
                response.projectItem = projectItem;
            }
        }
        return response;
    };
    return analysis;
}

@end

@implementation NXGetMemberShipAPIResponse
- (NXProjectModel*)projectItem {
    if (!_projectItem) {
        _projectItem =[[NXProjectModel alloc]init];
    }
    return _projectItem;
}

@end
