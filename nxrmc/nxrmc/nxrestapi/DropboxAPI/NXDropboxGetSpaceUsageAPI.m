//
//  NXDropboxGetSpaceUsageAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDropboxGetSpaceUsageAPI.h"
#import "NXCommonUtils.h"

@implementation NXDropboxGetSpaceUsageAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://api.dropboxapi.com/2/users/get_space_usage"]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxGetSpaceUsageAPIResponse *apiResponse = [[NXDropboxGetSpaceUsageAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            if (!error) {
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                
                apiResponse.used = returnDic[@"used"];
                NSDictionary *allocationDic = returnDic[@"allocation"];
                if (allocationDic.count) {
                    apiResponse.allocated = allocationDic[@"allocated"];
                    apiResponse.tag = allocationDic[@".tag"];
                }
                
                NSLog(@"%@",returnDic);
            }
            else if (error.code == 401)
            {
                apiResponse.isAccessTokenExpireError = YES;
            }
        }
        return apiResponse;
    };
    return analysis;
}
@end

@implementation NXDropboxGetSpaceUsageAPIResponse

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
@end

