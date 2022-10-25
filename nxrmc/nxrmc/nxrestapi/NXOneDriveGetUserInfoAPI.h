//
//  NXOneDriveGetUserInfoAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//


#import "NX3rdRepoRESTAPI.h"
@interface NXOneDriveGetUserInfoAPIRequest : NX3rdRepoRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@interface NXOneDriveGetUserInfoAPIResponse : NX3rdRepoRESTAPIResponse
@property (nonatomic, strong)NSDictionary *userInfo;
@end
