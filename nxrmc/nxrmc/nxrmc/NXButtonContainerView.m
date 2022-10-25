//
//  NXButtonContainerView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXButtonContainerView.h"

#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "Masonry.h"

@interface NXButtonContainerView ()

@property(nonatomic, weak) UIButton *button;

@end

@implementation NXButtonContainerView

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    if (self = [super initWithFrame:CGRectZero]) {
        [self.button setImage:image forState:UIControlStateSelected|UIControlStateNormal];
        [self.button setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (UIButton *)button {
    if (!_button) {
        UIButton *button = [[UIButton alloc] init];
        _button = button;
        [self addSubview:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.6);
            make.height.equalTo(@40);
        }];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
        [_button cornerRadian:3];
        
        [_button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        _button.backgroundColor = RMC_MAIN_COLOR;
        _button.accessibilityValue = @"FILE_PROTECT_BTN";
    }
    return _button;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.button setTitle:[NSString stringWithFormat:@"  %@",title] forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.button setImage:image forState:UIControlStateNormal];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    _button.enabled = enabled;
}

#pragma mark
- (void)click:(id)sender {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(sender);
    }
}

@end
