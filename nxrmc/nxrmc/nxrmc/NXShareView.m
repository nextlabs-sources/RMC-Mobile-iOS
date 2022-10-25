///
//  NXShareView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXShareView.h"

#import "UIView+UIExt.h"
#import "UIImage+ColorToImage.h"
#import "Masonry.h"

@interface NXShareView (){
    __weak UIImageView *_imageView;
    __weak UILabel *_titleLabel;
    __weak UIImageView *_accessoryImageView;
}

@property(nonatomic, strong) UIImage *image;
@end

@implementation NXShareView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addShadow:UIViewShadowPositionTop | UIViewShadowPositionLeft | UIViewShadowPositionBottom | UIViewShadowPositionRight color:[UIColor lightGrayColor] width:1 Opacity:0.5];
}

#pragma mark
- (void)setEnable:(BOOL)enable {
    _enable = enable;
    if (enable) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        _imageView.image = [self.image imageByApplyingAlpha:1];
        _accessoryImageView.image = [UIImage imageNamed:@"accessoryIcon"];
    } else {
        self.userInteractionEnabled = NO;
        _titleLabel.textColor = [UIColor lightGrayColor];
        _imageView.image = [self.image imageByApplyingAlpha:0.2];
        _accessoryImageView.image = nil;
    }
}

#pragma mark
- (void)click:(id)sender {
    if (self.buttonClickBlock && _enable) {
        self.buttonClickBlock(sender);
    }
}

#pragma mark
- (void)commonInit {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.width.equalTo(self.imageView.mas_height);
        make.top.equalTo(self).offset(kMargin * 2);
        make.bottom.equalTo(self).offset(-kMargin * 2);
        make.left.equalTo(self).offset(kMargin);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.top.equalTo(self).offset(kMargin/2);
        make.bottom.equalTo(self).offset(-kMargin/2);
        make.left.equalTo(self.imageView.mas_right).offset(kMargin);
    }];
    
    [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.top.equalTo(self).offset(kMargin);
        make.bottom.equalTo(self).offset(-kMargin);
        make.right.equalTo(self).offset(-kMargin);
        make.width.equalTo(self.accessoryImageView.mas_height);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(click:)];
}

- (UIImage *)image {
    if (!_image) {
        _image = self.imageView.image;
    }
    return _image;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share - black"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = NSLocalizedString(@"UI_SHARE_THE_PROTECTED_FILE", NULL);
        titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
        accessoryView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:accessoryView];
        _accessoryImageView = accessoryView;
    }
    return _accessoryImageView;
}
@end
