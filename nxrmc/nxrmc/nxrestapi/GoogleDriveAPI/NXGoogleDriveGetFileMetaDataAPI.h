//
//  NXGoogleDriveGetFileMetaDataAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 28/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXGoogleDriveGetFileMetaDataQuery : NSObject
@property (nonatomic,strong) NSString *fields;
+ (instancetype)query;
@end

@interface NXGoogleDriveGetFileMetaDataAPIRequest:NX3rdRepoRESTAPIRequest
@end

@interface NXGoogleDriveGetFileMetaDataAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic, copy) NSString *mimeType;
@end
