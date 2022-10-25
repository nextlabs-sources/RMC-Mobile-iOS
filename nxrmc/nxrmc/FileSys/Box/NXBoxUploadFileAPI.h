//
//  NXBoxUploadFileAPI.h
//  nxrmc
//
//  Created by Eren on 2020/5/13.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NX3rdRepoRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN
#define BOX_UPLOAD_FILE_NAME_KEY @"BOX_UPLOAD_FILE_NAME_KEY"
#define BOX_UPLOAD_FILE_PATH_KEY @"BOX_UPLOAD_FILE_PATH_KEY"
#define BOX_UPLOAD_PARENT_FOLDER_KEY @"BOX_UPLOAD_PARENT_FOLDER_KEY"

@interface NXBoxUploadFileRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXBoxUploadFileResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong) NXFile *uploadedFile;
@end

NS_ASSUME_NONNULL_END
