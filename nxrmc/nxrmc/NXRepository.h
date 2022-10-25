//
//  NXRepository.h
//  nxrmc
//
//  Created by EShi on 12/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXBoundService+CoreDataClass.h"
#import "NXFileBase.h"
#import "NXFile.h"
#import "NXFolder.h"
#import "NXRepositoryModel.h"

typedef NS_ENUM(NSInteger, NXRepositoryUploadType)
{
    NXRepositoryUploadTypeNormal = 0,    //normal upload, upload a file. if file(same name)exist in server, the uploaded file will be renamed, both files exist,
    NXRepositoryUploadTypeOverWrite,     //overwrite upload, uoload a file. if file(same name)exist in server, the exist file will be replaced by new uploaded file, only uploaded file existed.
    //TBD add other situation eg, when after protect normal file, delete the normal file, only nxl file will existed in server.
};

typedef void(^repoGetFilesUnderFolderCompletion)(NSArray* fileItems, NXFileBase *parentFolder, NSError *error);
typedef void(^repoDeleteFileUnderFolderCompletion)(NXFileBase *fileItem, NSError *error);
typedef void(^repoCreateFolderUnderFolderCompletion)(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error);
typedef void(^repoUploadFilesCompletion)(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error);
typedef void(^repoDownloadFileCompletion)(NXFileBase *file, NSError *error);
typedef void(^repoGetInfoCompletion)(NXRepositoryModel *repo, NSString *userName, NSString *userEmail, NSNumber *totalQuota, NSNumber *usedQuota, NSError *error);
typedef void(^repoGetFileMetaDataCompletion)(NXFileBase *metaData, NSError *error);

@interface NXRepository : NSObject
@property (nonatomic, strong) NSString *service_account;
@property (nonatomic, strong) NSString *service_account_id;
@property (nonatomic, strong) NSString *service_account_token;
@property (nonatomic, strong) NSString *service_alias;
@property (nonatomic, strong) NSString *service_id;
@property (nonatomic, strong) NSNumber *service_selected;
@property (nonatomic, strong) NSNumber *service_type;
@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSNumber *service_isAuthed;
@property(nonatomic, strong) NSString *service_providerClass;
@property(nonatomic, strong) NXBoundService *boundService;

// repo file system operation
- (void) updateRepoInfo:(NXRepositoryModel *)repoModel;
- (instancetype) initWithBoundService:(NXBoundService *)boundService userProfile:(NXLProfile *)profile;
- (instancetype) initWithRepoModel:(NXRepositoryModel *)repoModel userProfile:(NXLProfile *)profile;
- (void)addFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder;  // NOTE: only support one leavel noodes
- (NSArray *)updateFileItems:(NSArray *)fileItems underFolder:(NXFileBase *)parentFolder;

- (NSOperation *)getFileItemsCopyUnderFolder:(NXFileBase *)parentFolder onlyReadCache:(BOOL)onlyReadCache shouldReadCache:(BOOL) shouldReadCache withCompletion:(repoGetFilesUnderFolderCompletion) completion;
- (NSOperation *)deleteFile:(NXFileBase *)fileItem withCompletion:(repoDeleteFileUnderFolderCompletion) completion;
- (NSOperation *)createFolder:(NSString *)folderName underParentFolder:(NXFileBase *)parentFolder withCompletion:(repoCreateFolderUnderFolderCompletion) completion;
- (NSOperation *)uploadFile:(NSString*)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXRepositoryUploadType) type overWriteFile:(NXFileBase *)overWriteFile progress:(NSProgress *)uploadProgress completion:(repoUploadFilesCompletion)comp;
- (NSOperation *)downloadFile:(NXFileBase *)file progress:(NSProgress *)downloadProgress withCompletion:(repoDownloadFileCompletion)complete;
- (NSOperation *)getRepositoryInfowithCompletion:(repoGetInfoCompletion)complete;
- (NSOperation *)queryFileMetaData:(NXFileBase *)file withCompletion:(repoGetFileMetaDataCompletion)complete;

// fav/offline
- (void)markFavFileItem:(NXFileBase *)fileItem;
- (void)unmarkFavFileItem:(NXFileBase *)fileItem;
- (void)markOfflineFileItem:(NXFileBase *)fileItem;
- (void)unmarkOfflineFileItem:(NXFileBase *)fileItem;
- (void)updateFavFileItemList:(NSMutableSet *)favFileItems;
- (void)updateOfflineFileItemList:(NSMutableSet *)offlineItems;
- (NSArray *)allFavoriteFileItems;
- (NSArray *)allOfflineFileItems;

// for file system tree
- (NXFileBase *)getParentOfFileItem:(NXFileBase *)fileItem;
- (NSArray *)getChildOfFileItem:(NXFileBase *)fileItem;
- (NXFileBase *)getRepoRootFolder;

// return outside model
- (NXRepositoryModel *)getModel;

// dealloc
- (void)destory;  // called when user delete repository
@end
