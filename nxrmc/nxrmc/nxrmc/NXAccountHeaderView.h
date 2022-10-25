//
//  NXAccountHeaderView.h
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapClickBlock)(id sender);
@class NXProjectMemberHeaderView;
@interface NXAccountHeaderView : UIView

@property(nonatomic, readonly, weak) UIImageView *avatarImageView;

@property(nonatomic, strong) TapClickBlock tapclickBlock;

@property(nonatomic,strong) NSString *nameStr;
@end
