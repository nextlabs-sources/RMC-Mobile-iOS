//
//  NXMarkOfflineFilesInRepoAPI.h
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

typedef NS_ENUM(NSInteger, NXOfflineFilesInRepoRequestType)
{
    NXOfflineFilesInRepoRequestTypeeMark = 1,
    NXOfflineFilesInRepoRequestTypeUnmark,
};
#define NXOfflineFilesInRepoModel_UserProfileKey @"NXOfflineFilesInRepoModel_UserProfileKey"
#define NXOfflineFilesInRepoModel_FilesKey @"NXOfflineFilesInRepoModel_FilesKey"
#define NXOfflineFilesInRepoModel_RepoIdKey @"NXOfflineFilesInRepoModel_RepoIdKey"

@interface NXOfflineFilesInRepoRequest : NXSuperRESTAPIRequest
- (instancetype) initWithType:(NXOfflineFilesInRepoRequestType) type;
@property(nonatomic, readonly, strong) NSMutableArray *operationFileIds;
@end

@interface NXOfflineFilesInRepoResponse : NXSuperRESTAPIResponse
@end
