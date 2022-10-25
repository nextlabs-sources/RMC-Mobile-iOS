//
//  NXDropboxDownloadFileAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 07/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NX3rdRepoRESTAPI.h"

@interface NXDropboxDownloadFileAPIRequest:NX3rdRepoRESTAPIRequest
@end

@interface NXDropboxDownloadFileAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic, strong, nullable) NSData *fileData;
@end
