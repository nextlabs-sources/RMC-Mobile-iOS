//
//  NXRoundButton.h
//  CoreAnimationDemo
//
//  Created by EShi on 11/8/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@class NXRoundButtonView;
@protocol NXRoundButtonViewDelegate <NSObject>

@required
- (void)nxroundButtonView:(NXRoundButtonView *)roundButtonView actionButtonClicked:(UIButton *)actionButton;
@optional
- (BOOL)nxroundButtonView:(NXRoundButtonView *)roundButtonView actionButtonShouldClicked:(UIButton *)actionButton;
@end
@interface NXRoundButtonView : UIView

- (instancetype)initWithRadius:(CGFloat)radius;
- (instancetype)initWithRadius:(CGFloat)radius shadowOffset:(CGSize) shadowOffset shadowRadius:(CGFloat) shadowRadius;
- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius;

- (void)setBtnBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (void)setBtnImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *) imageForState:(UIControlState)state;
@property(nonatomic, strong) UIButton *actionButton;
@property(nonatomic, weak) id<NXRoundButtonViewDelegate> delegate;
@property(nonatomic, assign, getter=isSelected) BOOL selected;
@end
