//
//  NXProjectListMembersAPI.m
//  nxrmc
//
//  Created by xx-huang on 22/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectListMembersAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXProjectMemberModel.h"

#pragma mark -NXProjectListMembersAPIRequest
@interface NXProjectListMembersAPIRequest()
@property(nonatomic, strong) NSNumber *projectId;
@end
@implementation NXProjectListMembersAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSNumber *page = object[PAGE];
        NSNumber *projectId = object[PROJECT_ID];
        self.projectId = projectId;
        NSNumber *size = object[SIZE];
        NSNumber *orderBy = object[ORDERBY];
        NSNumber *picture = object[PICTURE];
        
        NSString *orderByType;
        NSString *shouldReturnPic;
        
        if ([picture boolValue])
        {
            shouldReturnPic = @"true";
        }
        else
        {
            shouldReturnPic = @"false";
        }
        
        switch ([orderBy integerValue])
        {
            case ListMemberOrderByTypeDisplayNameAscending:

                orderByType = @"displayName";

                break;

            case ListMemberOrderByTypeCreateTimeAscending:
                orderByType = @"creationTime";
                break;

            case ListMemberOrderByTypeDisplayNameDescending:

                orderByType = @"-displayName";
                break;

            case ListMemberOrderByTypeCreateTimeDescending:

                orderByType = @"-creationTime";
                break;
                
            default:
                orderByType = @"creationTime";
                
                break;
        }
    
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/members?page=%@&size=%@&orderBy=%@&picture=%@",[NXCommonUtils currentRMSAddress],projectId,page,size,orderByType,shouldReturnPic]];
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
         "detail": {
             "totalMembers": 2,
             "members": [
             {
             "userId": 1,
             "displayName": "fengchao1993@gmail.com",
             "email": "fengchao1993@gmail.com",
             "creationTime": 1470290028965
             },
             {
             "userId": 2,
             "displayName": "FENG CHAO",
             "email": "chao.feng@nextlabs.com",
             "creationTime": 1470292723663
             }
             ]
         }
     }
 }
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectListMembersAPIResponse *response = [[NXProjectListMembersAPIResponse alloc] init];
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
            NSDictionary *resultDic = returnDic[@"results"];
            NSDictionary *detailDic = resultDic[@"detail"];
            
            NSNumber *totalMember = detailDic[@"totalMembers"];
            NSArray *membersArray = detailDic[@"members"];
            NSMutableArray *membersItemArray = [[NSMutableArray alloc] init];
            
            if (detailDic.count > 0)
            {
                for (NSMutableDictionary *memberDic in membersArray)
                {
                    NXProjectMemberModel *memberItem = [[NXProjectMemberModel alloc] initWithDictionary:memberDic];
                    memberItem.projectId = self.projectId;
                    [membersItemArray addObject:memberItem];
                }
                
                response.membersItems = membersItemArray;
            }
            
            response.totalMembers = totalMember;
        }
        return response;
    };
    
    return analysis;
}
@end

#pragma mark -NXProjectListMembersAPIResponse

@implementation NXProjectListMembersAPIResponse

-(instancetype)init
{
    self = [super init];
    if (self) {
        _totalMembers = nil;
        _membersItems = [[NSMutableArray alloc] init];
    }
    return self;
}
@end



