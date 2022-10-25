//
//  NXProjectRemoveMemberOperation.h
//  nxrmc
//
//  Created by xx-huang on 06/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"

typedef void(^removeProjectMemberCompletion)(NSError *error);

@interface NXProjectRemoveMemberOperation : NXOperationBase

@property (nonatomic,strong) NXProjectModel *prjectModel;

@property (nonatomic,strong) NSString *memberId;

@property(nonatomic, copy) removeProjectMemberCompletion removeProjectMemberCompletion;

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel memberId:(NSString *)memberId;

@end
