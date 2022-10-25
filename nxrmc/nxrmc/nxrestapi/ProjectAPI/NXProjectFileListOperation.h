//
//  NXProjectFileListOperation.h
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

@class NXProjectFile;
@class NXProjectFileListParameterModel;
typedef void(^getProjectFileListOptCompletion)(NSArray *fileItems,NXProjectFileListParameterModel*parmeterMD,NSError *error);

@interface NXProjectFileListOperation : NXOperationBase
-(instancetype) initWithParmeterModel:(NXProjectFileListParameterModel*)parmeterModel;
@property(nonatomic, copy) getProjectFileListOptCompletion ProjectFileListCompletion;


@end
