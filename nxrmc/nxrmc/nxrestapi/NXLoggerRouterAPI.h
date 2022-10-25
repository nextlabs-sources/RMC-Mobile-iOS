//
//  NXLoggerRouter.h
//  nxrmc
//
//  Created by 时滕 on 2019/11/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXLoggerRouterRequest : NXSuperRESTAPIRequest

@end

@interface NXLoggerRouterResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSString *loggerURL;
@end

NS_ASSUME_NONNULL_END
