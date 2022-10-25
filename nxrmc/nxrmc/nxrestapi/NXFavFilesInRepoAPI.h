//
//  NXMarkFavFailesInRepoAPI.h
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

typedef NS_ENUM(NSInteger, NXFavFilesInRepoRequestType)
{
    NXFavFilesInRepoRequestTypeMark = 1,
    NXFavFilesInRepoRequestTypeUnmark,
};
#define NXFavFilesInRepoModel_ParentKey @"NXFavFilesInRepoModel_ParentKey"
#define NXFavFilesInRepoModel_FilesKey @"NXFavFilesInRepoModel_FilesKey"
#define NXFavFilesInRepoModel_RepoIdKey @"NXFavFilesInRepoModel_RepoIdKey"

@interface NXFavFilesInRepoRequest : NXSuperRESTAPIRequest
- (instancetype) initWithType:(NXFavFilesInRepoRequestType) type;
@end

@interface NXFavFilesInRepoResponse : NXSuperRESTAPIResponse
@end
