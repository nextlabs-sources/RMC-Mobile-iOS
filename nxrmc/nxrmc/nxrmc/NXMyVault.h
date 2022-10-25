//
//  NXMyVault.h
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXMyVaultFile.h"
#import "NXMyVaultListParModel.h"
#import "NXMyVaultFileSystemTree.h"
#import "NXFileChooseFlowDataSorceDelegate.h"

typedef void(^getMyVaultFileListComplete)(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error);
typedef void(^uploadFileToMyVaultFolderComplete)(NXMyVaultFile *file, NXFileBase *parentFolder, NSError *error);
typedef void(^downloadFileFromMyVaultComplete)(NXMyVaultFile *file,NSError *error);
typedef void(^deleteFileFromMyVaultComplete)(NXMyVaultFile *file, NSError *error);
typedef void(^metadataFromMyVaultComplete)(NXMyVaultFile *file, NSError *error);
@class NXMyVault;
@class NXLProfile;
@protocol NXMyVaultDelegate <NSObject>
-(void) updateFileList:(NSDictionary *)filesDict errors:(NSDictionary *) errorDict fromRepoFileSysManager:(NXMyVault *) myVault;
@end

@interface NXMyVault : NSObject<NXFileChooseFlowDataSorceDelegate>
@property(nonatomic, strong) NXMyVaultFileSystemTree *myVaultFileSystem;

- (instancetype)initWithUserProfile:(NXLProfile *)userProfile;

- (NSString *)getMyVaultFileListUnderRootFolderWithFilterModel:(NXMyVaultListParModel *)filterModel shouldReadCache:(BOOL)readCache withCompletion:(getMyVaultFileListComplete)complete;
- (NSString *)getMyVaultFileListUnderParentFolder:(NXFileBase *)parentFolder filterModel:(NXMyVaultListParModel *) filterModel shouldReadCache:(BOOL)readCache withCompletion:(getMyVaultFileListComplete)complete;
- (NSArray *)getAllMyVaultFileInCoreData;
- (NSString *)uploadFile:(NSString *)fileName fileData:(NSData *)fileData fileItem:(NXFileBase *)fileItem toMyVaultFolder:(NXFileBase *)folder progress:(NSProgress *)uploadProgress withCompletion:(uploadFileToMyVaultFolderComplete)complete;
- (NSString *)deleteFile:(NXMyVaultFile *)file withCompletion:(deleteFileFromMyVaultComplete)complete;
- (NSString *)metaData:(NXMyVaultFile *)file withCompletetino:(metadataFromMyVaultComplete)complete;
//- (void)startSyncMyVaultFileListUnderFolder:(NXFileBase *)parentFolder withDelegate:id<NXMyVaultDelegate> delegate;
- (void)stopSyncMyVaultFileList;
- (void)markFavoriteFile:(NXFileBase *)fileItem;
- (void)unmarkFavoriteFile:(NXFileBase *)fileItem;

- (void)cancelOperation:(NSString *)operationIdentify;

- (void)updateMyVaultFileSharedStatus:(NXMyVaultFile *)myVaultFile;
- (void)updateMyVaultFileRevokedStatus:(NXMyVaultFile *)myVaultFile;
- (NXFileBase *)getmyVaultRootFolder;

@end
