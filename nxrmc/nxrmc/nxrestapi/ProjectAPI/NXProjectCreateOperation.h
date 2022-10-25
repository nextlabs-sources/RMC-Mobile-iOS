//
//  NXProjectCreateOperation.h
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXProjectCreateAPI.h"
@class NXProjectModel;
typedef void(^createProjectCompletion)(NXProjectModel *projectItem,NXProjectCreateParmetersMD *parmeterMD,NSError *error);
@interface NXProjectCreateOperation : NXOperationBase
-(instancetype) initWithParmeterModel:(NXProjectCreateParmetersMD *)parmeterModel;
@property(nonatomic, copy) createProjectCompletion createProjectCompletion;

@end
