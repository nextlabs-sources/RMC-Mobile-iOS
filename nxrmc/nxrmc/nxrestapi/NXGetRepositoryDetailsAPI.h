//
//  NXGetRepositoryDetailAPI.h
//  nxrmc
//
//  Created by EShi on 6/13/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXRMCStruct.h"

@interface NXGetRepositoryDetailsAPIRequest : NXSuperRESTAPIRequest
// NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end

@interface NXGetRepositoryDetailsAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSMutableArray * rmsRepoList;
- (void)analysisResponseData:(NSData *)responseData;

@end
