//
//  NXGetFileMetadataAPI.h
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN
@class NXWorkSpaceFile;
@interface NXGetWorkSpaceFileMetadataRequest : NXSuperRESTAPIRequest

@end

@interface NXGetWorkSpaceFileMetadataResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong)NXWorkSpaceFile *workSpaceFile;
@end

NS_ASSUME_NONNULL_END
