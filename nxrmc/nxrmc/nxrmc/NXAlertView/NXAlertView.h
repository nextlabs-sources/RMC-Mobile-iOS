//
//  NXAlertView.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 27/04/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXDefine.h"

NX_EXTERN NSString *const NXAlertViewWillShowNotification;
NX_EXTERN NSString *const NXAlertViewDidShowNotification;
NX_EXTERN NSString *const NXAlertViewWillDismissNotification;
NX_EXTERN NSString *const NXAlertViewDidDismissNotification;

typedef NS_ENUM(NSInteger, NXAlertViewStyle) {
    NXAlertViewStyleAlert = 0,  // 默认
    NXAlertViewStyleActionSheet // 暂未实现(有空再编写Frame)
};

typedef NS_ENUM(NSInteger, NXAlertViewItemType) {
    NXAlertViewItemTypeDefault = 0,   // 字体默认蓝色
    NXAlertViewItemTypeDestructive,   // 字体默认红色
    NXAlertViewItemTypeClickForbidden,  // 字体默认灰色
};

typedef NS_ENUM(NSInteger, NXAlertViewBackgroundStyle) {
    NXAlertViewBackgroundStyleSolid = 0,    // 平面的
    NXAlertViewBackgroundStyleGradient      // 聚光的
};

typedef NS_ENUM(NSInteger, NXAlertViewTransitionStyle) {
    NXAlertViewTransitionStyleFade = 0,             // 渐退
    NXAlertViewTransitionStyleSlideFromTop,         // 从顶部滑入滑出
    NXAlertViewTransitionStyleSlideFromBottom,      // 从底部滑入滑出
    NXAlertViewTransitionStyleBounce,               // 弹窗效果
    NXAlertViewTransitionStyleDropDown              // 顶部滑入底部滑出
};

@class NXAlertView;
typedef void(^NXAlertViewHandler)(NXAlertView *alertView);

@interface NXAlertView : UIView

/** 标题-只支持1行 */
@property (nonatomic, copy) NSString *title;

/** 消息描述-支持多行 */
@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) NXAlertViewStyle alertViewStyle;              // 默认是NXAlertViewStyleAlert
@property (nonatomic, assign) NXAlertViewTransitionStyle transitionStyle;   // 默认是 NXAlertViewTransitionStyleFade
@property (nonatomic, assign) NXAlertViewBackgroundStyle backgroundStyle;   // 默认是 NXAlertViewBackgroundStyleSolid

@property (nonatomic, copy) NXAlertViewHandler willShowHandler;
@property (nonatomic, copy) NXAlertViewHandler didShowHandler;
@property (nonatomic, copy) NXAlertViewHandler willDismissHandler;
@property (nonatomic, copy) NXAlertViewHandler didDismissHandler;

@property (nonatomic, strong) UIColor *viewBackgroundColor          UI_APPEARANCE_SELECTOR; // 默认是白色
@property (nonatomic, strong) UIColor *titleColor                   UI_APPEARANCE_SELECTOR; // 默认是黑色
@property (nonatomic, strong) UIColor *messageColor                 UI_APPEARANCE_SELECTOR; // 默认是灰色
@property (nonatomic, strong) UIFont *titleFont                     UI_APPEARANCE_SELECTOR; // 默认是18.0
@property (nonatomic, strong) UIFont *messageFont                   UI_APPEARANCE_SELECTOR; // 默认是16.0
@property (nonatomic, strong) UIFont *buttonFont                    UI_APPEARANCE_SELECTOR; // 默认是buttonFontSize
@property (nonatomic, assign) CGFloat cornerRadius                  UI_APPEARANCE_SELECTOR; // 默认是10.0

/**
 *  初始化一个弹窗提示
 */
- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (instancetype)alertViewWithTitle:(NSString *)title andMessage:(NSString *)message;

/**
 *  添加按钮点击时候和处理
 *
 *  @param title   按钮名字
 *  @param type    按钮类型
 */

- (void)addItemWithTitle:(NSString *)title type:(NXAlertViewItemType)type handler:(NXAlertViewHandler)handler;

/**
 *  显示弹窗提示
 */
- (void)show;

@end
