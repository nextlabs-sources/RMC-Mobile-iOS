//
//  NXGetRepositoryDetailAPI.m
//  nxrmc
//
//  Created by EShi on 6/13/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGetRepositoryDetailsAPI.h"
#import "XMLWriter.h"
#import "NXXMLDocument.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXKeyChain.h"
#import "NXLProfile.h"
#pragma mark ---------- NXGetRepositoryDetailsAPIRequest ----------
@interface NXGetRepositoryDetailsAPIRequest()
@end

@implementation NXGetRepositoryDetailsAPIRequest
#pragma mark - overwrite NXSuperRESTAPI SETTER/GETTER
-(NSString *) restRequestType
{
    return @"GetRepositoryDetailsService";
}

#pragma mark -  NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil) {
     
  
        
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/repository", [NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;

    }
    
    return self.reqRequest;
   
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXGetRepositoryDetailsAPIResponse *rmsResponse = [[NXGetRepositoryDetailsAPIResponse alloc] init];
        // analysis the return data
        NSData *responseData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        [rmsResponse analysisResponseData:responseData];
        return rmsResponse;
        
    };
    return analysis;
}

@end

#pragma mark ---------- NXGetRepositoryDetailsAPIResponse ----------
@implementation NXGetRepositoryDetailsAPIResponse

#pragma mark - GETTER/SETTER
-(NSMutableArray *) rmsRepoList
{
    if (_rmsRepoList == nil) {
        _rmsRepoList = [[NSMutableArray alloc] init];
    }
    return _rmsRepoList;
}

- (void)analysisResponseData:(NSData *)responseData
{
    if (responseData) {
        [super analysisResponseStatus:responseData];
        NSError *error = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        if (!error) {
            NSDictionary *resultDict = result[@"results"];
            NSArray *repoItems = resultDict[@"repoItems"];
            NSMutableArray *repoArray=[NSMutableArray array];
            for (NSDictionary *rmsRepoItem in repoItems) {
                NXRMSRepoItem *repoItem = [[NXRMSRepoItem alloc] init];
                repoItem.repoId = rmsRepoItem[@"repoId"];
                repoItem.displayName = rmsRepoItem[@"name"];
                repoItem.repoType = rmsRepoItem[@"type"];
                repoItem.account = rmsRepoItem[@"accountName"];
                repoItem.accountId = rmsRepoItem[@"accountId"];
                repoItem.refreshToken =  rmsRepoItem[@"token"];
                repoItem.isShared = ((NSNumber *)rmsRepoItem[@"isShared"]).boolValue;
                repoItem.creationTime = ((NSNumber *)(rmsRepoItem[@"creationTime"] )).longLongValue /  1000;
                repoItem.isAuthed = YES;
                repoItem.isDefault = ((NSNumber *)rmsRepoItem[@"isDefault"]).boolValue;
                if ([rmsRepoItem.allKeys containsObject:@"providerClass"]) {
                  repoItem.providerClass = rmsRepoItem[@"providerClass"];
                }
                // sharepoint onpremise should check is Authed property
                if ([repoItem.repoType isEqualToString:RMS_REPO_TYPE_SHAREPOINT]) {
                    //now we use siteUrl for SHAREPOINT_ONPREMISE accountName (by stepnoval 2018.5.24)
                    
                    NSString *sharepointAccountId = [NSString stringWithFormat:@"%@^%@", repoItem.account,[NXLoginUser sharedInstance].profile.email];
                    repoItem.accountId = sharepointAccountId;
                    NSString* psw = [NXKeyChain load:sharepointAccountId];
                    if (psw.length > 0) {
                        repoItem.isAuthed = YES;
                    }else{
                        repoItem.isAuthed = NO;
                    }
                    
                    NSArray *localRepoArray = [[NXLoginUser sharedInstance].myRepoSystem allReposiories];
                    for (NXRepositoryModel *model in localRepoArray) {
                        if ([sharepointAccountId caseInsensitiveCompare:model.service_account_id] == NSOrderedSame && ![model.service_alias isEqualToString:repoItem.displayName]) {
                             repoItem.isAuthed = NO;
                        }
                        
                        if ([sharepointAccountId caseInsensitiveCompare:model.service_account_id] == NSOrderedSame && [model.service_alias isEqualToString:repoItem.displayName] && ![repoItem.repoId isEqualToString:model.service_id]) {
                              repoItem.isAuthed = NO;
                        }
                    }
                }
                
                // special for MyDrive
                if (repoItem.isDefault) {
                    repoItem.repoType = RMS_REPO_TYPE_SKYDRMBOX;
                    repoItem.isAuthed = YES;
                    repoItem.account = [NXLoginUser sharedInstance].profile.email;
                    repoItem.accountId = [NSString stringWithFormat:@"%@-%@", [NXLoginUser sharedInstance].profile.individualMembership.tenantId, [NXLoginUser sharedInstance].profile.userId];
                    repoItem.refreshToken = [NXLoginUser sharedInstance].profile.ticket;
                    repoItem.displayName = @"MyDrive";
                }
                [repoArray addObject:repoItem];
            }
            self.rmsRepoList=repoArray;
        }
    }
}
@end


