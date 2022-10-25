//
//  NXRemoveRepositoryAPI.m
//  nxrmc
//
//  Created by EShi on 6/13/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRemoveRepositoryAPI.h"
#import "NXRMCDef.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXXMLDocument.h"
#import "XMLWriter.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXLProfile.h"
#pragma mark ---------- NXRemoveRepositoryAPIRequest ----------
@implementation NXRemoveRepositoryAPIRequest
#pragma mark - overwrite NXSuperRESTAPIRequest
-(NSString *) restRequestType
{
    return @"RemoveRepoService";
}

-(void) genRestRequest:(id)object
{
    NSData *bodyData = [self genRequestBodyData:object];
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/repository", [NXCommonUtils currentRMSAddress]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:bodyData];
    [request setHTTPMethod:@"DELETE"];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // for RMS auth head
    [request setValue:[NXLoginUser sharedInstance].profile.userId forHTTPHeaderField:@"userId"];
    [request setValue:[NXLoginUser sharedInstance].profile.ticket forHTTPHeaderField:@"ticket"];
    self.reqRequest = request;
}
#pragma mark -  NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    // if object class is NSData, means the object is from cached files
    // directly use it.
    if (self.reqRequest == nil) {
        [self genRestRequest:object];
    }
    
    
    return self.reqRequest;

}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXRemoveRepositoryAPIResponse *response = [[NXRemoveRepositoryAPIResponse alloc] init];
        NSData *contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (contentData) {
            [response analysisResponseStatus:contentData];
        }
        return response;
    };
    
    return analysis;
}

#pragma mark - overwrite NXSuperRESTAPIRequest
- (NSData *) genRequestBodyData:(id)object
{
    
    NSString *deleteServiceId = (NSString *) object;
    NSDictionary *jsonDict = @{@"parameters":@{@"deviceId":[NXCommonUtils deviceID],
                                               @"deviceType":@"MOBILE",
                                               @"repoId":deleteServiceId}};
    NSError *error = nil;
    NSData *bodyData = [jsonDict toJSONFormatData:&error];
    return bodyData;

}
@end

#pragma mark ---------- NXRemoveRepositoryAPIResponse ----------
@implementation NXRemoveRepositoryAPIResponse
@end

