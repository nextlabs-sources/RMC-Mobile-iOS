//
//  NXWorkSpaceItem.h
//  nxrmc
//
//  Created by Eren on 2019/8/29.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXFile.h"
#import "NXFolder.h"
#import "NSObject+NXLRuntimeExt.h"
#import "NXLRights.h"

NS_ASSUME_NONNULL_BEGIN
@interface NXWorkSpaceFileItemUploader : NSObject <NSCopying>
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *email;
@end

@interface NXWorkSpaceFileItemLastModifiedUser : NSObject <NSCopying>
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *email;
@end

@interface NXWorkSpaceFile : NXFile <NSCopying>
@property (nonatomic, strong) NSString *duid;
@property (nonatomic, strong) NXWorkSpaceFileItemUploader *fileUploader;
@property (nonatomic, strong) NXWorkSpaceFileItemLastModifiedUser *fileModifiedUser;
@property (nonatomic, strong) NXLRights *rights;
@property (nonatomic, strong) NSDictionary *tags;
@end 

@interface NXWorkSpaceFolder : NXFolder
@property (nonatomic, strong) NXWorkSpaceFileItemUploader *fileUploader;
@property (nonatomic, strong) NXWorkSpaceFileItemLastModifiedUser *fileModifiedUser;
@end

NS_ASSUME_NONNULL_END
