//
//  NXSharedWithMeFileListAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXSharedWithMeFileListAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXSharedWithMeFileListAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic ,strong) NSMutableArray *itemsArray;
@end
