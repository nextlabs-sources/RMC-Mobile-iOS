//
//  NXProjectGetMemberDetailsAPI.h
//  nxrmc
//
//  Created by xx-huang on 26/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"
#import "NXProjectMemberModel.h"

#define PROJECT_ID    @"projectId"
#define MEMBER_ID     @"memberId"

@interface NXProjectGetMemberDetailsAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXProjectGetMemberDetailsAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong)NXProjectMemberModel *memberDetail;

@end
