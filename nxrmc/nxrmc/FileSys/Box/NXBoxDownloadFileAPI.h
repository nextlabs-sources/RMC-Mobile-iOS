//
//  NXBoxDownloadFileAPI.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 12/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NX3rdRepoRESTAPI.h"

@interface NXBoxDownloadFileRequest : NX3rdRepoRESTAPIRequest

@end

@interface NXBoxDownloadFileResponse : NX3rdRepoRESTAPIResponse
@property(nonatomic, strong) NSData *fileData;
@end
