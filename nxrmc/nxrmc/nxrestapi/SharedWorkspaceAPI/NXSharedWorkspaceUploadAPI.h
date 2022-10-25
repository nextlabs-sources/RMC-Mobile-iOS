//
//  NXSharedWorkspaceUploadAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

@interface NXSharedWorkspaceUploadFileModel : NSObject
@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NXFileBase *parentFolder;
@property(nonatomic, assign) NSInteger uploadType;
@property(nonatomic, assign) BOOL overwrite;
@end

@interface NXSharedWorkspaceUploadAPIRequest : NXSuperRESTAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo;

@property(nonatomic, strong) NXRepositoryModel *repo;
@end

@interface NXSharedWorkspaceUploadAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NXWorkSpaceFile *uploadedFile;
@end

