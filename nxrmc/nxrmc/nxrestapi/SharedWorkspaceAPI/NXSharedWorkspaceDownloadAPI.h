//
//  NXSharedWorkspaceDownloadAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define START       @"start"
#define LENGTH      @"length"
#define FILE_PATH   @"path"
#define DOWNLOAD_TYPE @"type"
#define ISNXL @"isnxl"

@interface NXSharedWorkspaceDownloadAPIRequest : NXSuperRESTAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo;

@property(nonatomic, strong) NXRepositoryModel *repo;
@end

@interface NXSharedWorkspaceDownloadAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong)NSData *resultData;
@end
