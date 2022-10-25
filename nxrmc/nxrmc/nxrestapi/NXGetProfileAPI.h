//
//  NXGetProfileAPI.h
//  nxrmc
//
//  Created by nextlabs on 12/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXGetProfileAPI : NXSuperRESTAPIRequest

@end

@interface NXGetProfileResponse : NXSuperRESTAPIResponse

@property(nonatomic, strong) id result;

@end
