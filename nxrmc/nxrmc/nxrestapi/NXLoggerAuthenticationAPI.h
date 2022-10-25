//
//  NXLoggerAuthentication.h
//  nxrmc
//
//  Created by 时滕 on 2019/11/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXLoggerAuthenticateRequest : NXSuperRESTAPIRequest

@end

@interface NXLoggerAuthenticateResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSString *loggerToken;
@end

NS_ASSUME_NONNULL_END
