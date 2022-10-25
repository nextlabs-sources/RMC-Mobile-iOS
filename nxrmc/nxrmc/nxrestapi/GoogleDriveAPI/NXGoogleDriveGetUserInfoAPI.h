//
//  NXGoogleDriveGetUserInfoAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXGoogleDriveGetUserInfoQuery : NSObject
@property (nonatomic,strong) NSString *fields;
+ (instancetype)query;
@end

@interface NXGoogleDriveGetUserInfoAPIRequest:NX3rdRepoRESTAPIRequest
@end

@interface NXGoogleDriveGetUserInfoAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic,strong) NSNumber *limit;
@property (nonatomic,strong) NSNumber *usage;
@property (nonatomic,copy) NSString *displayName;
@property (nonatomic,copy) NSString *emailAddress;
@end



