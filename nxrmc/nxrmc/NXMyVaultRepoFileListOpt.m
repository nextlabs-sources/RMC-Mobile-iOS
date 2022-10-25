//
//  NXMyVaultRepoFileListOpt.m
//  nxrmc
//
//  Created by Eren on 2020/5/14.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXMyVaultRepoFileListOpt.h"
#import "NXLoginUser.h"
#import "NXMyVaultListParModel.h"
@interface NXMyVaultRepoFileListOpt()
@property (nonatomic, strong) NXFileBase *parentFolder;
@property (nonatomic, assign) BOOL shouldReadCache;
@property (nonatomic, strong) NSArray *filesArray;
@property(nonatomic, strong) NSString *optStr;
@end

@implementation NXMyVaultRepoFileListOpt

- (instancetype) initWithParentFolder:(NXFileBase *) parentFolder shouldeReadCache:(BOOL) shouldReadCache {
    if (self = [super init]) {
        _parentFolder = parentFolder;
        _shouldReadCache = shouldReadCache;
        _parentFolder = parentFolder;
    }
    return self;
}

- (void)executeTask:(NSError **)error {
    NXMyVaultListParModel *filterModel = [[NXMyVaultListParModel alloc] init];
    if (self.parentFolder.isRoot) {
        self.optStr = [[NXLoginUser sharedInstance].myVault getMyVaultFileListUnderRootFolderWithFilterModel:filterModel shouldReadCache:self.shouldReadCache withCompletion:^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
            self.filesArray = fileList;
            self.getFileCompletion(fileList, parentFolder, error);
            [self finish:error];
        }];
    }else {
        self.optStr = [[NXLoginUser sharedInstance].myVault getMyVaultFileListUnderParentFolder:self.parentFolder filterModel:filterModel shouldReadCache:self.shouldReadCache withCompletion:^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
            self.filesArray = fileList;
            
            [self finish:error];
        }];
    }
}


- (void)workFinished:(NSError *)error {
    self.getFileCompletion(self.filesArray, self.parentFolder, error);
}


- (void)cancelWork:(NSError *)cancelError {
    [[NXLoginUser sharedInstance].myVault cancelOperation:self.optStr];
}
@end
