//
//  NXProjectMemberSync.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXProjectModel.h"
#import "NXProjectMemberModel.h"

typedef void(^projectMemberSyncRemoveMemberCompletion)(NSError *error);

@protocol NXProjectMemberSyncDelegate <NSObject>

- (void)projectMemberSyncDidUpdateMembers:(NSArray *)members;
@end

@interface NXProjectMemberSync : NSObject
@property(nonatomic, weak) id<NXProjectMemberSyncDelegate> delegate;
- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel members:(NSArray *)members;
- (void)startSyncProjectMember;
- (void)stopSyncProjectMember;
- (void)destory;
+ (void)syncFromRMSMemebers:(NSArray *)members toProject:(NXProjectModel *)project;
- (NSArray *)currentProjectMembers;
// get member list from storage
+ (NSArray *)getMemberListFromStorageOfProject:(NXProjectModel *)projectModel;
// 1. delete
- (void)removeProjectMember:(NXProjectMemberModel *)memberModel completion:(projectMemberSyncRemoveMemberCompletion)completion;
@end
