//
//  NXProjectGetListPendingInvitationsAPI.h
//  nxrmc
//
//  Created by xx-huang on 26/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"
#import "NXProjectMemberModel.h"

#define PROJECT_ID    @"projectId"
#define PAGE          @"page"
#define SIZE          @"size"
#define ORDERBY       @"orderBy"
#define SEARCH_STRING @"searchString"

@interface NXProjectGetListPendingInvitationsAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXProjectGetListPendingInvitationsAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong)NSMutableArray *pendingArray;
@end

