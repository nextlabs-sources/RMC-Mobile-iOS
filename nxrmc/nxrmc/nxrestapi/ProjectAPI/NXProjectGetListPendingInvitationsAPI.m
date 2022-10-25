//
//  NXProjectGetListPendingInvitationsAPI.m
//  nxrmc
//
//  Created by xx-huang on 26/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectGetListPendingInvitationsAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXPendingProjectInvitationModel.h"
@interface NXProjectGetListPendingInvitationsAPIRequest ()
@property(nonatomic, strong) NSNumber *projectId;
@end
@implementation NXProjectGetListPendingInvitationsAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSNumber *projectId = object[PROJECT_ID];
        self.projectId = projectId;
        NSString *size = object[SIZE];
        NSString *page = object[PAGE];
        NSString *orderBy = @"creationTime";
        NSString *searchString = object[SEARCH_STRING];
        
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/invitation/pending?page=%@&size=%@&orderBy=%@&q=email&searchString=%@",[NXCommonUtils currentRMSAddress],projectId,page,size,orderBy,searchString]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 Produces: application/json
 
 {
 "statusCode": 200,
 "message": "OK",
 "serverTime": 1484905488932,
 "results": {
 "pendingList":
 [
 {
 "invitationId": 1,
 "inviteeEmail": "fengchao1993@gmail.com",
 "inviterDisplayName": "Xifeng",
 "inviterEmail": "xifeng.zheng@nextlabs.com",
 "inviteTime": 1470290028965
 },
 {
 "invitationId": 2,
 "inviteeEmail": "rmsuser0@gmail.com",
 "inviterDisplayName": "Xifeng",
 "inviterEmail": "xifeng.zheng@nextlabs.com",
 "inviteTime": 1470290028965
 }
 ]
 }
 }
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
       NXProjectGetListPendingInvitationsAPIResponse *response = [[NXProjectGetListPendingInvitationsAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = returnDic[@"results"];
            NSDictionary *pendListDic = resultsDic[@"pendingList"];
            NSArray *invitations = pendListDic[@"invitations"];
            NSMutableArray *pendItems = [NSMutableArray array];
            for (NSDictionary *pendingItemDic in invitations) {
                NXPendingProjectInvitationModel *item = [[NXPendingProjectInvitationModel alloc]initWithDictionary:pendingItemDic];
                item.projectId = self.projectId;
                [pendItems addObject:item];
            }
            response.pendingArray = pendItems;
        }
        
        return response;
    };
    
    return analysis;
}

@end

@implementation NXProjectGetListPendingInvitationsAPIResponse
- (NSMutableArray*)pendingArray {
    if (!_pendingArray) {
        _pendingArray = [NSMutableArray array];
    }
    return _pendingArray;
}

@end
