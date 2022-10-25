//
//  NXFileSysTree.m
//  nxrmc
//
//  Created by EShi on 12/23/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRepoFileSysTree.h"
#import "NXCacheManager.h"
#import "NXCommonUtils.h"
#import "NXRepoFileStorage.h"


@interface NXRepoFileSysTree()
@property(nonatomic, readwrite, strong) NXFolder *rootFolder;
@property(nonatomic, strong) NSMapTable *fileItemMapTableCache;  // key fullServicePath  value fileBase
@property(atomic, strong) NSMutableSet *favFileItemSet;  // stand for local fav files
@property(atomic, strong) NSMutableSet *offlineItemSet;  // stand for local offline files
@property(nonatomic, strong) dispatch_queue_t cacheFileSysTreeSerialQueue;
@end

@implementation NXRepoFileSysTree
-(instancetype)initWithRepoModel:(NXRepositoryModel *)repo
{
    self = [super init];
    if (self) {
        _repo = [repo copy];
        if (_rootFolder == nil) {
            _rootFolder = [NXCommonUtils createRootFolderByRepoType:_repo.service_type.integerValue];
            _rootFolder.repoId = repo.service_id;
            _rootFolder.serviceAlias = [repo.service_alias copy];
        }
        _fileItemMapTableCache = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
        [_fileItemMapTableCache setObject:_rootFolder forKey:_rootFolder.fullServicePath];
        
        NSMutableArray *favFilesFullServicePaths = [[NSMutableArray alloc] init];
        NSMutableArray *offlineFilesFullServicePaths = [[NSMutableArray alloc] init];
        
        for (NXFileBase *fileBase in [_rootFolder.favoriteFileList allNodes]) {
            [favFilesFullServicePaths addObject:fileBase.fullServicePath];
        }
        
        for (NXFileBase *fileBase in [_rootFolder.offlineFileList allNodes]) {
            [offlineFilesFullServicePaths addObject:fileBase.fullServicePath];
        }
        
        _favFileItemSet = [[NSMutableSet alloc] initWithArray:favFilesFullServicePaths];
        _offlineItemSet = [[NSMutableSet alloc] initWithArray:offlineFilesFullServicePaths];
        
        _cacheFileSysTreeSerialQueue = dispatch_queue_create("NXRepoFileSysTree.cacheFileSysTreeSerailQueue", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}

- (NXFileBase *)rootFolder
{
    @synchronized (self) {
        return _rootFolder;
    }
}

- (NSMapTable *)fileItemMapTableCache
{
    @synchronized (self) {
        return _fileItemMapTableCache;
    }
}

- (void)setRepo:(NXRepositoryModel *)repo
{
    @synchronized (self) {
        _repo = repo;
    }
}

- (void)destroy
{
    [self destoryFileSysTree];
    self.rootFolder = nil;
}


-(void)addFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder
{
    [NXRepoFileStorage addFileItems:fileItems underFolder:parentFolder];
}
-(void)deleteFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder
{
    assert(0);
}

-(void)deleteFileItem:(NXFileBase *)fileItem
{
    [NXRepoFileStorage deleteFileItem:fileItem];
}

-(void)addFileItem:(NXFileBase *)fileItem underFolder:(NXFileBase *)parentFolder
{
    [NXRepoFileStorage addFileItem:fileItem underFolder:parentFolder];
}

-(void)updateFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder
{
    [NXRepoFileStorage updateFileItems:fileItems underFolder:parentFolder];
}

- (void)markFavFileItem:(NXFileBase *)fileItem
{
    [NXRepoFileStorage markFavFileItem:fileItem];
}

- (void)unmarkFavFileItem:(NXFileBase *)fileItem
{
    [NXRepoFileStorage unmarkFavFileItem:fileItem];
}

- (BOOL)markOfflineFileItem:(NXFileBase *)fileItem
{
    NXFileBase *reallyFileItem = [self insideFileItem:fileItem];
    if (reallyFileItem) { // in case the mark offline info is from RMS, so the local cache tree do not have this node!
        reallyFileItem.isOffline = YES;
        [self.rootFolder.offlineFileList addNode:reallyFileItem];
        [self.offlineItemSet addObject:reallyFileItem.fullServicePath];
        [self cacheFileSysTree];
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)unmarkOfflineFileItem:(NXFileBase *)fileItem
{
    NXFileBase *reallyFileItem = [self insideFileItem:fileItem];
    if (reallyFileItem) {
        reallyFileItem.isOffline = NO;
        [self.rootFolder.offlineFileList removeNode:reallyFileItem];
        [self.offlineItemSet removeObject:reallyFileItem.fullServicePath];
        [self cacheFileSysTree];
        return YES;
    }else{
        return NO;
    }
}

- (void)updateFavFileItemList:(NSMutableSet *)favFileItems
{
//    NSMutableSet *tempSet = [[NSMutableSet alloc] initWithSet:favFileItems];
//    // step1. update local fav list
//    __weak typeof(self) weakSelf = self;
//    [self.favFileItemSet enumerateObjectsUsingBlock:^(NSString*  _Nonnull fileItemFullServicePath, BOOL * _Nonnull stop) {
//        if(![favFileItems containsObject:fileItemFullServicePath]){
//            NXFileBase *fileItem = [[NXFileBase alloc] init];
//            fileItem.fullServicePath = fileItemFullServicePath;
//            fileItem.repoId = [self.repo.service_id copy];
//            fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
//            fileItem.serviceAlias = [self.repo.service_alias copy];
//            fileItem.serviceAccountId = [self.repo.service_account_id copy];
//            fileItem.serviceType = [self.repo.service_type copy];
//            [weakSelf unmarkFavFileItem:fileItem];
//        }else{
//            [favFileItems removeObject:fileItemFullServicePath];
//        }
//    }];
//    
//    [favFileItems enumerateObjectsUsingBlock:^(NSString *  _Nonnull fileItemFullServicePath, BOOL * _Nonnull stop) {
//        NXFileBase *fileItem = [[NXFileBase alloc] init];
//        fileItem.repoId = [self.repo.service_id copy];
//        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
//        fileItem.serviceAlias = [self.repo.service_alias copy];
//        fileItem.serviceAccountId = [self.repo.service_account_id copy];
//        fileItem.serviceType = [self.repo.service_type copy];
//        
//        fileItem.fullServicePath = fileItemFullServicePath;
//        BOOL ret = [weakSelf markFavFileItem:fileItem];
//        if (!ret) {
//            [tempSet removeObject:fileItemFullServicePath];
//        }
//    }];
//    // step2. update file system tree fav item set
//    self.favFileItemSet = tempSet;
    
}

- (void)updateOfflineFileItemList:(NSMutableSet *)offlineItems
{
    NSMutableSet *tempSet = [[NSMutableSet alloc] initWithSet:offlineItems];
    // step1. update local offline list
    __weak typeof(self) weakSelf = self;
    [self.offlineItemSet enumerateObjectsUsingBlock:^(NSString*  _Nonnull fileItemFullServicePath, BOOL * _Nonnull stop) {
        if(![offlineItems containsObject:fileItemFullServicePath]){
            NXFileBase *fileItem = [[NXFileBase alloc] init];
            fileItem.fullServicePath = fileItemFullServicePath;
            fileItem.repoId = [self.repo.service_id copy];
            fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
            fileItem.serviceAlias = [self.repo.service_alias copy];
            fileItem.serviceAccountId = [self.repo.service_account_id copy];
            fileItem.serviceType = [self.repo.service_type copy];
            [weakSelf unmarkOfflineFileItem:fileItem];
        }else{
            [offlineItems removeObject:fileItemFullServicePath];
        }
    }];
    
    [offlineItems enumerateObjectsUsingBlock:^(NSString *  _Nonnull fileItemFullServicePath, BOOL * _Nonnull stop) {
        NXFileBase *fileItem = [[NXFileBase alloc] init];
        fileItem.fullServicePath = fileItemFullServicePath;
        fileItem.repoId = [self.repo.service_id copy];
        fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
        fileItem.serviceAlias = [self.repo.service_alias copy];
        fileItem.serviceAccountId = [self.repo.service_account_id copy];
        fileItem.serviceType = [self.repo.service_type copy];
        BOOL ret = [weakSelf markOfflineFileItem:fileItem];
        if (!ret) {
            [tempSet removeObject:fileItemFullServicePath];
        }
    }];
    // step2. update file system tree offline item set
    self.offlineItemSet = tempSet;
}

- (NSArray *)allFavoriteFileItems
{
    NSMutableArray *favListArray = [[NSMutableArray alloc] init];
    NSInteger favListCount = [self.rootFolder.favoriteFileList count];
    for (NSInteger index = 0; index < favListCount; ++index) {
        NXFileBase *copyItem = [[self.rootFolder.favoriteFileList objectAtIndex:index] copy];
        copyItem.repoId = self.repo.service_id;
        [favListArray addObject:copyItem];
    }
    return favListArray;
}

- (NSArray *)allOfflineFileItems
{
    NSMutableArray *offlineListArray = [[NSMutableArray alloc] init];
    NSInteger offlineListCount = [self.rootFolder.offlineFileList count];
    for (NSInteger index = 0; index < offlineListCount; ++index) {
        NXFileBase *copyItem = [[self.rootFolder.offlineFileList objectAtIndex:index] copy];
        copyItem.repoId = self.repo.service_id;
        [offlineListArray addObject:copyItem];
    }
    return offlineListArray;
}
- (void)cacheFileSysTree
{
    WeakObj(self);
    dispatch_async(self.cacheFileSysTreeSerialQueue, ^{
        StrongObj(self);
        [NXCacheManager cacheFileSystemTree:self.rootFolder forRepository:self.repo];
    });
}

- (void)destoryFileSysTree
{
    // when repository is deleted, the relationship will make sure delete corresponding file system tree, so no need do anything
}

- (NXFileBase *)getParentOfFileItem:(NXFileBase *)fileItem
{
    return [NXRepoFileStorage getParentOfFileItem:fileItem];
}

-(NSArray *)getFileItemsCopyUnderFolder:(NXFileBase *)parentFolder
{
    return [NXRepoFileStorage getFileItemsCopyUnderFolder:parentFolder];
}

- (NSUInteger )allRepoFileItems
{
    return [NXRepoFileStorage allRepoFilesCount];
}

- (NSUInteger )allMyDriveFileItems{
     return [NXRepoFileStorage allMyDriveFilesCount];
}

- (NXFileBase *)getRootFolderCopy
{
    NXFolder *rootFolder = [self.rootFolder copy];
    rootFolder.repoId = self.repo.service_id;
    return rootFolder;
}


#pragma mark - Private method
-(NXFileBase *)insideFileItem:(NXFileBase *)fileItem;
{
    NSString *fullServicePath = fileItem.fullServicePath;
    NXFileBase *retFileItem = [self.fileItemMapTableCache objectForKey:fullServicePath];
    if (retFileItem) {
        return retFileItem;
    }
    // change out side folder to inside folder
    return [self findFileBase:fullServicePath inFolder:(NXFolder *)self.rootFolder];
    
}

-(NXFileBase *)insideFileItemByFullServicePath:(NSString *)fullServicePath;
{
    NXFileBase *retFileItem = [self.fileItemMapTableCache objectForKey:fullServicePath];
    if (retFileItem) {
        return retFileItem;
    }
    // change out side folder to inside folder
    return [self findFileBase:fullServicePath inFolder:(NXFolder *)self.rootFolder];
    
}

-(NXFileBase *)findFileBase:(NSString *)fullServicePath inFolder:(NXFolder *)parentFolder
{
    if([parentFolder getChildren] == nil  && [parentFolder getChildren].count == 0)
    {
        return nil;
    }
    
    for (NXFileBase *fileItem in [parentFolder getChildren]) {
        if ([fileItem.fullServicePath isEqualToString:fullServicePath]) {
            [_fileItemMapTableCache setObject:fileItem forKey:fullServicePath];
            return fileItem;
        }
        
        if ([fileItem isKindOfClass:[NXFolder class]] || [fileItem isKindOfClass:[NXSharePointFolder class]] || fileItem.isRoot) {
            NXFileBase * retFileBase = [self findFileBase:fullServicePath inFolder:(NXFolder *)fileItem];
            if (retFileBase) {
                // cache result
                [_fileItemMapTableCache setObject:retFileBase forKey:fullServicePath];
                return retFileBase;
            }
        }
    }
    return nil;
}


@end
