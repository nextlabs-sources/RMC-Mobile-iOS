//
//  NXProjectFileListingAPI.h
//  nxrmc
//
//  Created by helpdesk on 18/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
// parameters model
#import "NXProjectFileListParameterModel.h"

@interface NXProjectFileListingAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
-(Analysis)analysisReturnData;
@end
// api response
@interface NXProjectFileListingAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic ,strong) NSMutableArray *fileItems;
@end
