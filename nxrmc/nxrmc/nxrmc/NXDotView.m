//
//  NXDotView.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#define kAnimateDuration 0.5

#import "NXDotView.h"

@interface NXDotView ()
@end

@implementation NXDotView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    //setting circle view.
    self.backgroundColor    = [UIColor clearColor];
    
    self.deactiveColor = [UIColor clearColor];
    self.activeColor = self.backgroundColor;
}

- (void)layoutSubviews {
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/2;
}

- (void)changeActiveState:(BOOL)active {
    if (active) {
        [self animateToActiveState];
    } else {
        [self animateToDeactiveState];
    }
}

- (void)animateToActiveState {
    [UIView animateWithDuration:kAnimateDuration delay:0 usingSpringWithDamping:.5 initialSpringVelocity:-20 options:UIViewAnimationOptionCurveLinear animations:^{
        self.backgroundColor = self.activeColor;
        self.transform = CGAffineTransformMakeScale(1.4, 1.4);
    } completion:nil];
}

- (void)animateToDeactiveState {
    [UIView animateWithDuration:kAnimateDuration delay:0 usingSpringWithDamping:.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.backgroundColor = self.deactiveColor;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}
@end
