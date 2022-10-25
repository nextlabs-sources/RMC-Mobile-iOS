//
//  NXMBManager.h
//  nxrmc
//
//  Created by nextlabs on 11/21/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBProgressHUD.h"

typedef NS_ENUM(NSUInteger, NXMBProgressMode) {
    NXMBProgressModeDeterminate,
    NXMBProgressModeDeterminateHorizontalBar,
    NXMBProgressModeAnnularDeterminate,
};

static float const kDisplayTime = 2.0; //second.


@interface NXMBProgressView : UIView

@property(nonatomic, assign)float progress;

- (instancetype)initWithHUD:(MBProgressHUD *)hud;
- (void)hide;

@end


@interface NXMBManager : NSObject

+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message image:(UIImage *)image;

+ (void)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)showMessage:(NSString *)message image:(UIImage *)image toView:(UIView *)view;

+ (void)showMessage:(NSString *)message hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;
+ (void)showMessage:(NSString *)message image:(UIImage *)image hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

+ (void)showMessage:(NSString *)message toView:(UIView *)view hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;
+ (void)showMessage:(NSString *)message image:(UIImage *)image toView:(UIView *)view hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

+ (void)showLoading;
+ (void)showLoading:(NSString *)message;
+ (NXMBProgressView *)showLoading:(NSString *)message progress:(float)progress mode:(NXMBProgressMode)mode;

+ (void)showLoadingToView:(UIView *)view;
+ (void)showLoading:(NSString *)message toView:(UIView *)view;
+ (NXMBProgressView *)showLoading:(NSString *)message progress:(float)progress mode:(NXMBProgressMode)mode toView:(UIView *)view;

+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;

@end
