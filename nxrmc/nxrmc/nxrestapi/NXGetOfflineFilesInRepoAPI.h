//
//  NXGetOfflineFilesInRepoAPI.h
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"


#define NXGetOfflineFilesInRepoModel_RepoIdKey @"NXGetOfflineFilesInRepoModel_RepoIdKey"
#define NXGetOfflineFilesInRepoModel_ServiceTimeKey @"NXGetOfflineFilesInRepoModel_ServiceTimeKey"
#define NXGetOfflineFilesInRepoModel_UserProfileKey @"NXGetOfflineFilesInRepoModel_UserProfileKey"

@interface NXGetOfflineFilesInRepoRequest: NXSuperRESTAPIRequest

@end

@interface NXGetOfflineFilesInRepoResponse : NXSuperRESTAPIResponse
@property(nonatomic, readonly, strong) NSMutableArray *markedOfflineFiles;
@property(nonatomic, readonly, strong) NSMutableArray *unmarkedOfflineFiles;
@property(nonatomic, readonly, assign) BOOL isFullCopy;
@end
