//
//  NXDropboxGetCurrentAccountAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXDropboxGetCurrentAccountAPIRequest:NX3rdRepoRESTAPIRequest
@end

@interface NXDropboxGetCurrentAccountAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic, copy, nullable) NSString *userEmail;
@property (nonatomic, copy, nullable) NSString *userDisplayName;

@end
