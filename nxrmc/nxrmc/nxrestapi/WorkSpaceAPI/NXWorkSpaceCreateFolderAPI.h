//
//  NXWorkSpaceCreateFolderAPI.h
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXWorkSpaceItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface NXWorkSpaceCreateFolderModel : NSObject
@property(nonatomic, strong) NXFolder *parentFolder;
@property(nonatomic, strong) NSString *folderName;
@property(nonatomic, assign) BOOL autoRename;
@end

@interface NXWorkSpaceCreateFolderRequest : NXSuperRESTAPIRequest

@end


@interface NXWorkSpaceCreateFolderResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NXFolder *createdFolder;
@end

NS_ASSUME_NONNULL_END
