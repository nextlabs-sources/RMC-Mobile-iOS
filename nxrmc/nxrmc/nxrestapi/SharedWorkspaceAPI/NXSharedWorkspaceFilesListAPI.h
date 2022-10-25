//
//  NXSharedWorkspaceFilesListAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/15.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"



@interface NXSharedWorkspaceFilesListAPIRequest : NXSuperRESTAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo;

@property(nonatomic, strong) NXRepositoryModel *repo;
@end

@interface NXSharedWorkspaceFilesListAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong)NSArray *filesArray;
@end
