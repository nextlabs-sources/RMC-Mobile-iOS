//
//  NXDropboxUploadFileAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/7.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NX3rdRepoRESTAPI.h"


@class NXDropboxFileItem;
@interface NXDropboxUploadFileAPIRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXDropboxUploadFileAPIResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong)NXDropboxFileItem *fileItem;
@end
@interface NXDropboxUploadFileStartAPIRequest : NX3rdRepoRESTAPIRequest

@end
@interface NXDropboxUploadFileStartAPIResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong)NSString *session_id;
@end

@interface NXDropboxUploadFileAppendAPIRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXDropboxUploadFileAppendAPIResponse : NX3rdRepoRESTAPIResponse

@end
@interface NXDropboxUploadFileFinishAPIRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXDropboxUploadFileFinishAPIResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong)NXDropboxFileItem *fileItem;
@end

