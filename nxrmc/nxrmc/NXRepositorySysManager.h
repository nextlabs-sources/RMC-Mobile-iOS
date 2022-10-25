//
//  NXRepositorySysManager.h
//  nxrmc
//
//  Created by EShi on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NXRepository.h"
#import "NXRMCDef.h"
#import "NXFile.h"
#import "NXFolder.h"
#import "NXFileChooseFlowDataSorceDelegate.h"

// typedef for repository operation

typedef void(^authRepoCompletion)(NXRepositoryModel *repoModel, NSError *error);
typedef void(^updateRepoCompletion)(NXRepositoryModel *repoModel, NSError *error);
typedef void(^deleteRepoCompletion)(NXRepositoryModel *repoModel, NSError *error);
typedef void(^getRepoInfoCompletion)(NXRepositoryModel *repoModel, NSString *userName, NSString *userEmail, NSNumber *totalQuota, NSNumber *usedQuota, NSError *error);
typedef void(^syncRepositoryCompletion)(NSArray *repoArray, NSTimeInterval syncTime, NSError *error);
@class NXLProfile;
@class NXRepositorySysManager;
// typdef ,delegeate for file operation
@protocol NXRepoSystemFileInfoDelegate <NSObject>

- (void)updateFileListFromParentFolder:(NXFileBase *)parentFolder resultFileList:(NSArray *)resultFileList error:(NSError *) error;
- (void)didGetFileListUnderParentFolder:(NXFileBase *)parentFolder fileList:(NSArray *)fileList error:(NSError *)error;
@end


typedef NS_ENUM(NSInteger, NXRepositorySysManagerBoundRepoInputAliasOption)
{
    NXRepositorySysManagerBoundRepoInputAliasCancel = 1,
    NXRepositorySysManagerBoundRepoInputAliasProcess,
};

@class NXRepositorySysManager;
@protocol NXRepositorySysManagerBoundRepoDelegate <NSObject>

- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr boundRepo:(NXRepositoryModel *)repo inputRepositoryAliasHandler:(void(^)(NXRepositorySysManagerBoundRepoInputAliasOption processOpt, NSString *inputAlias)) processHandler;
- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr didSuccessfullyBoundRepo:(NXRepositoryModel *)repo;
- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr didFailedBoundRepo:(NXRepositoryModel *)repo withError:(NSError *)error;
- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr didCancelBoundRepo:(NXRepositoryModel *)repo;

@end

typedef NS_ENUM(NSInteger, NXRepositorySysManagerUploadType)
{
    NXRepositorySysManagerUploadTypeNormal = 0,    //normal upload, upload a file. if file(same name)exist in server, the uploaded file will be renamed, both files exist,
    NXRepositorySysManagerUploadTypeOverWrite,     //overwrite upload, uoload a file. if file(same name)exist in server, the exist file will be replaced by new uploaded file, only uploaded file existed.
    //TBD add other situation eg, when after protect normal file, delete the normal file, only nxl file will existed in server.
};
typedef void(^getFileListUnderParentFolderCompletion)(NSArray *fileList, NXFileBase *parentFolder, NSError *error);
typedef void(^deleteFileCompletion)(NXFileBase *fileItem, NSError *error);
typedef void(^createFolderCompletion)(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error);
typedef void(^uploadFilesCompletion)(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error);
typedef void(^downloadCompletion)(NXFileBase *fileItem, NSError *error);
typedef void(^queryFileMetaDataCompletion)(NXFileBase *fileMetaData, NSError *error);

@interface NXRepositorySysManager : NSObject<NXFileChooseFlowDataSorceDelegate>
@property(nonatomic, assign, readonly) NSTimeInterval lastUpdateRepoListTime;
#pragma mark - Control method
- (void)bootupWithUserProfile:(NXLProfile *)profile;
- (void)shutdown;

#pragma mark - repository operation
- (void)authRepositoyInViewController:(UIViewController *)vc forRepo:(NXRepositoryModel *)repo completion:(authRepoCompletion)comp;
- (void)boundRepositoryInViewController:(UIViewController *)vc repoType:(ServiceType) repoType withDelegate:(id<NXRepositorySysManagerBoundRepoDelegate>) boundRepoDelegate;
- (void)syncRepositoryWithCompletion:(syncRepositoryCompletion)comp;
- (void)updateRepository:(NXRepositoryModel *)repoModel completion:(updateRepoCompletion)comp;
- (void)updateRepositoryArrayToSelectState:(NSArray *)repoModelArray;
- (void)updateRepositoryArrayToDeSelectState:(NSArray *)repoModelArray;
- (void)deleteRepository:(NXRepositoryModel *)repoModel completion:(deleteRepoCompletion)comp;
- (NSString *)getRepositoryInfo:(NXRepositoryModel *)repoModel completion:(getRepoInfoCompletion)comp;
- (NSArray *)allReposiories;
- (NSArray *)allAuthReposiories;
- (NSArray *)allApplicationRepositories;
- (NSArray *)allAuthReposioriesExceptMyDrive;
- (NSArray *)allAuthReposioriesExceptApplicationRepos;
- (NSArray *)allAuthApplicationRepos;
- (NSArray *)allSupportedServiceTypes;
- (NXRepositoryModel *)getNextLabsRepository;

#pragma mark - file item operation
- (NXRepositoryModel *)getRepositoryModelByFileItem:(NXFileBase *)fileItem;
- (NXRepositoryModel *)getRepositoryModelByRepoId:(NSString *)repoId;
- (NXFolder *)rootFolderForRepo:(NXRepositoryModel *)repoModel;
- (void)syncFilesInContentFolder:(NXFileBase *)contentFolder delegate:(id<NXRepoSystemFileInfoDelegate>)delegate;
- (void)stopSyncFilesInContentFolder:(NXFileBase *)contentFolder;

- (void)markFavFileItem:(NXFileBase *)fileItem;
- (void)unmarkFavFileItem:(NXFileBase *)fileItem;
- (void)markOfflineFileItem:(NXFileBase *)fileItem;
- (void)unmarkOfflineFileItem:(NXFileBase *)fileItem;
- (NSArray *)allOfflineFileItems;
- (NSArray *)allFavoriteFileItems;
- (NSArray *)offlineFilesForRepository:(NXRepositoryModel *)repo;
- (NSArray *)favFilesForRepository:(NXRepositoryModel *)repo;
- (NSUInteger)allRepoFiles;
- (NSUInteger)allMyDriveFilesCount;

// 这里有complete block和返回值同时存在 会有问题吗？？调用顺序？
- (void)fileListForParentFolder:(NXFileBase *)parentFolder readCache:(BOOL)readCache delegate:(id<NXRepoSystemFileInfoDelegate>)delegate;
- (void)fileListForRepository:(NXRepositoryModel *)repo readCache:(BOOL)readCache delegate:(id<NXRepoSystemFileInfoDelegate>)delegate;

- (NSString *)deleteFileItem:(NXFileBase *)fileItem completion:(deleteFileCompletion)comp;
- (NSString *)createFolder:(NSString *)folderName inParent:(NXFileBase *)parentFolder completion:(createFolderCompletion)comp;
- (NSString *)uploadFile:(NSString*)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXRepositorySysManagerUploadType) type overWriteFile:(NXFileBase *)overWriteFile progress:(NSProgress *)uploadProgress completion:(uploadFilesCompletion)comp;
- (NSString *)queryFileMetaData:(NXFileBase *)fileItem completion:(queryFileMetaDataCompletion)comp;
- (void)cancelOperation:(NSString *)operationIdentify;

// query file interface
-(NXFileBase *)parentForFileItem:(NXFileBase *)fileItem;
-(NSArray *)childForFileItem:(NXFileBase *)fileItem;


@end
