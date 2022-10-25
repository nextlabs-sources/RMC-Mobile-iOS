//
//  NXUpdateRepositoryAPI.h
//  nxrmc
//
//  Created by EShi on 8/10/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"



@interface NXUpdateRepositoryRequest : NXSuperRESTAPIRequest
// NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end


@interface NXUpdateRepositoryResponse: NXSuperRESTAPIResponse
@end
