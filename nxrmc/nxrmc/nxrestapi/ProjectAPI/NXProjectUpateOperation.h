//
//  NXProjectUpateOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 21/8/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXProjectUpdateAPI.h"
@class NXProjectModel;
typedef void(^updatedProjectCompletion)(NXProjectModel *projectItem,NXProjectUpdateParmetersMD *parmeterMD,NSError *error);
@interface NXProjectUpateOperation : NXOperationBase
-(instancetype) initWithParmeterModel:(NXProjectUpdateParmetersMD *)parmeterModel;
@property(nonatomic, copy) updatedProjectCompletion updateProjectCompletion;
@end
