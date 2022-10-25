//
//  NXNewestVersionAPI.h
//  nxrmc
//
//  Created by helpdesk on 5/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXNewestVersionAPIRequest : NXSuperRESTAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@interface NXNewestVersionAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong) NSString *version;
@end
