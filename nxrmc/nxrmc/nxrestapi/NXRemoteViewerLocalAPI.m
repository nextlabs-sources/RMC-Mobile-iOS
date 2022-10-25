//
//  NXRemoteViewerLocalAPI.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/15/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRemoteViewerLocalAPI.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMultipartFormDataMaker.h"
#import "NXLProfile.h"
@implementation NXRemoteViewerLocalModel

@end

@implementation NXRemoteViewerLocalRequest
-(NSMutableURLRequest *) generateRequestObject:(NXRemoteViewerLocalModel *)object
{
    if (self.reqRequest == nil) {
        NXLProfile *profile = [NXLoginUser sharedInstance].profile;
        NSString *userName = profile.userName;
        NSString *fileName = object.fileName;
        NSData *fileContentData = object.fileContent;
        NSString *tenantName = [NXCommonUtils currentTenant];
        NSString *tenantId = profile.individualMembership.tenantId;
        
        NSInteger operations = object.operations;
        
        [[NSTimeZone localTimeZone] secondsFromGMT];
        NSUInteger offSet = [[NSTimeZone localTimeZone] secondsFromGMT] /60;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/remoteView/local", [NXCommonUtils currentRMSAddress]]]];
        [request setHTTPMethod:@"POST"];
        
        NSDictionary *jsonDict = @{@"parameters":@{@"userName":userName,
                                                   @"tenantId":tenantId,
                                                   @"tenantName":tenantName,
                                                   @"fileName":fileName,
                                                   @"offSet": @(-offSet),
                                                   @"operations":@(operations)}};
        
        NSString *jsonString = [jsonDict toJSONFormatString:nil];
        
        NSString *stringBoundary =@"----WebKitFormBoundary7MA4YWxkTrZu0gW";
        [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
        
        NXMultipartFormDataMaker *formdataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:stringBoundary];
        [formdataMaker addTextParameter:@"API-input" parameterValue:jsonString];
        [formdataMaker addFileParameter:@"file" fileName:fileName fileData:fileContentData];
        [formdataMaker endFormData];
        NSData *formData = [formdataMaker getFormData];
        [request setHTTPBody:formData];
        
        self.reqRequest = request;
        
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXRemoteViewerResponse *response = [[NXRemoteViewerResponse alloc] init];
        NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            [response analysisResponseData:data];
        }
        return response;
    };
    return analysis;
}

@end

@implementation NXRemoteViewerResponse

- (void)analysisResponseData:(NSData *)responseData {
    [super analysisResponseData:responseData];
    NSError *error = nil;
    NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        DLog(@"%@", error.localizedDescription);
    }
    if ([returnDic objectForKey:@"results"]) {
        NSDictionary *resultDic = [returnDic objectForKey:@"results"];
        if ([resultDic objectForKey:@"cookies"]) {
            self.cookies = [resultDic objectForKey:@"cookies"];
        }
        if ([resultDic objectForKey:@"viewerURL"]) {
            self.viewerURL = [resultDic objectForKey:@"viewerURL"];
        }
        if ([resultDic objectForKey:@"owner"]) {
            NSNumber *isOwner = [resultDic objectForKey:@"owner"];
            self.isOwner = isOwner.boolValue;
        }
        if ([resultDic objectForKey:@"permissions"]) {
            self.permissions = ((NSNumber *)[resultDic objectForKey:@"permissions"]).longValue;
        }
        if ([resultDic objectForKey:@"membership"]) {
            self.ownerId = [resultDic objectForKey:@"membership"];
        }
        if ([resultDic objectForKey:@"duid"]) {
            self.duid = [resultDic objectForKey:@"duid"];
        }
    }
}

- (void)analysisResponseJSONDict:(NSDictionary *)jsonDict {
    //
}
@end
