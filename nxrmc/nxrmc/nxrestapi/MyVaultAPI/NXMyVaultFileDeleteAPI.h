//
//  NXMyVaultFileDeleteAPI.h
//  nxrmc
//
//  Created by nextlabs on 1/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXMyVaultFileDeleteAPI : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end
