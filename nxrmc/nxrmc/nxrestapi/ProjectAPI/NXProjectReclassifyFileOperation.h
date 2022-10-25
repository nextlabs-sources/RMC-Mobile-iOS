//
//  NXProjectReclassifyFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/5/8.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"


@class NXProjectUploadFileParameterModel;
@class NXProjectFile;
typedef void(^projectReclassifyFileCompletion)(NXProjectFile *fileItem,NXProjectUploadFileParameterModel*parmeterMD,NSError *error);
@interface NXProjectReclassifyFileOperation : NXOperationBase
-(instancetype)initWithParmeterModel:(NXProjectUploadFileParameterModel*)parmeterModel;
@property (nonatomic, copy) projectReclassifyFileCompletion projectReclassifyFileCompletion;
@end

