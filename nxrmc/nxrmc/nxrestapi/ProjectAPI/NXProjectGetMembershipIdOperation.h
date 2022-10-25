//
//  NXProjectGetMembershipIdOperation.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 19/04/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"
#import "NXProjectMemberModel.h"

typedef void(^getMembershipIDCompletion)(NXProjectModel *model,NSError *error);

@interface NXProjectGetMembershipIdOperation : NXOperationBase

@property (nonatomic,strong) NXProjectModel *projectModel;
@property(nonatomic, copy) getMembershipIDCompletion getMembershipIdCompletion;

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel;

@end

