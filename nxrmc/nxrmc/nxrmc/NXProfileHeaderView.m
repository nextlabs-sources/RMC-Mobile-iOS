//
//  NXProfileHeaderView.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXProfileHeaderView.h"

#import "UIView+UIExt.h"
#import "Masonry.h"

#import "NXLoginUser.h"
#import "UIImage+Cutting.h"
#import "NXProjectMemberHeaderView.h"
#import "NXLProfile.h"
@implementation NXProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
/* hide user photo
    [self.avatarImageView borderColor:[UIColor whiteColor]];
    [self.avatarImageView borderWidth:5];
    [self.avatarImageView cornerRadian:self.avatarImageView.bounds.size.width/2];
    self.avatarImageView.clipsToBounds = YES;
*/
}

- (void)updateUserInfoData:(NSString *)userAvatar name:(NSString *)userName email:(NSString *)userEmail {
/* hide user photo
    if (userAvatar) {
        UIImage *image = [UIImage imageWithBase64Str:userAvatar];
        self.avatarImageView.image = image;
    } else {
       self. avatarImageView.image = [UIImage imageNamed:@"Account"];

    }
*/
    if (userName) {
        self.nameLabel.text = userName;
        self.userPhoto.items = @[userName];
    }
    
    if (userEmail) {
        self.emailLabel.text = userEmail;
    }
}
#pragma mark

- (void)clicked:(id)sender {
    if (self.tapclickBlock) {
        self.tapclickBlock(sender);
    }
}

#pragma mark 
- (void)commonInit {
    self.backgroundColor = RMC_MAIN_COLOR;
    NXProjectMemberHeaderView *userPhotoView = [[NXProjectMemberHeaderView alloc]init];
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    UILabel *nameLabel = [[UILabel alloc] init];
    UILabel *emailLabel = [[UILabel alloc] init];
    UILabel *editlabel = [[UILabel alloc] init];
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"access-white"]];
    
    [self addSubview:userPhotoView];
    [self addSubview:avatarImageView];
    [self addSubview:nameLabel];
    [self addSubview:emailLabel];
    [self addSubview:editlabel];
    [self addSubview:accessoryView];

    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
   
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.frame = CGRectMake(50, 100, 200, 80);
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    emailLabel.textColor = [UIColor whiteColor];
    emailLabel.font = [UIFont systemFontOfSize:14];
    emailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    editlabel.textColor = [UIColor lightGrayColor];
    editlabel.text = NSLocalizedString(@"UI_COM_EDIT_ACCOUNT", NULL);
    
    accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
    [gesture addTarget:self action:@selector(clicked:)];
    [self addGestureRecognizer:gesture];
    userPhotoView.sizeWidth = 70;
    userPhotoView.items = @[[NXLoginUser sharedInstance].profile.userName];
    _userPhoto = userPhotoView;
    _nameLabel = nameLabel;
    _emailLabel = emailLabel;
    _avatarImageView = avatarImageView;
    
//    [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(kMargin * 2);
//        make.height.equalTo(@70);
//        make.width.equalTo(avatarImageView.mas_height);
//        make.centerY.equalTo(self).offset(-kMargin);
//    }];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            
            [userPhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.height.equalTo(@70);
                make.width.equalTo(@70);
                make.centerY.equalTo(self.mas_safeAreaLayoutGuideCenterY).offset(-kMargin);
            }];
            [accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin * 2);
                make.centerY.equalTo(self.mas_safeAreaLayoutGuideCenterY);
                make.width.equalTo(@20);
                make.height.equalTo(@(20));
            }];
            [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(userPhotoView).offset(5);
                make.left.equalTo(userPhotoView.mas_right).offset(kMargin * 2);
                make.right.equalTo(accessoryView.mas_left).offset(-kMargin/2);
                make.height.equalTo(@20);
            }];
            [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(userPhotoView.mas_right).offset(kMargin * 2);
                make.right.equalTo(accessoryView.mas_left).offset(-kMargin/2);
                make.top.equalTo(nameLabel.mas_bottom);
                make.height.equalTo(@20);
            }];
            
            [editlabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(emailLabel);
                make.right.equalTo(emailLabel);
                make.top.equalTo(emailLabel.mas_bottom);
            }];
        }
    }
    else
    {
        [userPhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kMargin);
            make.height.equalTo(@70);
            make.width.equalTo(@70);
            make.centerY.equalTo(self).offset(-kMargin);
        }];
        [accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-kMargin * 2);
            make.centerY.equalTo(self);
            make.width.equalTo(@20);
            make.height.equalTo(@(20));
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(userPhotoView).offset(5);
            make.left.equalTo(userPhotoView.mas_right).offset(kMargin * 2);
            make.right.equalTo(accessoryView.mas_left).offset(-kMargin/2);
            make.height.equalTo(@20);
        }];
        [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(userPhotoView.mas_right).offset(kMargin * 2);
            make.right.equalTo(accessoryView.mas_left).offset(-kMargin/2);
            make.top.equalTo(nameLabel.mas_bottom);
            make.height.equalTo(@20);
        }];
        
        [editlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(emailLabel);
            make.right.equalTo(emailLabel);
            make.top.equalTo(emailLabel.mas_bottom);
        }];
    }
}

@end
