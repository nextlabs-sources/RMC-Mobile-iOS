//
//  NXAddRepositoryAPIRequest.m
//  nxrmc
//
//  Created by EShi on 6/8/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAddRepositoryAPI.h"
#import "NXRMCDef.h"
#import "NXXMLDocument.h"
#import "XMLWriter.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

#pragma mark ---------- NXAddRepositoryAPIRequest ----------
@interface NXAddRepositoryAPIRequest()

@end
@implementation NXAddRepositoryAPIRequest
#pragma mark - INIT
-(instancetype) initWithAddRepoItem:(NXRMCRepoItem *) repoItem
{
    self = [super init];
    if (self) {
        _addedService = repoItem;
    }
    return self;
}

#pragma mark - overwrite NXSuperRESTAPIRequest SETTER/GETTER
-(NSString *) restRequestType
{
    return @"AddRepoService";
}

-(NSString *) restRequestFlag
{
    assert(self.addedService);
    return NXREST_UUID(self.addedService);
}

-(void) genRestRequest:(id)object
{
    // if the request is new create not from cached file, objcet should be NXBoudService type
    self.addedService = (NXRMCRepoItem *) object;
    
    NSData *dataContent = [self genRequestBodyData:object];
    
    NSString *url = [NSString stringWithFormat:@"%@/rs/repository", [NXCommonUtils currentRMSAddress]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[dataContent length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:dataContent];
    
    self.reqRequest = request;

}

#pragma mark -  NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    // if self.reqRequest is nil, means the object is from cached files
    // directly use it.
    if (self.reqRequest == nil) {
        [self genRestRequest:object];
    }
    
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error)
    {
        NXAddRepositoryAPIResponse *response = [[NXAddRepositoryAPIResponse alloc] init];
        NSData *contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (contentData) {
            [response analysisResponseStatus:contentData];
            NSError *error = nil;
            NSDictionary *jsonDict = [contentData toJSONDict:&error];
            response.repoId = jsonDict[@"results"][@"repoId"];
        }
        return response;
    };
    
    return analysis;
}

#pragma mark - overwrite NXSuperRESTAPIRequest
- (NSData *) genRequestBodyData:(id) object
{
    NXRMCRepoItem *repoItem = (NXRMCRepoItem *)object;

    if(repoItem.service_type.integerValue == kServiceSharepointOnline || repoItem.service_type.integerValue == kServiceSharepoint)
    {
//        NSString *siteURL = [repoItem.service_account_id componentsSeparatedByString:@"^"].firstObject;
//        NSString *userAccount = [repoItem.service_account_id componentsSeparatedByString:@"^"].lastObject;
//        repoItem.service_account_id = userAccount;
//        repoItem.service_account = siteURL;
    }
    
    NSString *repoInfoString = [NSString stringWithFormat:@"{\"name\":\"%@\",\"type\":\"%@\",\"isShared\":false,\"accountName\":\"%@\",\"accountId\":\"%@\",\"token\":\"%@\",\"preference\":\"\",\"creationTime\":%lld}",repoItem.service_alias, [NXCommonUtils rmcToRMSRepoType:repoItem.service_type], repoItem.service_account, repoItem.service_account_id, repoItem.service_account_token, (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
    NSDictionary *bodyDict = @{@"parameters":@{@"deviceId":[NXCommonUtils deviceID],
                                               @"deviceType":@"MOBILE",
                                               @"repository":repoInfoString}};
    NSError *error = nil;
    NSData *jsonData = [bodyDict toJSONFormatData:&error];
    if (error) {
        NSLog(@"jsonSerialize failed %@", error);
    }
    return jsonData;
}


@end


#pragma mark ---------- NXAddRepositoryAPIResponse ----------
@implementation NXAddRepositoryAPIResponse
@end
