//
//  NXOneDriveBigFileUploadCreateSessionAPI.h
//  nxrmc
//
//  Created by 时滕 on 2020/5/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

// refer from Miscrosoft https://docs.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_createuploadsession?view=odsp-graph-online
#import "NX3rdRepoRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

#define ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_FILE_NAME_KEY @"ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_FILE_NAME_KEY"
#define ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_CONFLICT_BEHAVIOR_KEY @"ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_CONFLICT_BEHAVIOR_KEY"
#define ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_TARGET_FOLDER_KEY @"ONE_DRIVE_BIG_FILE_UPLOAD_SESSION_TARGET_FOLDER_KEY"

@interface NXOneDriveBigFileUploadCreateSessionRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXOneDriveBigFileUploadCreateSessionResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong) NSURL *uploadSessionURL;
@end

NS_ASSUME_NONNULL_END
