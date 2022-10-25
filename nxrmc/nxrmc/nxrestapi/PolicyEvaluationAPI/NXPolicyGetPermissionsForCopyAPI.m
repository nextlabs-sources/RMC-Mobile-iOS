//
//  NXPolicyGetPermissionsForCopyAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2022/5/20.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXPolicyGetPermissionsForCopyAPI.h"
#import "NXPolicyTransformModel.h"
@implementation NXPolicyGetPermissionsForCopyAPIRequest
-(NSURLRequest *) generateRequestObject:(id) object {
    
    if (self.reqRequest == nil)
    {
        NXPolicyTransformModel *transformModel = (NXPolicyTransformModel *)object;
        NSDictionary *parametersDic;
        if (transformModel.sourceSpaceId) {
            parametersDic = @{@"parameters":@{@"src":@{@"filePathId":transformModel.scrFilePathId,@"spaceType":transformModel.sourceSpaceType,@"spaceId":transformModel.sourceSpaceId},@"destSpaceType":transformModel.destSpaceType,@"destMembershipId":transformModel.destMembershipId,@"destFileName":transformModel.destFileName}};
        }else{
            parametersDic = @{@"parameters":@{@"src":@{@"filePathId":transformModel.scrFilePathId,@"spaceType":transformModel.sourceSpaceType},@"destSpaceType":transformModel.destSpaceType,@"destMembershipId":transformModel.destMembershipId,@"destFileName":transformModel.destFileName}};
        }
       
        
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parametersDic options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/policyEval/permissions/nxl",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"produce"];
        [request setValue:@"application/json" forHTTPHeaderField:@"consume"];
        self.reqRequest = request;

    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error) {
        NXPolicyGetPermissionsForCopyAPIResponse *response=[[NXPolicyGetPermissionsForCopyAPIResponse alloc]init];
        NSData *backData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (backData) {
            [response analysisResponseStatus:backData];
            NSDictionary *returnDic =[NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = returnDic[@"results"];
            NSString *watermarkStr = resultsDic[@"watermarkStr"];
            NSArray *rightsArray = resultsDic[@"rights"];
            
            response.watermarkStr = watermarkStr;
            response.rightsArray = rightsArray;
        }
        return response;
    };
    return analysis;
}

@end


@implementation NXPolicyGetPermissionsForCopyAPIResponse



@end
