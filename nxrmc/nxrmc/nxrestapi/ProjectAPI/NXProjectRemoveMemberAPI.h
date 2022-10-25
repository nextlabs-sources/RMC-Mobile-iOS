//
//  NXProjectRemoveMemberAPI.h
//  nxrmc
//
//  Created by xx-huang on 26/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define PROJECT_ID    @"projectId"
#define MEMBER_ID     @"memberId"

@interface NXProjectRemoveMemberAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXProjectRemoveMemberAPIResponse : NXSuperRESTAPIResponse

@end
