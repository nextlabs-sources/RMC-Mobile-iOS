//
//  NXGetTenantPreferenceAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/1/15.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"



@interface NXGetTenantPreferenceAPIRequest : NXSuperRESTAPIRequest

@end
@interface NXGetTenantPreferenceAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong)NSDictionary *perenceDic;
@end

