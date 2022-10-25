//
//  NXDropboxGetSpaceUsageAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXDropboxGetSpaceUsageAPIRequest:NX3rdRepoRESTAPIRequest
@end

@interface NXDropboxGetSpaceUsageAPIResponse:NX3rdRepoRESTAPIResponse
/// The user's total space usage (bytes).
@property (nonatomic, strong) NSNumber * _Nullable used;
@property (nonatomic, strong) NSNumber * _Nullable allocated;
@property (nonatomic, copy) NSString * _Nullable tag;

@end
