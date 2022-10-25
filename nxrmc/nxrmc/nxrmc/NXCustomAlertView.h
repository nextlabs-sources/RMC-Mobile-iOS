//
//  NXCustomAlertView.h
//  nxrmc
//
//  Created by xx-huang on 25/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXEmailView.h"
#import <UIKit/UIKit.h>

@class NXCustomAlertView;

typedef void (^onButtonClickHandle)(NXCustomAlertView *alertView, NSInteger buttonIndex);

@interface NXCustomAlertView :UIView

@property (nonatomic,retain) UIView *parentView;
@property (nonatomic,retain) UIView *dialogView;
@property (nonatomic,retain) UIView *containerView;

@property (nonatomic, retain) NSArray *buttonTitles;

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleBackgroundColor;

@property (nonatomic,strong) NXEmailView *emailView;

@property (nonatomic, copy) onButtonClickHandle onButtonClickHandle;

- (instancetype)init;
- (instancetype)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor titleBackgroundColor:(UIColor *)titleBackgroundColor;

- (void)addContentView: (UIView *)contentView;
- (void)setOnButtonClickHandle:(onButtonClickHandle)onButtonClickHandle;
- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)show;
- (void)dismiss;

@end
