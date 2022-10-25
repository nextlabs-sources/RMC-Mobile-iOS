//
//  NXProjectListMembersAPI.h
//  nxrmc
//
//  Created by xx-huang on 22/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define PROJECT_ID   @"projectId"
#define PAGE         @"page"
#define SIZE         @"size"
#define ORDERBY      @"orderBy"
#define PICTURE      @"picture"
@interface NXProjectListMembersAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXProjectListMembersAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,assign)NSNumber *totalMembers;
@property (nonatomic,strong)NSMutableArray *membersItems;


@end
