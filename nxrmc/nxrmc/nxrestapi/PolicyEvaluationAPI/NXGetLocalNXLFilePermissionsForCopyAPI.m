//
//  NXGetLocalNXLFilePermissionsForCopyAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2022/5/20.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXGetLocalNXLFilePermissionsForCopyAPI.h"
#import "NXPolicyTransformModel.h"
#import "NXMultipartFormDataMaker.h"
@implementation NXGetLocalNXLFilePermissionsForCopyAPIRequest
-(NSURLRequest *) generateRequestObject:(id) object {
    
    if (self.reqRequest == nil)
    {
        NXPolicyTransformModel *transformModel = (NXPolicyTransformModel *)object;
        NSDictionary *parametersDic = @{@"parameters":@{@"destSpaceType":transformModel.destSpaceType,@"destMembershipId":transformModel.destMembershipId,@"destFileName":transformModel.destFileName}};
       
       
      
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/policyEval/permissions/nxl",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
     
        [request setHTTPMethod:@"POST"];
        [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",@"boundaryLine"] forHTTPHeaderField:@"Content-Type"];

        NSData *parameterData = [parametersDic toJSONFormatData:nil];

        NXMultipartFormDataMaker *formdataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:@"boundaryLine"];
        [formdataMaker addFileParameter:@"nxl-header" fileName:transformModel.destFileName fileData:transformModel.headerData];
        [formdataMaker addTextParameter:@"API-input" parameterJsonDataValue:parameterData];
        [formdataMaker endFormData];
        NSData *formData = [formdataMaker getFormData];
        [request setHTTPBody:formData];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error) {
        NXGetLocalNXLFilePermissionsForCopyAPIResponse *response=[[NXGetLocalNXLFilePermissionsForCopyAPIResponse alloc]init];
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
@implementation NXGetLocalNXLFilePermissionsForCopyAPIResponse


@end
