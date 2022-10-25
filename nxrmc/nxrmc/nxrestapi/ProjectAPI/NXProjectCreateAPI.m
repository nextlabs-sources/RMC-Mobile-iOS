//
//  NXProjectCreatedAPI.m
//  nxrmc
//
//  Created by helpdesk on 18/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectCreateAPI.h"
#import "NXCommonUtils.h"
#import "NXProjectModel.h"
@implementation NXProjectCreateParmetersMD
- (NSArray*)userEmails {
    if (!_userEmails) {
        _userEmails=[NSArray array];
    }
    return _userEmails;
}
@end
@implementation NXProjectCreateAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSDictionary *jsonDict = nil;
        if ([object isKindOfClass:[NXProjectCreateParmetersMD class]]) {
            NXProjectCreateParmetersMD *parmetersMD = (NXProjectCreateParmetersMD*)object;
            NSDictionary *detailDic = nil;
            if (parmetersMD.invitationMsg) {
                detailDic = @{@"projectName":parmetersMD.projectName,@"projectDescription":parmetersMD.projectDescription,@"emails":parmetersMD.userEmails,@"invitationMsg":parmetersMD.invitationMsg};
            }else {
                detailDic = @{@"projectName":parmetersMD.projectName,@"projectDescription":parmetersMD.projectDescription,@"emails":parmetersMD.userEmails};
            }
            
            jsonDict = @{@"parameters":detailDic};
        }
       
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"application/json" forHTTPHeaderField:@"consumes"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
-(Analysis)analysisReturnData{
   Analysis analysis = (id)^(NSString *returnData, NSError* error){
       NXProjectCreateAPIResponse *response =[[NXProjectCreateAPIResponse alloc]init];
       NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
       if (resultData) {
            [response analysisResponseStatus:resultData];
           NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
           NSString *createdTimeStr = dic[@"serverTime"];
           NSDictionary *resultsDic = dic[@"results"];
           NXProjectModel *model = [[NXProjectModel alloc]initWithDictionary:resultsDic];
           model.createdTime = [createdTimeStr longLongValue];
           response.ProjectModel = model;
       }
       return response;
   };
    return analysis;
}
@end

@implementation NXProjectCreateAPIResponse
- (NXProjectModel*)ProjectModel{
    if (!_ProjectModel) {
        _ProjectModel=[[NXProjectModel alloc]init];
    }
    return _ProjectModel;
}

@end

