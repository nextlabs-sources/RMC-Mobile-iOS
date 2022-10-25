//
//  NXWorkSpaceManager.h
//  nxrmc
//
//  Created by Eren on 2019/8/29.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileChooseFlowDataSorceDelegate.h"
@class NXLProfile;
@class NXWorkSpaceFolder;
@class NXWorkSpaceFile;
@class NXWorkSpaceUploadFileModel;
@class NXWorkSpaceCreateFolderModel;
@class NXWorkSpaceReclassifyFileModel;
@class NXFileBase;
typedef void(^getWorkSpaceFileListComplete)(NSArray *fileListArray,NXWorkSpaceFolder *parentFoloder,NSError *error);
typedef void(^uploadWorkSpaceFileComplete)(NXWorkSpaceFile *workSpaceFile,NXWorkSpaceUploadFileModel *uploadModel,NSError *error);
typedef void(^delegeWorkSpaceFileComplete)(NXFileBase *workSpaceItem,NSError *error);
typedef void(^createWorkSpaceFolderComplete)(NXWorkSpaceFolder *spaceFolder,NXWorkSpaceCreateFolderModel *folderModel,NSError *error);
typedef void(^getWorkSpaceFileMetadataComplete)(NXWorkSpaceFile *workSpaceFile,NSError *error);
typedef void(^reclassifyWorkSpaceFileComplete)(NXWorkSpaceFile *workSpaceFile,NXWorkSpaceReclassifyFileModel *reclassifyModel,NSError *error);
typedef void(^downloadWorkSpaceFileComplete)(NXWorkSpaceFile *workSpaceFile,NSError *error);

typedef void(^getDefalutClassificationComplete)(NSArray *classifications,NSError *error);
typedef void(^getWorkSpaceTotalFileNumberAndStorageComplete)(NSNumber *fileNumber,NSNumber *storageSize,NSError *error);
@interface NXWorkSpaceManager : NSObject<NXFileChooseFlowDataSorceDelegate>
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile;

- (NSString *)getWorkSpaceFileNumberAndStorageWithCompletion:(getWorkSpaceTotalFileNumberAndStorageComplete)complete;
- (NSString *)getWorkSpaceFileListUnderFolder:(NXWorkSpaceFolder *)parentFolder shouldReadCache:(BOOL)readCache withCompletion:(getWorkSpaceFileListComplete)complete;
- (NSArray *)getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)parentFolder;
- (NSString *)uploadWorkSpaceFile:(NXWorkSpaceUploadFileModel *)upLoadWorkSpaceFileModel WithCompletion:(uploadWorkSpaceFileComplete)complete;
- (NSString *)deleteWorkSpaceFile:(NXFileBase *)workSpaceFile withCompletion:(delegeWorkSpaceFileComplete)complete;
- (NSString *)reclassifyWorkSpaceFile:(NXWorkSpaceReclassifyFileModel *)model withCompletion:(reclassifyWorkSpaceFileComplete)complete;
- (NSString *)createWorkSpaceFolder:(NXWorkSpaceCreateFolderModel *)model withCompletion:(createWorkSpaceFolderComplete)complete;
- (NSString *)getWorkSpaceFileMetadataWithFile:(NXWorkSpaceFile *)workSpaceFile withCompletion:(getWorkSpaceFileMetadataComplete)complete;
- (NSString *)getWorkSpaceDefalutClassificationWithCompletion:(getDefalutClassificationComplete)complete;
- (void)cancelOperation:(NSString *)operationIdentify;
-(NXWorkSpaceFolder *)rootFolderForWorkSpace;
- (void)bootup;
- (void)shutDown;
@property (nonatomic, weak) id upDateFiledelegate;
@end
@protocol NXWorkSpaceFileUpdateDelegate <NSObject>
- (void)nxWorkSpaceManager:(NXWorkSpaceManager *)manager didGetWorkSpaceFiles:(NSArray *)files underFolder:(NXWorkSpaceFolder *)folder withSpaceDict:(NSDictionary *)dict withError:(NSError *)error;
@end


