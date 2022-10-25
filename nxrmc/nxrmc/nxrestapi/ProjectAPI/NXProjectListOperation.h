//
//  NXProjectListOperation.h
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
@class NXProjectsListParameterModel;

typedef void(^getProjectListCompletion)(NSArray *projectList,NSString*kindType,NSError *error);

@interface NXProjectListOperation : NXOperationBase
-(instancetype) initWithProjectListParameterModel:(NXProjectsListParameterModel *)parameterModel;
@property(nonatomic, copy) getProjectListCompletion getProjectListCompletion;

@end
