//
//  NXProjectDeclineMsgView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 13/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectDeclineMsgView.h"
#import "NXProjectInviteMemberView.h"
#import "NXDefine.h"
#import "Masonry.h"
#import "UIView+NXExtension.h"
#import "NXCommentInputView.h"
@interface NXProjectDeclineMsgView ()
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *inviteButton;
@property (nonatomic,strong) UIView *containerView;

@property (nonatomic,strong) NXCustomAlertWindow *alertWindow;
@property (nonatomic, strong) NXCustomAlertWindowRootViewController *rooVC;

@property (nonatomic,assign) BOOL keyBoardIsShow;

@property (nonatomic,assign) CGFloat keyboardHeight;


@end


@implementation NXProjectDeclineMsgView
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_containerView];
    }
    return _containerView;
}
- (NXCustomAlertWindow *)alertWindow {
    if (!_alertWindow) {
        _alertWindow = [[NXCustomAlertWindow alloc] initWithFrame:NXMainScreenBounds];
        _alertWindow.alpha = 1.0;
        _alertWindow.rootViewController = _rooVC;
    }
    
    return _alertWindow;
}
- (NSString *)reasonStr {
    if (self.inputView) {
        return  [self.inputView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return nil;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        _rooVC = [[NXCustomAlertWindowRootViewController alloc] init];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTheKeyBoard)];
        [self addGestureRecognizer:tapGesture];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title inviteHander:(onDeclineClickHandle)hander;
{
    _title = title;
    _onDeclineClickHandle = hander;
    return [self init];
}
- (void)show
{
    // create containerView
    self.containerView.layer.shouldRasterize = YES;
    self.containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIButton *crossButton = [[UIButton alloc] init];
    crossButton.backgroundColor = [UIColor clearColor];
    crossButton.contentMode =  UIViewContentModeBottom;
    [crossButton setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    [crossButton addTarget:self action:@selector(onClickCrossButton:) forControlEvents:UIControlEventTouchUpInside];
    crossButton.imageEdgeInsets = UIEdgeInsetsMake(2,0, 0, 0);
    //[crossButton setBackgroundColor:[UIColor yellowColor]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.text = _title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    
    UIButton *declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [declineButton setTitle:NSLocalizedString(@"UI_DECLINE", NULL) forState:UIControlStateNormal];
    declineButton.contentMode = UIViewContentModeLeft;
    [declineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    declineButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [declineButton addTarget:self action:@selector(onClickDeclineButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [headView addSubview:crossButton];
    [headView addSubview:titleLabel];
    [headView addSubview:declineButton];
    [self.containerView addSubview:headView];
    NXCommentInputView *inputView = [[NXCommentInputView alloc]init];
    inputView.maxCharacters = 250;
    inputView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_REASON_FOR_DECLINE", NULL) subTitle:NSLocalizedString(@"UI_INVITATION_OPTIONAL", NULL) subTitleColor:[UIColor grayColor]];
    inputView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:inputView];
    self.inputView = inputView;
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:self.containerView];
    
    [self.alertWindow.rootViewController.view addSubview:self];
    [self.alertWindow makeKeyAndVisible];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_alertWindow.rootViewController.view);
        make.bottom.equalTo(_alertWindow.rootViewController.view);
        make.leading.equalTo(_alertWindow.rootViewController.view);
        make.trailing.equalTo(_alertWindow.rootViewController.view);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@250);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView);
        make.trailing.equalTo(self.containerView);
        make.width.equalTo(self.containerView);
        make.top.equalTo(self.containerView);
        make.height.equalTo(@100);
    }];
    
    [crossButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView).offset(5);
        make.width.equalTo(@42);
        make.height.equalTo(@42);
        make.leading.equalTo(headView).offset(5);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView).offset(50);
        make.height.equalTo(@50);
        make.leading.equalTo(headView).offset(5);
        make.trailing.equalTo(headView).offset(-5);
    }];
    
    [declineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView).offset(5);
        make.height.equalTo(@42);
        make.width.equalTo(@55);
        make.right.equalTo(headView).offset(-10);
    }];
    
    
    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(20);
        make.right.equalTo(self.containerView).offset(-20);
        make.top.equalTo(headView.mas_bottom).offset(20);
        make.height.equalTo(@130);
    }];
    
    self.containerView.layer.opacity = 0.5f;
    self.containerView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.1f delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
                         self.containerView.layer.opacity = 1.0f;
                         self.containerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:nil
     ];
}

#pragma -Mark Method

- (void)hideTheKeyBoard
{
    [self endEditing:YES];
}

- (void)onClickCrossButton:(id)sender
{
    self.alertWindow.alpha = 0;
    [self.alertWindow removeFromSuperview];
    self.alertWindow.rootViewController = nil;
    self.alertWindow = nil;
    [self hd_removeAllSubviews];
    [self removeFromSuperview];
    
    [NXFirstWindow makeKeyAndVisible];
}

- (void)onClickDeclineButton:(id)sender
{
    if (_onDeclineClickHandle) {
        self.onDeclineClickHandle(self);
    }
}

- (void)dismiss
{
    [self onClickCrossButton:nil];
}

#pragma -mark Keyboard Event

- (void)keyboardWillShow: (NSNotification *)notification
{
    _keyBoardIsShow  = YES;
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    _keyboardHeight = keyboardSize.height;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@250);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).offset(-(keyboardSize.height/1.1));
            }];
        }
    
    else
    {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@250);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-(keyboardSize.height/2));
        }];
        
    }
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    _keyBoardIsShow  = NO;
    _keyboardHeight = 0.0;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@250);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
    }
    else
    {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@250);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
    }
}

#pragma -mark Device Orientation Notification

- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // CGFloat containViewHeight = 300;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
        if (_keyBoardIsShow == YES) {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@250);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).offset(-(_keyboardHeight/2));
            }];
            
        }
        else
        {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@250);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self);
            }];
        }
    }
    else
    {
        if (_keyBoardIsShow) {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@250);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).offset(-(_keyboardHeight/2));
            }];
            
        }
        else
        {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@250);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self);
            }];
            
        }
    }
}



- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle subTitleColor:(UIColor *)color {
    NSMutableAttributedString *myTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *sub = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :color, NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [myTitle appendAttributedString:sub];
    return myTitle;
}
@end
