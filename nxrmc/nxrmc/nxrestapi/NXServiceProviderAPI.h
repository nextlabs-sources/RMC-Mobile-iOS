//
//  NXServiceProviderAPI.h
//  nxrmc
//
//  Created by 时滕 on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXServiceProviderRequest : NXSuperRESTAPIRequest

@end

@interface NXServiceProviderResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSMutableArray *supportedServiceTypes;
@end

NS_ASSUME_NONNULL_END
