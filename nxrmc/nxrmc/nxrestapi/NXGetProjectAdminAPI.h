//
//  NXGetProjectAdminAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2019/4/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXGetProjectAdminAPIRequest : NXSuperRESTAPIRequest
@end

@interface NXGetProjectAdminAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong)NSArray *projectAdminArr;
@property(nonatomic, strong)NSArray *tenantAdminArr;
@end

NS_ASSUME_NONNULL_END
