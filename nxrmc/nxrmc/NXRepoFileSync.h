//
//  NXRepoFileSync.h
//  nxrmc
//
//  Created by EShi on 12/21/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXGetRepoFileInFolderOperation.h"

@class NXRepoFileSync;
@protocol NXRepoFileSyncDelegate <NSObject>
- (void)updateFiles:(NSMutableDictionary *)repoFolderDict errors:(NSDictionary *) error fromRepoFileSync:(NXRepoFileSync *)repoSync; // repoFolderDict should be key:repo value:NSDictionary in
// format key:parentFolder value:fileItems
- (void)getFiles:(NSMutableDictionary *)repoFolderDict errors:(NSDictionary *) error fromRepoFileSync:(NXRepoFileSync *)repoSync;
@end

@interface NXRepoFileSync : NSObject
@property(nonatomic, readonly, assign) BOOL exited;
@property(nonatomic, weak) id<NXRepoFileSyncDelegate> delegate;
- (void)startSyncFromRepoFolders:(NSDictionary *)repoFolderDict isOnceOperation:(BOOL)isOnce;  // the repoFolderDict should be key: (NXRepoModel)repoItem, value: (NXFolder *)folder to sync
- (void)stopSync;
- (NSArray *)syncFolders;
@end
