//
//  NXProjectRecentFilesOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
@class NXProjectFile;
@class NXProjectFileListParameterModel;
typedef void(^getProjectRecentFilesOptCompletion)(NSArray *fileItems,NSDictionary *spaceDict,NXProjectFileListParameterModel*parmeterMD,NSError *error);
@interface NXProjectRecentFilesOperation : NXOperationBase
-(instancetype) initWithParmeterModel:(NXProjectFileListParameterModel*)parmeterModel;
@property(nonatomic, copy) getProjectRecentFilesOptCompletion ProjectFileListCompletion;

@end
