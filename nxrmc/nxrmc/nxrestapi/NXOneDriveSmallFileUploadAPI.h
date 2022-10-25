//
//  NXOneDriveSmallFileUploadAPI.h
//  nxrmc
//
//  Created by 时滕 on 2020/5/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NX3rdRepoRESTAPI.h"
#import "NXOneDriveFileItem.h"

#define ONE_DRIVE_SMALL_UPLOAD_PARENT_FOLDER_KEY @"ONE_DRIVE_SMALL_UPLOAD_PARENT_FOLDER_KEY"
#define ONE_DRIVE_SMALL_UPLOAD_FILE_NAME_KEY @"ONE_DRIVE_SMALL_UPLOAD_FILE_NAME_KEY"
#define ONE_DRIVE_SMALL_UPLOAD_FILE_LOCAL_PATH_KEY @"ONE_DRIVE_SMALL_UPLOAD_FILE_LOCAL_PATH_KEY"

NS_ASSUME_NONNULL_BEGIN

@interface NXOneDriveSmallFileUploadRequest : NX3rdRepoRESTAPIRequest <NXRESTAPIScheduleProtocol>

@end

@interface NXOneDriveSmaillFileUploadResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong) NXOneDriveFileItem *uploadedFile;
@end

NS_ASSUME_NONNULL_END
