//
//  NXProjectListAPI.h
//  nxrmc
//
//  Created by helpdesk on 16/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

//typedef NS_ENUM(NSInteger, NXProjectListKindType) {
//    NXProjectListKindTypeAllProject = 1,
//    NXProjectListKindTypeUserOwnedProject,
//    NXProjectListKindTypeUserJoinedProject
//};
@interface NXProjectListAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@interface NXProjectListAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NSMutableArray *itemsArray;
@end
