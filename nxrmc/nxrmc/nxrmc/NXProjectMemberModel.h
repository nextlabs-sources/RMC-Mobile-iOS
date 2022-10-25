//
//  NXProjectMemberModel.h
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ListMemberOrderByType)
{
    ListMemberOrderByTypeDisplayNameAscending = 0,
    ListMemberOrderByTypeCreateTimeAscending = 1,
    ListMemberOrderByTypeDisplayNameDescending = 2,
    ListMemberOrderByTypeCreateTimeDescending = 3,
};


@interface NXProjectMemberModel : NSObject<NSCoding>
@property(nonatomic, strong) NSNumber *projectId;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSNumber *userId;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *inviterDisplayName;
@property(nonatomic, strong) NSString *inviterEmail;
@property(nonatomic, assign) NSTimeInterval joinTime;
@property(nonatomic, strong) NSString *avatarUrl;
@property(nonatomic, strong) NSString *avatarBase64;
@property(nonatomic, assign) BOOL isProjectOwner;
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end
