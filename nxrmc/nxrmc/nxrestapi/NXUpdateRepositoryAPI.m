//
//  NXUpdateRepositoryAPI.m
//  nxrmc
//
//  Created by EShi on 8/10/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXUpdateRepositoryAPI.h"
#import "NXRMCDef.h"
#import "NXXMLDocument.h"
#import "XMLWriter.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@implementation NXUpdateRepositoryRequest
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil && object && [object isKindOfClass:[NXRMCRepoItem class]]) {
        NSData *bodyData = [self genRequestBodyData:object];
        NSString *url = [NSString stringWithFormat:@"%@/rs/repository", [NXCommonUtils currentRMSAddress]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"PUT"];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:bodyData];

        self.reqRequest = request;

    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXUpdateRepositoryResponse *response = [[NXUpdateRepositoryResponse alloc] init];
        NSData *contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (contentData) {
            [response analysisResponseStatus:contentData];
        }
        return response;
    };
    return analysis;
}

-(NSData *) genRequestBodyData:(id)object
{
    NXRMCRepoItem *repoItem = (NXRMCRepoItem *) object;
    NSDictionary *bodyDict = @{@"parameters":@{@"deviceId":[NXCommonUtils deviceID],
                                               @"devictType":@"MOBILE",
                                               @"repoId":repoItem.service_id,
                                               @"name":repoItem.service_alias}};
    NSError *error = nil;
    NSData *jsonData = [bodyDict toJSONFormatData:&error];
    return jsonData;
}
@end

#pragma mark - NXUpdateRepositoryResponse
@implementation NXUpdateRepositoryResponse
@end
