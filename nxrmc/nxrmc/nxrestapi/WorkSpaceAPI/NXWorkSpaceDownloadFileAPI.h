//
//  NXWorkSpaceDownloadFileAPI.h
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN
#define START       @"start"
#define LENGTH      @"length"
#define FILE_PATH   @"filePath"
#define DOWNLOAD_TYPE @"downloadType"
@interface NXWorkSpaceDownloadFileRequest : NXSuperRESTAPIRequest

@end

@interface NXWorkSpaceDownloadFileResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong)NSData *resultData;
@end

NS_ASSUME_NONNULL_END
