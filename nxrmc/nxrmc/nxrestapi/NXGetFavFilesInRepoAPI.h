//
//  NXGetFavFilesInRepoAPI.h
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

#define NXGetFavFilesInRepoModel_RepoIdKey @"NXGetFavFilesInRepoModel_RepoIdKey"
#define NXGetFavFilesInRepoModel_ServiceTimeKey @"NXGetFavFilesInRepoModel_ServiceTimeKey"
#define NXGetFavFilesInRepoModel_UserProfileKey @"NXGetFavFilesInRepoModel_UserProfileKey"

@interface NXGetFavFilesInRepoRequest: NXSuperRESTAPIRequest

@end

@interface NXGetFavFilesInRepoResponse : NXSuperRESTAPIResponse
@property(nonatomic, readonly, strong) NSMutableArray *markedFavFiles;
@property(nonatomic, readonly, strong) NSMutableArray *unmarkedFavFiles;
@property(nonatomic, readonly, assign) BOOL isFullCopy;
@end

