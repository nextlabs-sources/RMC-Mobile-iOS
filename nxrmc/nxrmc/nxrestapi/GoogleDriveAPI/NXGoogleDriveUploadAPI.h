//
//  NXGoogleDriveUploadAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/5/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXGoogleDriveUploadAPIRequest:NX3rdRepoRESTAPIRequest
@end

@interface NXGoogleDriveUploadAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic, strong, nullable) NSData *fileData;

@end

