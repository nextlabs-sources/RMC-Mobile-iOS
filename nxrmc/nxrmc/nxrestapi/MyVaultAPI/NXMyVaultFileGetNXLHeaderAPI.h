//
//  NXMyVaultFileGetNXLHeaderAPI.h
//  nxrmc
//
//  Created by 时滕 on 2020/6/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXMyVaultFileGetNXLHeaderRequest : NXSuperRESTAPIRequest

@end

@interface NXMyVaultFileGetNXLHeaderResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSData *fileData;
@end

NS_ASSUME_NONNULL_END
