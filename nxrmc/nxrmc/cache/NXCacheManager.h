//
//  NXCacheManager.h
//  nxrmc
//
//  Created by Kevin on 15/5/14.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXRMCDef.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXFolder.h"
#import "NXSuperRESTAPI.h"
#import "NXRepositoryModel.h"
@class NXLProfile;
@interface NXCacheManager : NSObject


+ (NSURL *) cacheRESTReq:(NXSuperRESTAPIRequest *) restAPI cacheURL:(NSURL *) cacheURL;
+ (void) deleteCachedRESTReq:(NXSuperRESTAPIRequest *)restAPI cacheURL:(NSURL *)cacheURL;
+ (void) cacheRESTReq:(NXSuperRESTAPIRequest *)restAPI directlyCacheURL:(NSURL *)cacheURL;
+ (void) deleteCachedRESTByURL:(NSURL *)cacheURL;

+ (NSURL *) getRESTCacheURL;
+ (NSURL *) getSharingRESTCacheURL;
+ (NSURL *) getLogCacheURL;
+ (NSURL *) getFavOfflineRESTCacheURL;
+ (NSURL *) getProjectMembersRESTCacheURL;
+ (NSURL *) getProjectPendingMembersRESTCacheURL;

+ (NSURL *) getHeartbeatCacheURL;

+ (void)cacheDirectory: (ServiceType)type serviceAccountId:(NSString*)sid directory: (NXFileBase*)directory;

+ (void)cacheFileSystemTree:(NXFileBase *) rootFolder forRepository:(NXRepositoryModel *)repo;
+ (void)deleteCachedRepositoryFileSystemTree:(NXRepositoryModel *)repo;
+ (NXFolder *)getRepositoryFileSystemRootFolder:(NXRepositoryModel *)repo;

+ (NSURL*) getLocalUrlForServiceCache:(NXRepositoryModel *)repoModel;
+ (NSURL*) getSafeLocalUrlForServiceCache:(NXRepositoryModel *)repoModel;
+ (NSURL*) getCacheUrlForOpenedInFile:(NSURL *)openedInFileUrl;

// myvault
+ (NSURL *) getMyVaultRootFolderCachePathWithUserProfile:(NXLProfile *)userProfile;
+ (NSURL*) getMyVaultDownloadFilePath:(NSString *)fileName userProfile:(NXLProfile *)userProfile;
+ (NSURL *)cacheMyVaultRootFolder:(NXFileBase *)rootFolder userProfile:(NXLProfile *)userProfile;
+ (NXFolder *)getCachedMyVaultRootFolderWithUserProfile:(NXLProfile *)userProfile;
+ (NSURL *)cacheMyVaultDownloadFile:(NSString *)fileName fileData:(NSData *)fileData userProfile:(NXLProfile *)userProfile;

+ (void) cacheFile:(NXFileBase *)file localPath:(NSString *)localPath;

// my project
+ (NSURL *)getProjectCachedFilePathWithFileName:(NSString *)fileName;
@end
