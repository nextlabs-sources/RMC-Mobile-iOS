//
//  NXMyVaultFileDeleteAPI.m
//  nxrmc
//
//  Created by nextlabs on 1/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMyVaultFileDeleteAPI.h"
#import "NXCommonUtils.h"

#define kFilePathId @"pathId"

@interface NXMyVaultFileDeleteAPI ()

@end

@implementation NXMyVaultFileDeleteAPI

- (NSURLRequest *)generateRequestObject:(id)object {
    if (!self.reqRequest) {
        if ([object isKindOfClass:[NXMyVaultFile class]]) {
            NSError *error;
            NXMyVaultFile *file = (NXMyVaultFile *)object;
            NSDictionary *jDict = @{@"parameters":@{kFilePathId:file.fullServicePath}};
            NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                DLog(@"%@", error.localizedDescription);
            }
            NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/myVault/%@/delete",[NXCommonUtils currentRMSAddress], file.duid]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            
            [request setHTTPBody:bodyData];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"consumes"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSuperRESTAPIResponse *response = [[NXSuperRESTAPIResponse alloc] init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return response;
    };
    
    return analysis;
}

@end
