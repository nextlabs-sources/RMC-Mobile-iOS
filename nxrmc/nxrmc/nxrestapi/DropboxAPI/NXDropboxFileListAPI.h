//
//  NXDropboxFileListAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 07/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXDropboxFileItem:NSObject

/// A unique identifier for the file.
@property (nonatomic, copy) NSString * _Nonnull id_;

/// The last time the file was modified on Dropbox.
@property (nonatomic, strong) NSDate * _Nullable serverModified;

@property (nonatomic, strong) NSDate * _Nullable clientModified;

/// The file size in bytes.
@property (nonatomic, strong) NSNumber * _Nonnull size;

/// The cased path to be used for display purposes only. In rare instances the
/// casing will not correctly match the user's filesystem, but this behavior
/// will match the path provided in the Core API v1, and at least the last path
/// component will have the correct casing. Changes to only the casing of paths
/// won't be returned by `listFolderContinue`. This field will be null if the
/// file or folder is not mounted.
@property (nonatomic, copy) NSString * _Nullable pathDisplay;

/// The last component of the path (including extension). This never contains a
/// slash.
@property (nonatomic, copy) NSString * _Nonnull name;

/// file type file/folder
@property (nonatomic, copy) NSString * _Nonnull tag;


@end


@interface NXDropboxFileListAPIRequest:NX3rdRepoRESTAPIRequest
@property (nonatomic, strong,nullable) NSString *cursor;
@end

@interface NXDropboxFileListAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic, strong, nullable) NSMutableArray<NXDropboxFileItem *> *files;
@property (nonatomic, strong, nullable) NSNumber *hasMore;
@property (nonatomic, strong,nullable) NSString *cursor;
@end
