//
//  NXRepositoryHeaderView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepositoryHeaderView.h"
#import "Masonry.h"
#import "UIView+UIExt.h"

@interface NXRepositoryHeaderView ()

@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) UIImageView *thumbImageView;
@property(nonatomic, strong) UIImageView *accessoryImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@end

@implementation NXRepositoryHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

#pragma mark
- (void)tap:(id)sender {
    if (self.clickBlock) {
        self.clickBlock(sender);
    }
}
#pragma mark
- (void)commonInit {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMargin*2, kMargin*2, kMargin*2, kMargin*2));
    }];
    
    [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(self.contentView).multipliedBy(0.6);
        make.width.equalTo(self.thumbImageView.mas_width);
        make.left.equalTo(self.contentView).offset(kMargin);
    }];
    
    [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.and.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-kMargin);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thumbImageView.mas_right).offset(kMargin);
        make.right.equalTo(self.accessoryImageView.mas_left).offset(-kMargin);
        make.centerY.equalTo(self.thumbImageView);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tap:)];
    
    [self.contentView addGestureRecognizer:tap];
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        contentView.backgroundColor = [UIColor whiteColor];
        
        _contentView = contentView;
    }
    return _contentView;
}

- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        UIImageView *thumbImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:thumbImageView];
        thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        thumbImageView.image = [UIImage imageNamed:@"add - black"];
        
        _thumbImageView = thumbImageView;
    }
    return _thumbImageView;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        UIImageView *accessoryImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:accessoryImageView];
        accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
        accessoryImageView.image = [UIImage imageNamed:@"accessoryIcon"];
        
        _accessoryImageView = accessoryImageView;
    }
    
    return _accessoryImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:titleLabel];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

@end
