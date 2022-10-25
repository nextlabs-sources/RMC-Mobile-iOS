//
//  NXRightsSelectReusableView.m
//  nxrmc
//
//  Created by nextlabs on 11/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRightsSelectReusableView.h"

#import "Masonry.h"

@interface NXRightsSelectReusableView ()

@property(nonatomic, weak, readonly) UILabel *titleLabel;

@end

@implementation NXRightsSelectReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - setter 

- (void)setModel:(NSString *)model {
    if ([_model isEqualToString:model]) {
        return;
    }
    _model = model;
    if(!model){
         self.titleLabel.attributedText = nil;
        return;
    }
    
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:model attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSObliquenessAttributeName:@0.1, NSFontAttributeName:[UIFont systemFontOfSize:kNormalFontSize]}];
    self.titleLabel.attributedText = attriStr;
}

#pragma mark -
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview: titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self).offset(-kMargin);
    }];
    
    _titleLabel = titleLabel;
}
@end

@interface NXRightsMoreOptionSelectReusableView ()
@property(nonatomic, strong) UIImageView  *rightImageView;
@property(nonatomic, weak, readonly) UILabel *titleLabel;
@end
@implementation NXRightsMoreOptionSelectReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    self.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapBackgroundView:)];
    [self addGestureRecognizer:tap];
    
    return self;
}

#pragma mark - setter



#pragma mark -
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"  More options";
    [self addSubview: titleLabel];
    UIImageView *rightImageView = [[UIImageView alloc] init];
    [self addSubview:rightImageView];
    _rightImageView = rightImageView;
    _titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(rightImageView.mas_left).offset(-kMargin * 5);
        make.height.equalTo(self).multipliedBy(0.85);
    }];
    
    [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-kMargin * 2);
        make.width.height.equalTo(@18);
        make.height.equalTo(@12);
    
    }];
}

- (void)setShowMoreOptions:(BOOL)moreOption{
    if (moreOption) {
        self.rightImageView.image = [UIImage imageNamed:@"up arrow - black1"];
    }else{
        self.rightImageView.image = [UIImage imageNamed:@"down arrow - black1"];
    }
}
- (void)userDidTapBackgroundView:(id)sender {
    if (self.moreOptionsButtonClicked) {
        self.moreOptionsButtonClicked();
    }
}
@end

