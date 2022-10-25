//
//  NXCopyNxlFileTransformModel.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/4/9.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, NXFileSourceType) {
    NXFileSourceTypeEnterWorkspace = 1,
    NXFileSourceTypeSharedWorkspace,
    NXFileSourceTypeProject,
    NXFileSourceTypeMyvault,
    NXFileSourceTypePersonalRepository,
    NXFileSourceTypeSharedWithMe
};
typedef NS_ENUM(NSInteger, NXFileDestSpaceType) {
    NXFileDestSpaceTypeEnterWorkspace = 1,
    NXFileDestSpaceTypeSharedWorkspace,
    NXFileDestSpaceTypeProject,
    NXFileDestSpaceTypeMyvault,
    NXFileDestSpaceTypePersonalRepository
};
@interface NXCopyNxlFileTransformModel : NSObject
@property(nonatomic,strong,nonnull)NSString *fileName;
@property(nonatomic,strong,nonnull)NSString *filePath;
@property(nonatomic,strong,nonnull)NSString *fileLocalPath;
@property(nonatomic,strong,nonnull)NSString *sourceSpaceType;
@property(nonatomic,strong,nonnull)NSString *destSpaceType;
@property(nonatomic,strong,nonnull)NSString *destSpacePath;
@property(nonatomic,strong)NSString *filePathId;
@property(nonatomic,strong)NSString *scrSpaceId;
@property(nonatomic, strong)NSString *destSpaceId;
@property(nonatomic,strong)NSString *transactionCode;
@property(nonatomic,strong)NSString *transactionId;
@property(nonatomic, assign)NXFileSourceType fileSourceType;
@property(nonatomic, assign)NXFileDestSpaceType fileDestSpaceType;
@property(nonatomic, assign)BOOL overwrite;
@end

NS_ASSUME_NONNULL_END
