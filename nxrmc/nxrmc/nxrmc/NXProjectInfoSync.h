//
//  NXProjectInfoSync.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXPendingProjectInvitationModel.h"
#import "NXProjectModel.h"
#import "NXProjectMemberModel.h"
#import "NXProjectCreateAPI.h"
#import "NXProjectUpdateAPI.h"

typedef void(^projectInfoSyncAcceptProjectInvitationCompletion)(NXProjectModel *project,NSTimeInterval serverTime,NSInteger statusCode,NSError *error);
typedef void(^projectInfoSyncDeclineProjectInvitationCompletion)(NXPendingProjectInvitationModel *projectInvitation,NSInteger statusCode, NSError *error);
typedef void(^projectInfoSyncCreateProjectCompletion)(NXProjectModel *project, NSError *error);
typedef void(^projectInfoSyncUpdateProjectCompletion)(NXProjectModel *project, NSError *error);

@protocol NXProjectInfoSyncDelegate <NSObject>
- (void)NXProjectInfoSyncDidUpdateProjectInfo:(NSArray *)projectsArray error:(NSError *)error;
@end

typedef void(^queryAllMyProjectInfoCompletion)(NSArray *projectsArray, NSError *error);
@interface NXProjectInfoSync : NSObject
@property(nonatomic, assign) NSTimeInterval timeStamp;
@property(nonatomic, weak) id<NXProjectInfoSyncDelegate>delegate;
- (void)startSyncProjectInfoWithRMS;
- (void)pauseSyncProjectInfoWithRMS;
- (void)destroy;
- (void)insertAcceptProjectModeltoStorage:(NXProjectModel *)projectModel;
- (void)getMyProjectWithCompletion:(queryAllMyProjectInfoCompletion)completion;
// sync operation
- (void)createProject:(NXProjectCreateParmetersMD *)projectMD withCompletion:(projectInfoSyncCreateProjectCompletion)completion;
- (void)updateProject:(NXProjectModel *)projectModel withParmetersMD:(NXProjectUpdateParmetersMD *)parmetersMD withCompletion:(projectInfoSyncUpdateProjectCompletion)completion;
@end
