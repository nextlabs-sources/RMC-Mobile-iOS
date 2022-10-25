//
//  NXProjectUploadFileOperation.h
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
@class NXProjectUploadFileParameterModel;
@class NXProjectFile;
typedef void(^projectUploadFileCompletion)(NXProjectFile *fileItem,NXProjectUploadFileParameterModel*parmeterMD,NSError *error);
@interface NXProjectUploadFileOperation : NXOperationBase
-(instancetype) initWithParmeterModel:(NXProjectUploadFileParameterModel*)parmeterModel;
@property(nonatomic, copy) projectUploadFileCompletion projectUploadFileCompletion;
@property(nonatomic, strong) NSProgress *uploadProgress;
@end
