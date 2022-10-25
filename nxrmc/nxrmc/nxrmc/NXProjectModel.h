//
//  NXProjectModel.h
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXProjectMemberModel.h"
#import "NXProject.h"


@class  NXProject;

@interface NXProjectOwnerItem : NSObject<NSCopying,NSCoding>

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSNumber * trialEndTime;
@end
@class NXLFileValidateDateModel;
@interface NXProjectModel : NSObject<NSCopying,NSCoding>
@property (nonatomic, strong) NSNumber * projectId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * membershipId;
@property (nonatomic, strong) NSString * tokenGroupName;
@property (nonatomic, strong) NSString *parentTenantName;
@property (nonatomic, strong) NSString *parentTenantId;
@property (nonatomic, strong) NSString * projectDescription;
@property (nonatomic, strong) NSString * invitationMsg;
@property (nonatomic, assign) NSTimeInterval createdTime;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, assign) BOOL  isOwnedByMe;
@property (nonatomic, assign) long totalMembers;
@property (nonatomic, assign) long totalFiles;
@property (nonatomic, strong) NXProjectOwnerItem *projectOwner;
@property (nonatomic, strong) NSString *accountType;
@property (nonatomic, assign) NSTimeInterval trialEndTime;
//@property (nonatomic, strong) NSMutableArray *pendingMembers;
@property (nonatomic, strong) NSMutableArray *homeShowMembers;
@property (nonatomic, assign) NSTimeInterval lastActionTime;
@property (nonatomic, strong) NSString *watermark;
@property (nonatomic, assign) NSTimeInterval configurationModified;
@property (nonatomic, strong) NXLFileValidateDateModel *validateModel;
-(instancetype)initWithDictionary:(NSDictionary*)dic;
-(instancetype)initWithProject:(NXProject *)project;

@end
