//
//  NXProjectInvitation.h
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NXProjectModel;
typedef NS_ENUM(NSInteger, ListPendingOrderByType)
{
    ListPendingOrderByTypeDisplayNameAscending = 0,
    ListPendingOrderByTypeCreateTimeAscending = 1,
    ListPendingOrderByTypeDisplayNameDescending = 2,
    ListPendingOrderByTypeCreateTimeDescending = 3,
};

@interface NXPendingProjectInvitationModel : NSObject<NSCopying,NSCoding>
@property(nonatomic, strong) NSNumber *projectId;
@property(nonatomic, strong) NSNumber *invitationId;
@property(nonatomic, strong) NSString *inviteeEmail;
@property(nonatomic, strong) NSString *inviterDisplayName;
@property(nonatomic, strong) NSString *inviterEmail;
@property(nonatomic, assign) NSTimeInterval inviteTime;
@property(nonatomic, assign) NSTimeInterval createdTime;
@property(nonatomic, strong) NXProjectModel *projectInfo;
@property(nonatomic, strong) NSString *code;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSString *invitationMsg;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *name;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
