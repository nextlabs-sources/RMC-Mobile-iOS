//
//  NXProjectListMembersOperation.h
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"
#import "NXProjectMemberModel.h"

@class NXProjectModel;

typedef void(^projecListMembersCompletion)(NSMutableArray *membersArray,NSInteger totalMembers,NSError *error);

@interface NXProjectListMembersOperation : NXOperationBase

@property (nonatomic,strong) NXProjectModel *prjectModel;
@property (nonatomic,assign) NSUInteger page;
@property (nonatomic,assign) NSUInteger size;
@property (nonatomic,assign) ListMemberOrderByType orderBy;

@property (nonatomic,assign) BOOL shouldReturnUserPicture;

@property(nonatomic, copy) projecListMembersCompletion projecListMembersCompletion;

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel page:(NSUInteger)page size:(NSUInteger)size orderBy:(ListMemberOrderByType)orderBy shouldReturnUserPicture:(BOOL)shouldReturnUserPicture;

@end
