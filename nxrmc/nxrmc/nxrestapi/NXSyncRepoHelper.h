//
//  NXSyncRepoHelper.h
//  nxrmc
//
//  Created by EShi on 6/12/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSyncHelper.h"
#import "NXGetRepositoryDetailsAPI.h"


typedef void(^DownloadLocalRepoInfoComplection)(id object, NSError *error);
typedef void(^SyncRepoInfoComplection)(NSArray *addRMCReposList, NSArray *delReposList, NSArray *updateReposList, NSError *error);
@class NXLProfile;
@interface NXSyncRepoHelper : NXSyncHelper
+ (instancetype)sharedInstance;

- (void)deletePreviousFailedAddRepoRESTRequest:(NSString *) cachedFileFlag;
- (void)downloadServiceRepoInfoWithComplection:(DownloadLocalRepoInfoComplection) complectionBlcok;

- (void) syncRepoInfoWithLocalRepoInfo:(NSArray *)localRepoDict userProfile:(NXLProfile *)userProfile withCompletion:(SyncRepoInfoComplection) syncCompletion;
@end
