//
//  NXResetPasswordAPI.h
//  nxrmc
//
//  Created by EShi on 3/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#define NXResetPasswordRequestOldPSWKey @"NXResetPasswordRequestOldPSWKey"
#define NXResetPasswordRequestNewPSWKey @"NXResetPasswordRequestNewPSWKey"

@interface NXResetPasswordRequest : NXSuperRESTAPIRequest

@end

@interface NXResetPasswordResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSString *ticket;
@property(nonatomic, strong) NSNumber *ttl;
@end
