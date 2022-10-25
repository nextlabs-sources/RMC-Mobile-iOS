//
//  NXProjectListPendingOperation.h
//  nxrmc
//
//  Created by helpdesk on 21/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXPendingProjectInvitationModel.h"
@class NXProjectModel;

typedef void(^projecListPendingCompletion)(NXProjectModel *projectModel,NSMutableArray *totalPendings,NSError *error);

@interface NXProjectListPendingOperation : NXOperationBase
@property (nonatomic,strong) NXProjectModel *prjectModel;
@property (nonatomic,assign) NSUInteger page;
@property (nonatomic,assign) NSUInteger size;
@property (nonatomic,assign) ListPendingOrderByType orderBy;


@property(nonatomic, copy) projecListPendingCompletion projecListPendingCompletion;

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel page:(NSUInteger)page size:(NSUInteger)size orderBy:(ListPendingOrderByType)orderBy ;
@end
