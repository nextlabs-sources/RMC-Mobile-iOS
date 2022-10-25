//
//  NXMBManager.m
//  nxrmc
//
//  Created by nextlabs on 11/21/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMBManager.h"

@interface NXMBProgressView ()

@property(nonatomic, strong) MBProgressHUD *hud;

@end

@implementation NXMBProgressView

- (instancetype)initWithHUD:(MBProgressHUD *)hud {
    if (self = [super init]) {
        self.hud = hud;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)hide {
    [_hud hideAnimated:YES];
}

- (void)setProgress:(float)progress {
    _hud.progress = progress;
}

@end

@implementation NXMBManager

+ (void)showMessage:(NSString *)message {
    [self showMessage:message toView:nil hideAnimated:YES afterDelay:INFINITY];
}

+ (void)showMessage:(NSString *)message image:(UIImage *)image {
    [self showMessage:message image:image toView:nil hideAnimated:YES afterDelay:INFINITY];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view {
    [self showMessage:message toView:view hideAnimated:YES afterDelay:INFINITY];
}

+ (void)showMessage:(NSString *)message image:(UIImage *)image toView:(UIView *)view {
    [self showMessage:message image:image toView:nil hideAnimated:YES afterDelay:INFINITY];
}

+ (void)showMessage:(NSString *)message hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self showMessage:message toView:nil hideAnimated:animated afterDelay:delay];
}

+ (void)showMessage:(NSString *)message image:(UIImage *)image hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self showMessage:message image:image toView:nil hideAnimated:animated afterDelay:delay];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    if (view == nil) {
        view =  [[[UIApplication sharedApplication] delegate] window];
    }
    
    [MBProgressHUD hideHUDForView:view animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [self commonInitializeHUDDisplay:hud];
    
    hud.label.text = message;
    hud.label.numberOfLines = 0;
    hud.label.textAlignment = NSTextAlignmentCenter;
    hud.label.lineBreakMode = NSLineBreakByWordWrapping;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:animated afterDelay:delay];
}

+ (void)showMessage:(NSString *)message image:(UIImage *)image toView:(UIView *)view hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    if (view == nil) {
        view =  [[[UIApplication sharedApplication] delegate] window];
    }
    
    [MBProgressHUD hideHUDForView:view animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [self commonInitializeHUDDisplay:hud];
    
    hud.label.numberOfLines = 0;
    hud.label.text = message;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:animated afterDelay:delay];
}

+ (void)showLoading {
    [self showLoading:nil toView:nil];
}

+ (void)showLoading:(NSString *)message {
    [self showLoading:message toView:nil];
}

+ (NXMBProgressView *)showLoading:(NSString *)message progress:(float)progress mode:(NXMBProgressMode)mode {
    return [self showLoading:message progress:progress mode:mode toView:nil];
}

+ (void)showLoadingToView:(UIView *)view {
    [self showLoading:nil toView:view];
}

+ (void)showLoading:(NSString *)message toView:(UIView *)view {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    if (view == nil) {
        view =  [[[UIApplication sharedApplication] delegate] window];
    }
    
    [MBProgressHUD hideHUDForView:view animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [self commonInitializeHUDDisplay:hud];
    
    hud.label.text = message;
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud removeFromSuperViewOnHide];
}

+ (NXMBProgressView *)showLoading:(NSString *)message progress:(float)progress mode:(NXMBProgressMode)mode toView:(UIView *)view {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    if (view == nil) {
        view =  [[[UIApplication sharedApplication] delegate] window];
    }
    
    [MBProgressHUD hideHUDForView:view animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [self commonInitializeHUDDisplay:hud];
    
    hud.label.text = message;
    switch (mode) {
        case NXMBProgressModeDeterminate:
            hud.mode = MBProgressHUDModeDeterminate;
            break;
        case NXMBProgressModeDeterminateHorizontalBar:
            hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
            break;
        case NXMBProgressModeAnnularDeterminate:
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            break;
        default:
            break;
    }
    
    hud.progress = progress;
    
    [hud removeFromSuperViewOnHide];
    
    NXMBProgressView *progressView = [[NXMBProgressView alloc] initWithHUD:hud];
    progressView.progress = progress;
    return progressView;
}

+ (void)hideHUD {
    [self hideHUDForView:nil];
}

+ (void)hideHUDForView:(UIView *)view {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    if (view == nil) {
        view =  [[[UIApplication sharedApplication] delegate] window];
    }
    
    [MBProgressHUD hideHUDForView:view animated:YES];
}

#pragma mark - private method
+ (void)commonInitializeHUDDisplay:(MBProgressHUD *)hud {
    
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.animationType = MBProgressHUDAnimationFade;
    hud.userInteractionEnabled = YES;
    hud.graceTime = 0.2;
    hud.margin = 15.0f;
}

@end
