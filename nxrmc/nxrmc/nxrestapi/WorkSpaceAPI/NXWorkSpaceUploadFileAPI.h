//
//  NXWorkSpaceUploadFileAPI.h
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXWorkSpaceItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface NXWorkSpaceUploadFileModel : NSObject
@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NXLRights *digitalRight;
@property(nonatomic, strong) NSDictionary *tags;
@property(nonatomic, strong) NXFolder *parentFolder;
@property(nonatomic, assign) BOOL isOverWrite;
@end

@interface NXWorkSpaceUploadFileRequest : NXSuperRESTAPIRequest

@end

@interface NXWorkSpaceUploadFileResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NXWorkSpaceFile *uploadedFile;
@end

NS_ASSUME_NONNULL_END
