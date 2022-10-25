//
//  NXGoogleDriveFileListAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 06/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"
#import "NXGoogleDriveFileBase.h"
#import "NXGoogleDateTime.h"


@interface NXGoogleDriveFileListAPIRequest:NX3rdRepoRESTAPIRequest
@end

@interface NXGoogleDriveFileListAPIResponse:NX3rdRepoRESTAPIResponse<NSCopying>
@property (nonatomic, copy, nullable) NSString *kind;
@property (nonatomic, copy, nullable) NSString *nextPageToken;
@property (nonatomic, strong, nullable) NSMutableArray<NXGoogleDriveFileBase *> *files;
@property (nonatomic, assign) BOOL incompleteSearch;
@end

