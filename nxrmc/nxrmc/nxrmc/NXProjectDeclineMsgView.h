//
//  NXProjectDeclineMsgView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 13/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXProjectDeclineMsgView;
@class NXCommentInputView;
typedef void (^onDeclineClickHandle)(NXProjectDeclineMsgView *alertView);


@interface NXProjectDeclineMsgView : UIView
@property (nonatomic, strong) NXCommentInputView *inputView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *reasonStr;
@property (nonatomic, copy) onDeclineClickHandle onDeclineClickHandle;

- (instancetype)initWithTitle:(NSString *)title inviteHander:(onDeclineClickHandle)hander;
- (void)show;
- (void)dismiss;
@end
