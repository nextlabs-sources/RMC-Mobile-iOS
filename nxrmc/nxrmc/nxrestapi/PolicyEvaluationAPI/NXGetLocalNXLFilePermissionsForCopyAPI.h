//
//  NXGetLocalNXLFilePermissionsForCopyAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2022/5/20.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXGetLocalNXLFilePermissionsForCopyAPIRequest : NXSuperRESTAPIRequest

@end
@interface NXGetLocalNXLFilePermissionsForCopyAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NSString *watermarkStr;
@property (nonatomic, strong) NSArray *rightsArray;
@end
NS_ASSUME_NONNULL_END
