//
//  NXSharedWorkspaceGetNXLFileHeaderAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define FILE_PATH   @"filePath"
#define REPO_ID       @"repoID"

@interface NXSharedWorkspaceGetNXLFileHeaderAPIRequest : NXSuperRESTAPIRequest

@end

@interface NXSharedWorkspaceGetNXLFileHeaderAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSData *fileData;
@end
