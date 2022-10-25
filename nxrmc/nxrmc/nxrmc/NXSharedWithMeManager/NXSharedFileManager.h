//
//  NXSharedFileManager.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 31/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NXSharedWithMeFileListParameterModel;
@class NXSharedWithMeFile;
@class NXShareWithMeReshareResponseModel;
@class NXSharedWithMeReshareProjectFileResponseModel;
@class NXSharedWithMeReshareProjectFileRequestModel;
@class NXLProfile;
@class NXMyVaultListParModel;
@class NXMyVaultFile;
@class NXProjectFile;
@class NXSharedWithProjectFile;

typedef void(^getSharedWithMeFileListCompletion)(NXSharedWithMeFileListParameterModel *parameterModel,NSArray *fileListArray,NSError *error);
typedef void(^reShareSharedWithMeFileCompletion)(NXSharedWithMeFile *originalFile,NXSharedWithMeFile *freshFile,NXShareWithMeReshareResponseModel *responseModel,NSError *error);

typedef void(^getSharedByMeFileListCompletion)(NXMyVaultListParModel *parameterModel,NSArray *fileListArray,NSError *error);
typedef void(^reShareProjetFileCompletion)(NXSharedWithProjectFile *originalFile,NXSharedWithProjectFile *freshFile,NXSharedWithMeReshareProjectFileResponseModel *responseModel,NSError *error);


@interface NXSharedFileManager : NSObject

- (instancetype)initWithUserProfile:(NXLProfile *)userProfile;
// sharedWithMe
- (NSString *)getSharedWithMeFileListWithParameterModel:(NXSharedWithMeFileListParameterModel *)parameterModel shouldReadCache:(BOOL)isReadCache wtihCompletion:(getSharedWithMeFileListCompletion)sharedWithMeFileListCompletion;
- (NSArray *)getSharedWithMeFileListFromStorage;
- (NSString *)reshareSharedWithMeFile:(NXSharedWithMeFile *)sharedWithMeFile withReceivers:(NSArray *)receiversArray withCompletion:(reShareSharedWithMeFileCompletion)reshareFileCompletion;
- (NSString *)reshareProjectFile:(NXSharedWithProjectFile *)sharedWithProjectFile withReceivers:(NSArray *)receiversArray withCompletion:(reShareProjetFileCompletion)reshareProjectFileCompletion;
// sharedByMe
- (NSString *)getSharedByMeFileListWithParameterModel:(NXMyVaultListParModel *)parameterModel shouldReadCache:(BOOL)isReadCache withCompletion:(getSharedByMeFileListCompletion)sharedByMeFileListCompletion;

- (void)updateCacheListArrayWhenDeleteItem:(NXMyVaultFile *)item;

- (void)cancelOperation:(NSString *)operationIdentify;

@end
