//
//  NXFileSysTree.h
//  nxrmc
//
//  Created by EShi on 12/23/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXFile.h"
#import "NXFolder.h"
#import "NXSharePointFile.h"
#import "NXSharePointFolder.h"
#import "NXRepositoryModel.h"

// Not thread safe
@interface NXRepoFileSysTree : NSObject
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, readonly, strong) NXFileBase *rootFolder;

- (instancetype)initWithRepoModel:(NXRepositoryModel *)repo;
- (void)addFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder;  // NOTE: only support one leavel noodes
- (void)deleteFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder;
- (NSArray *)getFileItemsCopyUnderFolder:(NXFileBase *)parentFolder;
- (NXFileBase *)getRootFolderCopy;
- (void)updateFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder;
- (void)deleteFileItem:(NXFileBase *)fileItem;
- (void)addFileItem:(NXFileBase *)fileItem underFolder:(NXFileBase *)parentFolder;

- (void)markFavFileItem:(NXFileBase *)fileItem;
- (void)unmarkFavFileItem:(NXFileBase *)fileItem;
- (BOOL)markOfflineFileItem:(NXFileBase *)fileItem;
- (BOOL)unmarkOfflineFileItem:(NXFileBase *)fileItem;
- (void)updateFavFileItemList:(NSMutableSet *)favFileItems;
- (void)updateOfflineFileItemList:(NSMutableSet *)offlineItems;
- (NSArray *)allFavoriteFileItems;
- (NSArray *)allOfflineFileItems;
- (NSUInteger )allRepoFileItems;
- (NSUInteger )allMyDriveFileItems;

- (NXFileBase *)getParentOfFileItem:(NXFileBase *)fileItem;
- (void)cacheFileSysTree;
- (void)destroy;
@end
