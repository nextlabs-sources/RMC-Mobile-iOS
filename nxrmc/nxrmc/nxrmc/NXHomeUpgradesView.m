//
//  NXHomeUpgradesView.m
//  nxrmc
//
//  Created by helpdesk on 10/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXHomeUpgradesView.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
static const CGFloat KTopSpace = 8.0f;
@interface NXHomeUpgradesView ()
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel1;
@property(nonatomic, strong) UILabel *messageLabel2;
@property(nonatomic, strong) UILabel *messageLabel3;
@property(nonatomic, strong) UIButton *upgradeButton;
@end
@implementation NXHomeUpgradesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commoninit];
    }
    return self;
}
- (void)commoninit {
    self.titleLabel = [[UILabel alloc]init];
    [self addSubview:self.titleLabel];
    self.titleLabel.text = @"Collaborate in project securely!";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(KTopSpace*3);
        make.centerX.equalTo(self);
        make.height.equalTo(@30);
        make.width.equalTo(self).multipliedBy(0.9);
    }];
    
        UILabel *messageLabel = [[UILabel alloc]init];
        messageLabel.text = @"Try SkyDRM Project.";
    messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:messageLabel];
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(KTopSpace);
        make.centerX.equalTo(self);
        make.width.equalTo(self.titleLabel).multipliedBy(0.6);
        make.height.equalTo(@40);
  
    }];
    UIButton *upgradeButton = [[UIButton alloc] init];
    self.upgradeButton = upgradeButton;
    [self addSubview:upgradeButton];
    
    [upgradeButton cornerRadian:4];
    upgradeButton.backgroundColor = [UIColor whiteColor];
    [upgradeButton setTitle:@"  Activate  " forState:UIControlStateNormal];
    [upgradeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [upgradeButton addTarget:self action:@selector(Activate:) forControlEvents:UIControlEventTouchUpInside];
    upgradeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [upgradeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(KTopSpace*3);
        make.width.equalTo(self).multipliedBy(0.3);
        make.centerX.equalTo(self);
        make.height.equalTo(@(44));
        make.bottom.equalTo(self).offset(-KTopSpace*3);
    }];

     }
#pragma mark
- (void)Activate:(id)sender {
    if (self.upgradeBlock) {
        self.upgradeBlock(sender);
    }
}

@end
