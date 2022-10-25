//
//  NXMySpaceHomeInfoView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXMySpaceHomeInfoView.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXLoginUser.h"
#import "UIImage+Cutting.h"
#import "NXProjectMemberHeaderView.h"
#import "NXLProfile.h"
@interface NXMySpaceHomeInfoView ()
@property(nonatomic, strong) UIImageView *headImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) NXProjectMemberHeaderView *userPhoto;

@end
@implementation NXMySpaceHomeInfoView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = RMC_MAIN_COLOR;
        self.backgroundColor = [UIColor clearColor];
        [self commonInitUserInfo];
    }
    return self;
}
- (void)commonInitUserInfo {
//    UIView *infoBgView = [[UIView alloc]init];
//    [self addSubview:infoBgView];
    
//    UILabel *lineLabel = [[UILabel alloc]init];
//    lineLabel.backgroundColor = [UIColor whiteColor];
//    [self addSubview:lineLabel];

    UILabel *welcomeLabel = [[UILabel alloc]init];
    welcomeLabel.text = NSLocalizedString(@"UI_HOMEVC_WELCOME", NULL);
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:welcomeLabel];
    
    UILabel *userNameLabel = [[UILabel alloc]init];
    userNameLabel.textColor = [UIColor whiteColor];
    userNameLabel.font = [UIFont boldSystemFontOfSize:20];
    userNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self addSubview:userNameLabel];
    self.nameLabel = userNameLabel;
    self.nameLabel.accessibilityValue = @"HOME_PAGE_USER_NAME_LAB";
    NXProjectMemberHeaderView *headerPhoto = [[NXProjectMemberHeaderView alloc]init];
    headerPhoto.sizeWidth = 50;
    self.userPhoto = headerPhoto;
    [self addSubview:headerPhoto];
/* hide user photo
    UIImageView *headImageView = [[UIImageView alloc]init];
    [headImageView borderColor:[UIColor whiteColor]];
    [headImageView borderWidth:5];
    headImageView.clipsToBounds = YES;
    
    [headImageView cornerRadian:25];
    [self addSubview:headImageView];
    headImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGetRer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickHeadImage:)];
    [headImageView addGestureRecognizer:tapGetRer];
    
    self.headImageView = headImageView;
*/
//    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).offset(48);
//        make.left.equalTo(self).offset(30);
//        make.width.equalTo(@25);
//        make.height.equalTo(@5);
//    }];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(40);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(30);
                make.width.equalTo(@100);
                make.height.equalTo(@20);
            }];
            
            [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(welcomeLabel.mas_bottom);
                make.left.equalTo(welcomeLabel);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-80);
                make.height.equalTo(@40);
            }];
            
            [headerPhoto mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(40);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-15);
                make.width.height.equalTo(@50);
            }];
        }
    }
    else
    {
        [welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(40);
            make.left.equalTo(self).offset(30);
            make.width.equalTo(@100);
            make.height.equalTo(@20);
        }];
        [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(welcomeLabel.mas_bottom);
            make.left.equalTo(welcomeLabel);
            make.right.equalTo(self.mas_right).offset(-80);
            make.height.equalTo(@40);
        }];
        [headerPhoto mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(40);
            make.right.equalTo(self.mas_right).offset(-15);
            make.width.height.equalTo(@50);
        }];
    }
  
/* hide user photo
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
        make.right.equalTo(self.mas_right).offset(-15);
        make.width.height.equalTo(@50);
    }];
*/
    }
- (void)updateUserNameAndHeadImage {
    NSString *nameStr = [NXLoginUser sharedInstance].profile.userName;
    if(nameStr == nil){
        return;
    }
    self.nameLabel.text = [nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.userPhoto.items = @[nameStr];
/* hide user photo
    if ([NXLoginUser sharedInstance].profile.avatar) {
        self.headImageView.image = [UIImage imageWithBase64Str:[NXLoginUser sharedInstance].profile.avatar];
    }else {
        self.headImageView.image = [UIImage imageNamed:@"Account"];
    }
*/
}
- (void)clickHeadImage:(id)sender {
    if (self.goToPorFilePageBlock) {
        self.goToPorFilePageBlock(sender);
    }
}
@end
