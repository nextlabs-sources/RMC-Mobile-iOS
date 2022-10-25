//
//  NXProjectMetadataAPI.h
//  nxrmc
//
//  Created by helpdesk on 17/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
@interface NXProjectMetadataAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@class NXProjectModel;
@interface NXProjectMetadataAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NXProjectModel *projectItem;
@end
