//
//  NXProjectRecentFilesAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXProjectRecentFilesAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
-(Analysis)analysisReturnData;

@end

@interface NXProjectRecentFilesAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic ,strong) NSMutableArray *fileItems;
@property (nonatomic ,strong) NSDictionary *spaceDict;

@end
