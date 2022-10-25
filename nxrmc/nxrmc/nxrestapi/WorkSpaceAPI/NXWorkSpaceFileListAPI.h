//
//  NXWorkSpaceFileListAPI.h
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXWorkSpaceFileListRequest : NXSuperRESTAPIRequest
@end

@interface NXWorkSaceFileListResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSMutableArray *workSpaceFileList;
@property(nonatomic, assign) NSNumber  *totalFiles;
@property(nonatomic, assign) NSNumber *usage;
@property(nonatomic, assign) NSNumber *quota;
@end

NS_ASSUME_NONNULL_END
