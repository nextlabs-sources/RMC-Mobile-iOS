//
//  NXProjectMemberDetailHeaderView.h
//  nxrmc
//
//  Created by xx-huang on 06/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "NXProjectMemberModel.h"
@class NXProjectMemberHeaderView;
@interface NXProjectMemberDetailHeaderView : UIView

@property(nonatomic, readonly, weak) UIImageView *avatarImageView;

@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *joinTimeLabel;
@property(nonatomic,strong) NXProjectMemberHeaderView *memHeaderLabel;
@property(nonatomic,strong) NSString *nameStr;
@end
