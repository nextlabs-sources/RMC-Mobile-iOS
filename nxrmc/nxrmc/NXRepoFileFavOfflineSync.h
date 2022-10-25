//
//  NXRepoFileFavOfflineSync.h
//  nxrmc
//
//  Created by EShi on 1/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSyncHelper.h"
#import "NXLProfile.h"

#define FAV_FILES_KEY @"FAV_FILES_KEY"

@class NXRepoFileFavOfflineSync;
@class NXLProfile;
@protocol NXRepoFileFavOfflineSyncDelegate<NSObject>
- (void)offlineFavSync:(NXRepoFileFavOfflineSync *) sync favOfflineFileItemsDict:(NSDictionary *)dict;
@end

@interface NXRepoFileFavOfflineSync : NXSyncHelper
- (instancetype) initWithCurrentLocalFavOfflineFileItems:(NSDictionary *)favOfflineFilesDict userProfile:(NXLProfile *)userProfile;

- (void)unmarkFavFile:(NXFileBase *)fileBase;
- (void)markFavFile:(NXFileBase *)fileBase withParent:(NXFileBase *)parent;
- (void)startSyncFavOfflineFromRMS;
- (void)stopSyncFavOfflineFromRMS;

@property(nonatomic, weak) id<NXRepoFileFavOfflineSyncDelegate> delegate;
@property(nonatomic, assign) NSTimeInterval localFavOfflineLastOptTime;
@end
