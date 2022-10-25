//
//  NXMyVaultMetadataAPI.m
//  nxrmc
//
//  Created by nextlabs on 1/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMyVaultMetadataAPI.h"

#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXLFileValidateDateModel.h"
#import "NXLProfile.h"
#define kFilePathID      @"pathId"

#define kResults        @"results"
#define kDetail         @"detail"
#define kFileName       @"fileName"
#define kRecipients     @"recipients"
#define kFileLink       @"fileLink"
#define kProtectedOn    @"protectedOn"
#define kSharedOn       @"sharedOn"
#define kRights         @"rights"
#define kValidity       @"validity"

@implementation NXMyVaultMetadataRequest

- (NSURLRequest *)generateRequestObject:(id)object {
    if (!self.reqRequest) {
        if ([object isKindOfClass:[NXMyVaultFile class]]) {
            NSError *error;
            NXMyVaultFile *file = (NXMyVaultFile *)object;
            NSDictionary *jDict = @{@"parameters":@{kFilePathID:file.fullServicePath}};
            NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                DLog(@"%@", error.localizedDescription);
            }
            NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/myVault/%@/metadata",[NXCommonUtils currentRMSAddress], file.duid]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            
            [request setHTTPBody:bodyData];
            [request setHTTPMethod:@"POST"];
            [request setValue:[NXLoginUser sharedInstance].profile.userId forHTTPHeaderField:@"userId"];
            [request setValue:[NXLoginUser sharedInstance].profile.ticket forHTTPHeaderField:@"ticket"];
            [request setValue:@"application/json" forHTTPHeaderField:@"consumes"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXMyVaultMetadataResponse *response = [[NXMyVaultMetadataResponse alloc] init];
        NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            [response analysisResponseStatus:data];
            NSError *error = nil;
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                DLog(@"%@", error.localizedDescription);
            }
            if ([returnDic objectForKey:kResults]) {
                NSDictionary *resultDic = [returnDic objectForKey:kResults];
                if ([resultDic objectForKey:kDetail]) {
                    NSDictionary *detail = [resultDic objectForKey:kDetail];
                    if ([detail objectForKey:kFileName]) {
                        response.filename = [detail objectForKey:kFileName];
                    }
                    if ([detail objectForKey:kFileLink]) {
                        response.fileLink = [detail objectForKey:kFileLink];
                    }
                    if ([detail objectForKey:kProtectedOn]) {
                        NSNumber *protectedOn = [detail objectForKey:kProtectedOn];
                        response.protectedOn = [NSNumber numberWithLongLong:protectedOn.longLongValue/1000];
                    }
                    if ([detail objectForKey:kSharedOn]) {
                        NSNumber *sharedOn = [detail objectForKey:kSharedOn];
                        response.protectedOn = [NSNumber numberWithLongLong:sharedOn.longLongValue/1000];
                    }
                    if ([detail objectForKey:kRecipients]) {
                        response.recipients = [detail objectForKey:kRecipients];
                    }
                    if ([detail objectForKey:kRights]) {
                        response.rights = [detail objectForKey:kRights];
                    }
                    if ([detail objectForKey:kValidity]) {
                        NSDictionary *validityDict = [detail objectForKey:kValidity];
                        NXLFileValidateDateModel *validateDateModel = nil;
                        if ([validityDict allKeys].count == 0) {
                            validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
                        }else if([validityDict allKeys].count == 1) {
                            long long endSeconds = ((NSNumber *)(validityDict[@"endDate"])).longLongValue / 1000;
                            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endSeconds];
                            validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeAbsolute withStartTime:[NSDate date] endTIme:endDate];
                        }else if([validityDict allKeys].count == 2) {
                            long long startSeconds = ((NSNumber *)(validityDict[@"startDate"])).longLongValue / 1000;
                            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startSeconds];
                            long long endSeconds = ((NSNumber *)(validityDict[@"endDate"])).longLongValue / 1000;
                            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endSeconds];
                            validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeRange withStartTime:startDate endTIme:endDate];
                        }
                        response.validateDateModel = validateDateModel;
                    }
                }
            }
        }
        
        return response;
    };
    return analysis;
}

@end

@implementation NXMyVaultMetadataResponse

@end
