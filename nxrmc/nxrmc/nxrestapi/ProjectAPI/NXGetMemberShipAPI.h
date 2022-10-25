//
//  NXGetMemberShipAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 19/04/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXGetMemberShipAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end

@class NXProjectModel;
@interface NXGetMemberShipAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NXProjectModel *projectItem;
@end
