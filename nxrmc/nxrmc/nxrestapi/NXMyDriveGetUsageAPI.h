//
//  NXMyDriveGetUsageAPI.h
//  nxrmc
//
//  Created by EShi on 3/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXMyDriveGetUsageRequeset : NXSuperRESTAPIRequest

@end

@interface NXMyDriveGetUsageResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSNumber *usage;
@property(nonatomic, strong) NSNumber *quota;
@property(nonatomic, strong) NSNumber *myVaultUsage;
@property(nonatomic, strong) NSNumber *vaultQuota;
@end
