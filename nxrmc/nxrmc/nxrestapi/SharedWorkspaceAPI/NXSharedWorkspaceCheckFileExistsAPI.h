//
//  NXSharedWorkspaceCheckFileExistsAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define FILE_PATH   @"filePath"
#define REPO_ID       @"repoID"

@interface NXSharedWorkspaceCheckFileExistsAPIRequest : NXSuperRESTAPIRequest
@property (nonatomic,copy) NSString *path;

@end

@interface NXSharedWorkspaceCheckFileExistsAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,assign) BOOL isFileExist;
@end
