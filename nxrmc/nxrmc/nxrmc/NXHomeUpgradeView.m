//
//  NXHomeUpgradeView.m
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXHomeUpgradeView.h"

#import "Masonry.h"
#import "UIView+UIExt.h"

@interface NXHomeUpgradeView ()

@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, weak) UILabel *messageLabel;
@property(nonatomic, weak) UIButton *upgradeButton;

@end

@implementation NXHomeUpgradeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (CGFloat)height {
    [self.titleLabel sizeToFit];
    [self.messageLabel sizeToFit];
    
    CGFloat height = self.titleLabel.bounds.size.height + self.messageLabel.bounds.size.height + kMargin * 4 + self.upgradeButton.bounds.size.height;
    return height;
}

#pragma mark
- (void)upgrade:(id)sender {
    if (self.upgradeBlock) {
        self.upgradeBlock(sender);
    }
}

#pragma mark
- (void)commonInit {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview:titleLabel];
    
    UILabel *messageLabel = [self createDetailLabel];
    [self addSubview:messageLabel];
    
    UIButton *upgradeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
    [self addSubview:upgradeButton];
    
    titleLabel.text = @"Create Protect to colloborate!";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.numberOfLines = 0;
    
    messageLabel.text = @"Centralize the files everyone needs A faster way to share files with your colledges Sharing settings to protect company data";
    
    [upgradeButton cornerRadian:4];
    upgradeButton.backgroundColor = [UIColor whiteColor];
    [upgradeButton setTitle:@"  Upgrade  " forState:UIControlStateNormal];
    [upgradeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [upgradeButton addTarget:self action:@selector(upgrade:) forControlEvents:UIControlEventTouchUpInside];
    upgradeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    self.titleLabel = titleLabel;
    self.messageLabel = messageLabel;
    self.upgradeButton = upgradeButton;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.left.equalTo(self).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin);
    }];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(kMargin);
        make.left.equalTo(self).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin);
    }];
    [upgradeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(kMargin);
        make.centerX.equalTo(self);
        make.height.equalTo(@(30));
    }];
}

- (UILabel *)createDetailLabel {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - kMargin * 2, 20)];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont systemFontOfSize:12];
    messageLabel.numberOfLines = 0;
    return messageLabel;
}

@end
