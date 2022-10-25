//
//  NXMyVaultFileSystemTree.m
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultFileSystemTree.h"
#import "NXCacheManager.h"
#import "NXMyVaultFileStorage.h"
#import "NXLProfile.h"
@interface NXMyVaultFileSystemTree()
@property(nonatomic, strong) NXFileBase *rootFolder;
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, strong) NSMapTable *fileItemMapTableCache; // key fullServicePath  value fileBase

@end

@implementation NXMyVaultFileSystemTree
- (instancetype) initWithUserProfile:(NXLProfile *)userProfile
{
    self = [super init];
    if (self) {
        _rootFolder = [NXCacheManager getCachedMyVaultRootFolderWithUserProfile:userProfile];
        if (!_rootFolder) {
            _rootFolder = [[NXFolder alloc] init];
            _rootFolder.isRoot = YES;
            _rootFolder.fullPath = @"/";
            _rootFolder.fullServicePath = @"/";
        }
        
        _userProfile = userProfile;
        
        _fileItemMapTableCache = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
        [_fileItemMapTableCache setObject:_rootFolder forKey:@"/"];
    }
    return self;
}


-(NSArray *)getFileItemsCopyUnderFolder:(NXMyVaultFile *)parentFolder
{
    return [NXMyVaultFileStorage getAllMyVaultFiles];
}

-(NSArray *)getFileItemsCopyUnderFolder:(NXMyVaultFile *)parentFolder filterModel:(NXMyVaultListParModel *)filterModel
{
    return [NXMyVaultFileStorage getAllMyVaultFilesWithFilterModel:filterModel];
}

-(void)updateFileItems:(NSArray *)fileItems underFolder:(NXMyVaultFile *)parentFolder
{
    [NXMyVaultFileStorage updateMyVaultFileItemsInStorage:fileItems];
}

-(void)updateMyVaultFileItemMetadataInStorage:(NXMyVaultFile *)myVaultFile
{
    [NXMyVaultFileStorage updateMyVaultFileItemMetadataInStorage:myVaultFile];
}

-(void)addFileItems:(NSArray *)fileItems underFolder:(NXMyVaultFile *)parentFolder
{
    [NXMyVaultFileStorage insertMyVaultFileItems:fileItems];
}
-(void)deleteFileItems:(NSArray *)fileItems underFolder:(NXMyVaultFile *)parentFolder
{
    [NXMyVaultFileStorage deleteMyVaultFileItemsInStorage:fileItems];
}

-(void)deleteFileItem:(NXMyVaultFile *)fileItem
{
    [NXMyVaultFileStorage deleteMyVaultFileItemInStorage:fileItem];
}

-(void)addFileItem:(NXMyVaultFile *)fileItem underFolder:(NXMyVaultFile *)parentFolder
{
    [NXMyVaultFileStorage insertNewMyVaultFileItem:fileItem];
}

@end
