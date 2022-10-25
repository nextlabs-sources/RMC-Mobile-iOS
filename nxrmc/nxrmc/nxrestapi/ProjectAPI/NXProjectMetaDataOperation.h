//
//  NXProjectMetaDataOperation.h
//  nxrmc
//
//  Created by helpdesk on 22/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

@class NXProjectModel;
typedef void(^getProjectMetaDataCompletion)(NXProjectModel *projectItem,NSNumber *projectId,NSError *error);
@interface NXProjectMetaDataOperation : NXOperationBase
-(instancetype) initWithProjectModelId:(NSNumber*)projectId;
@property(nonatomic, copy) getProjectMetaDataCompletion ProjectMetaDataCompletion;

@end
