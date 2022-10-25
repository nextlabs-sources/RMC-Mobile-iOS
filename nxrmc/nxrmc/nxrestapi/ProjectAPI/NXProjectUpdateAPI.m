//
//  NXProjectUpdateAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 21/8/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectUpdateAPI.h"

@implementation NXProjectUpdateParmetersMD 
@end

@implementation NXProjectUpdateAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isMemberOfClass:[NXProjectUpdateParmetersMD class]]) {
            NXProjectUpdateParmetersMD *parmetersMD = (NXProjectUpdateParmetersMD *)object;
            NSMutableDictionary *parameterDic = [NSMutableDictionary dictionary];
            if (parmetersMD.projectName) {
                [parameterDic setValue:parmetersMD.projectName forKey:@"projectName"];
            }
            if (parmetersMD.projectDescription) {
                [parameterDic setValue:parmetersMD.projectDescription forKey:@"projectDescription"];
            }
            if (parmetersMD.invitationMsg) {
                [parameterDic setValue:parmetersMD.invitationMsg forKey:@"invitationMsg"];
            }
            NSDictionary *jsonDict = @{@"parameters":parameterDic};
            NSError *error;
            NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
            NSURL *apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@",[NXCommonUtils currentRMSAddress],parmetersMD.projectId]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPBody:bodyData];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            self.reqRequest = request;

        }
    }
    return self.reqRequest;
}
-(Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXProjectUpdateAPIResponse *response = [[NXProjectUpdateAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSString *createdTimeStr = dic[@"serverTime"];
            NSDictionary *resultsDic = dic[@"results"];
            NSDictionary *detailDic = resultsDic[@"detail"];
            NXProjectModel *model = [[NXProjectModel alloc]initWithDictionary:detailDic];
            model.createdTime = [createdTimeStr longLongValue];
            response.ProjectModel = model;
        };
        return response;
    };
    return analysis;
}
@end

@implementation NXProjectUpdateAPIResponse

@end
