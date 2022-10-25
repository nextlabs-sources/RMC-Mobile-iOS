//
//  NXProjectInvitationOperation.h
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"

typedef void(^inviteProjectMembersCompletion)(NSDictionary *resultDic,NSError *error);

@interface NXProjectInvitationOperation : NXOperationBase

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel emailsArray:(NSArray *)emailsArray invitationMsg:(NSString *)invitationMsg;

@property (nonatomic, strong) NXProjectModel *prjectModel;

@property (nonatomic, strong) NSArray *emailsArray;

@property (nonatomic, strong) NSString *invitationMsg;
@property(nonatomic, copy) inviteProjectMembersCompletion inviteProjectMemberCompletion;

@end
