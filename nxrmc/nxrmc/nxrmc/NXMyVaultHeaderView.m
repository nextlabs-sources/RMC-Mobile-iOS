//
//  NXMyVaultHeaderView.m
//  nxrmc
//
//  Created by nextlabs on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultHeaderView.h"

#import "UIView+UIExt.h"
#import "Masonry.h"

@interface NXMyVaultHeaderView ()

@property(nonatomic, weak) UILabel *titleLabel;

@end

@implementation NXMyVaultHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)setModel:(NSString *)model {
    if ([self.model isEqualToString:model]) {
        return;
    }
    _model = model;
    
    self.titleLabel.text = model;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addShadow:UIViewShadowPositionBottom color:[UIColor blackColor] width:0.2f Opacity:0.3f];
}

#pragma mark
- (void)commonInit {
    [self.layer setBackgroundColor:[UIColor groupTableViewBackgroundColor].CGColor];
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    [shadowView addShadow:UIViewShadowPositionBottom color:[UIColor blackColor] width:0.4f Opacity:0.3f];
    [self addSubview:shadowView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 50, 25)];
    [self addSubview:label];
    
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _titleLabel = label;
    
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self);
        make.height.equalTo(@0.5);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(0.5);
        make.width.equalTo(self).multipliedBy(0.6);
        make.left.equalTo(self).offset(2 * kMargin);
        make.right.equalTo(self).offset(-kMargin);
    }];
}

@end
