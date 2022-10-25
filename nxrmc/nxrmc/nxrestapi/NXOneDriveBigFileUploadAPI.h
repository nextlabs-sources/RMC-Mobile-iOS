//
//  NXOneDriveBigFileUploadAPI.h
//  nxrmc
//
//  Created by 时滕 on 2020/5/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NX3rdRepoRESTAPI.h"
#import "NXOneDriveFileItem.h"

NS_ASSUME_NONNULL_BEGIN
#define ONE_DRIVE_BIG_FILE_UPLOAD_FILE_KEY @"ONE_DRIVE_BIG_FILE_UPLOAD_FILE_KEY"
#define ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_URL_KEY @"ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_URL_KEY"

@interface NXOneDriveBigFileUploadRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXOneDriveBigFileUploadResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong) NXOneDriveFileItem *uploadedFile;
@end

NS_ASSUME_NONNULL_END
