//
//  NXPolicyGetPermissionsForCopyAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2022/5/20.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXPolicyGetPermissionsForCopyAPIRequest : NXSuperRESTAPIRequest
-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end
@interface  NXPolicyGetPermissionsForCopyAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NSString *watermarkStr;
@property (nonatomic, strong) NSArray *rightsArray;

@end
NS_ASSUME_NONNULL_END
