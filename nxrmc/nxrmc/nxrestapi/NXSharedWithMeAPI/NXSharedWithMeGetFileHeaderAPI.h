//
//  NXSharedWithMeGetFileHeaderAPI.h
//  nxrmc
//
//  Created by Sznag on 2020/11/7.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXSharedWithMeGetFileHeaderAPIRequest : NXSuperRESTAPIRequest

@end
@interface NXSharedWithMeGetFileHeaderAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSData *fileData;
@end
NS_ASSUME_NONNULL_END
