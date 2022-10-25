//
//  NXSharedWorkspaceFile.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/2/24.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXFile.h"
#import "NXFileBase.h"
#import "NXLRights.h"
#import "NXFolder.h"

@interface NXSharedWorkspaceFileItemUploader : NSObject <NSCopying>
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *email;
@end
@interface NXSharedWorkspaceFileItemLastModifiedUser : NSObject <NSCopying>
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *email;
@end
@interface NXSharedWorkspaceFile : NXFile<NSCopying>
@property(nonatomic, strong)NSString *fileId;
@property(nonatomic, assign)BOOL isFolder;
@property(nonatomic, assign)BOOL protectedFile;
@property(nonatomic, strong)NSString *fileType;
@property (nonatomic, strong)NXLRights *rights;
@property(nonatomic, strong)NSDictionary *tags;
@property(nonatomic,assign)BOOL encryptable;
@property(nonatomic, strong)NXSharedWorkspaceFileItemUploader *fileUploader;
@property(nonatomic, strong)NXSharedWorkspaceFileItemLastModifiedUser *fileModifiedUser;
@property(nonatomic, assign)long protectionType;
@end
@interface NXSharedWorkspaceFolder : NXFolder
@property (nonatomic, strong) NXSharedWorkspaceFileItemUploader *fileUploader;
@property (nonatomic, strong) NXSharedWorkspaceFileItemLastModifiedUser *fileModifiedUser;
@end


