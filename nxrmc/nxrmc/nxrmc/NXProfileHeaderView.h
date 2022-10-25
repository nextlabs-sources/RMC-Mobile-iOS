//
//  NXProfileHeaderView.h
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapClickBlock)(id sender);
@class NXProjectMemberHeaderView;
@interface NXProfileHeaderView : UIView

@property(nonatomic, readonly, weak) UIImageView *avatarImageView;
@property(nonatomic, readonly, weak) UILabel *nameLabel;
@property(nonatomic, readonly, weak) UILabel *emailLabel;
@property(nonatomic, readonly, weak) NXProjectMemberHeaderView *userPhoto;
@property(nonatomic, strong) TapClickBlock tapclickBlock;

- (void)updateUserInfoData:(NSString *)userAvatar name:(NSString *)userName email:(NSString *)userEmail;

@end
