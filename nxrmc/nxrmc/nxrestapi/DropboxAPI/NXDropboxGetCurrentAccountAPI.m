//
//  NXDropboxGetCurrentAccountAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDropboxGetCurrentAccountAPI.h"
#import "NXCommonUtils.h"

@implementation NXDropboxGetCurrentAccountAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://api.dropboxapi.com/2/users/get_current_account"]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxGetCurrentAccountAPIResponse *apiResponse = [[NXDropboxGetCurrentAccountAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            if (!error) {
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *nameDic = returnDic[@"name"];
                if (nameDic.count >0) {
                    apiResponse.userDisplayName = nameDic[@"display_name"];
                }
                apiResponse.userEmail = returnDic[@"email"];
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

@implementation NXDropboxGetCurrentAccountAPIResponse

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
