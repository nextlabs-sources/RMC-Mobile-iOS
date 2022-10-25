//
//  NXGetAccessTokenAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 06/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXGetAccessTokenAPI.h"
@interface NXGetAccessTokenAPIRequest()
@property(nonatomic, strong) NXRepositoryModel * repoModel;
@end
@implementation NXGetAccessTokenAPIRequest

- (NSURLRequest*) generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSString *repoId = object;
        NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:repoId];
        self.repoModel = repoModel;
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/repository/%@/accessToken",[NXCommonUtils currentRMSAddress],repoId]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}

/**
 Response Object Format Is Just Like Follows:
 
{
     "statusCode":200,
     "message":"OK",
     "serverTime":1474591551519,
     "results":{
         "accessToken":"Znb8BSROLVAAAAAAAAAB3O3PJvPw25xpb13EtNnx6XuPGGVYgFxmYOcur"
     }
 }
 
 if rms return 5005, should Re-Auth
 
 {
 "statusCode": 5005,
 "message": "Not authorized or expired.",
 "serverTime": 1488338175439,
 "results": {
 "authURL": "https://rmtest.nextlabs.com/rms/json/OAuthManager/DBAuth/DBAuthStart"
 }
 }
 
*/

- (Analysis)analysisReturnData {
    WeakObj(self);
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
       
        NXGetAccessTokenAPIResponse *apiResponse = [[NXGetAccessTokenAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            NSDictionary *returnDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if(returnDic[@"results"]) {
               
                if (apiResponse.rmsStatuCode == 5005) {
                    NSString *authURL = returnDic[@"results"][@"authURL"];
                    apiResponse.authURL = authURL;}
                else if(apiResponse.rmsStatuCode == 200){
                    NSString *accessToken = returnDic[@"results"][@"accessToken"];
                    StrongObj(self);
                    switch (self.repoModel.service_type.integerValue) {
                        case kServiceBOX:
                        case kServiceOneDrive:
                            {
                                accessToken = [NSString stringWithFormat:@"Bearer %@", accessToken];
                            }
                            break;
                        case kServiceDropbox:
                        case kServiceGoogleDrive:
                        case kServiceSharepointOnline:
                        {
                            accessToken = [NSString stringWithFormat:@"Bearer %@", accessToken];
                        }
                            break;
                            
                        default:
                            break;
                    }
                    apiResponse.accessToken = accessToken;
                }
            }
        }
        return apiResponse;
        
    };
    return analysis;
}
@end

@implementation NXGetAccessTokenAPIResponse
@end
