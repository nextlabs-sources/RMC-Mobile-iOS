//
//  NXAccountEmailView.m
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAccountEmailView.h"

#import "Masonry.h"
#import "NXRMCDef.h"

@interface NXAccountEmailView()

//@property(nonatomic, weak) UILabel *connectLabel;

@end

@implementation NXAccountEmailView

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

#pragma mark
//- (void)clicked:(id)sender {
//    if (self.tapclickBlock) {
//        self.tapclickBlock(sender);
//    }
//}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    
    UILabel *emailLabel = [[UILabel alloc] init];
    [self addSubview:emailLabel];
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [changeBtn setTitle:NSLocalizedString(@"UI_PROFILE_CHANGE_NAME", NULL) forState:UIControlStateNormal];
    changeBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [changeBtn setTitleColor:[UIColor colorWithRed:40/256.0 green:125/256.0 blue:240/256.0 alpha:1] forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeNameClick:) forControlEvents:UIControlEventTouchUpInside];
    changeBtn.accessibilityValue = @"PROFILE_PAGE_ACCOUNT_CHANGE_BTN";
    [self addSubview:changeBtn];
//    UILabel *connectLabel = [[UILabel alloc] init];
//    [self addSubview:connectLabel];
    imageView.image = [UIImage imageNamed:@"accessoryIcon"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    emailLabel.font = [UIFont systemFontOfSize:14];
    emailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    emailLabel.accessibilityValue = @"PROFILE_PAGE_ACCOUNT_EMAIL_LABEL";
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
//    [gesture addTarget:self action:@selector(clicked:)];
//    [connectLabel addGestureRecognizer:gesture];
//    connectLabel.userInteractionEnabled = YES;
//    connectLabel.font = [UIFont systemFontOfSize:14];
//    connectLabel.textColor = [UIColor redColor];
//    connectLabel.text = NSLocalizedString(@"Disconnect", NULL);
//    connectLabel.textAlignment = NSTextAlignmentRight;
    
    _emaiLabel = emailLabel;
    _imageView = imageView;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(10);
                make.height.equalTo(self.mas_safeAreaLayoutGuideHeight);
                make.width.equalTo(self.mas_safeAreaLayoutGuideWidth).multipliedBy(0.65);
            }];
            
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.mas_safeAreaLayoutGuideCenterY);
                make.height.equalTo(self.mas_safeAreaLayoutGuideHeight).multipliedBy(0.6);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
                make.width.equalTo(@(kMargin*2));
            }];
            [changeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(emailLabel);
                make.right.equalTo(imageView.mas_left);
                make.width.equalTo(@60);
                make.height.equalTo(emailLabel);
            }];
        }
    }
    else
    {
        [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.height.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.65);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.6);
            make.right.equalTo(self).offset(-kMargin);
            make.width.equalTo(@(kMargin*2));
        }];
        [changeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(emailLabel);
            make.right.equalTo(imageView.mas_left);
            make.width.equalTo(@60);
            make.height.equalTo(emailLabel);
        }];
    }
//    [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.bottom.equalTo(imageView.mas_centerY).offset(-kMargin/8);
//        make.right.equalTo(self).offset(-kMargin);
//        make.left.equalTo(imageView.mas_right).offset(kMargin/4);
//        make.centerY.equalTo(imageView);
//    }];
    
//    [connectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(imageView.mas_centerY).offset(kMargin/8);
//        make.right.equalTo(self).offset(-kMargin);
//        make.left.equalTo(imageView.mas_right).offset(kMargin/4);
//    }];
    

#if 0
    emailLabel.text = @"alexmartin@gmail.com";
#endif
    
#if 0
    emailLabel.backgroundColor = [UIColor blueColor];
//    connectLabel.backgroundColor = [UIColor redColor];
    imageView.backgroundColor = [UIColor orangeColor];
#endif
    
}
- (void)changeNameClick:(id) sender {
    if (self.tapclickBlock) {
        self.tapclickBlock(sender);
    }
}
@end
