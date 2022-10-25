//
//  NXSharedWorkspaceGetFileMetaDataAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/15.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXSharedWorkspaceGetFileMetaDataAPIRequest : NXSuperRESTAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo;

@property(nonatomic, strong) NXRepositoryModel *repo;
@end
@interface NXSharedWorkspaceGetFileMetaDataAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong)NXFileBase *fileItem;
@end
NS_ASSUME_NONNULL_END
