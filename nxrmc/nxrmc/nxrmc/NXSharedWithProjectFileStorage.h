//
//  NXSharedWithProjectStorage.h
//  nxrmc
//
//  Created by 时滕 on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSharedWithProjectFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXSharedWithProjectFileStorage : NSObject
+ (void)insertSharedFiles:(NSArray<NXSharedWithProjectFile *> *)fileList intoProject:(NXProjectModel *)project;
+ (NSArray<NXSharedWithProjectFile *> *)querySharedFileListFromProject:(NXProjectModel *)project;
+ (NXSharedWithProjectFile *)querySharedFileProjectFileByFileKey:(NSString *)fileKey;
+ (void)deleteSharedWithProjectFile:(NXSharedWithProjectFile *)fileItem;
+ (void)updateSharedWithProjectFile:(NXSharedWithProjectFile *)file;
@end

NS_ASSUME_NONNULL_END
