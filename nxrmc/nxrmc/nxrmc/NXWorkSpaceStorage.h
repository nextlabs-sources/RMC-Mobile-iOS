//
//  NXWorkSpaceStorage.h
//  nxrmc
//
//  Created by Eren on 2019/9/26.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXWorkSpaceItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface NXWorkSpaceStorage : NSObject
#pragma mark -----> Insert file for workspace
+ (void)insertWorkSpaceFiles:(NSArray *)files toFolder:(NXFolder *)parentFolder;
+ (void)insertWorkSpaceFileItem:(NXFileBase *)fileItem toParentFolder:(NXFolder *)parentFolder;

#pragma mark ---->Parent folder
+(NXFileBase *)parentFolderForFileItem:(NXFileBase *)fileItem;

#pragma mark -----> Delete file form workspace
+ (void)deleteWorkSpaceFileItem:(NXFileBase *)fileItem;

#pragma mark ----->Query project file for workspace
+ (NSMutableArray *)queryWorkSpaceFilesUnderFolder:(NXFolder *)parentFolder;
+ (NXWorkSpaceFile *)queryWorkSpaceFileByFileKey:(NSString *)duid;
#pragma mark ----->update projectFileItem in coredata
+(void)updateWorkSpaceFileItem:(NXFileBase *)fileItem;
@end

NS_ASSUME_NONNULL_END
