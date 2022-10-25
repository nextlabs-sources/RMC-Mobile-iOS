//
//  NXGoogleDriveDownloadAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 06/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXGoogleDriveDownloadAPIRequest:NX3rdRepoRESTAPIRequest
@property (nonatomic, assign) BOOL isGoogleDoc;
@property (nonatomic, copy, nonnull) NSString *mimeType;
@end

@interface NXGoogleDriveDownloadAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic, strong, nullable) NSData *fileData;
@end
