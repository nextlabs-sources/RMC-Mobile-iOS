//
//  NXChangeServerURLView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/4/25.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXChangeServerURLView.h"
#import "NXProjectInviteMemberView.h"
#import "Masonry.h"
#import "NXDefine.h"
#import "UIView+NXExtension.h"
#import "NXRMCDef.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
@interface NXChangeServerURLView ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NXCustomAlertWindow *alertWindow;
@property (nonatomic, strong) NXCustomAlertWindowRootViewController *rootVC;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintEnterLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UISwitch *defaultSwitch;
@property (nonatomic, strong) UILabel *defaultLabel;
@property (nonatomic, strong) UIButton *removeBtn;
@property (nonatomic, strong) UILabel *validLabel;
@end
@implementation NXChangeServerURLView
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
        _alertWindow.rootViewController = _rootVC;
    }
    return _alertWindow;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _rootVC = [[NXCustomAlertWindowRootViewController alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)tap:(id)sender {
    [self.textField resignFirstResponder];
}
- (instancetype)initWithurlStr:(NSString *)urlStr InviteHander:(onSaveClickHandle)hander {
    self.urlStr = urlStr;
    _onSaveClickHandle = hander;
    return [self init];
}
- (void)cancelBtnClick:(id)sender {
    [self close];
    
    [NXFirstWindow makeKeyAndVisible];
}
- (void)saveBtnClick:(id)sender {
    NSString *urlStr = self.textField.text;
    if (urlStr.length == 0) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SERVER_URL_EMPTY", NULL) hideAnimated:YES afterDelay:1.5];
        return;
    }
    if ([urlStr isEqualToString:@"https://skydrm.com"] || [urlStr isEqualToString:@"skydrm.com"]) {
        urlStr = @"www.skydrm.com";
      }
    if (![urlStr containsString:@"https://"]) {
        urlStr = [[NSString alloc]initWithFormat:@"https://%@",urlStr];
    }
    if (![NXCommonUtils isValidateURL:urlStr]) {
        self.validLabel.hidden = NO;
        return;
    }
    if(self.changeType == NXChangeServerURLViewTypeAddURL) {
        if (self.defaultSwitch.isOn) {
            [NXCommonUtils updateUserLoginUrl:nil newLoginUrl:urlStr isMakeDefault:YES];
        } else {
            [NXCommonUtils updateUserLoginUrl:nil newLoginUrl:urlStr isMakeDefault:NO];
        }
    }
    if (self.onSaveClickHandle) {
        self.onSaveClickHandle(urlStr);
    }
    [self close];
}
- (void)show {
    
    self.containerView.layer.shouldRasterize = YES;
    _containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.contentSize = CGSizeMake(0, 350);
    [_containerView addSubview:bgScrollView];
    
    UIView *headView = [[UIView alloc] init];
    
    UIButton *crossButton = [[UIButton alloc] init];
    crossButton.backgroundColor = [UIColor clearColor];
    crossButton.contentMode =  UIViewContentModeBottom;
    [crossButton setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    [crossButton addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    crossButton.imageEdgeInsets = UIEdgeInsetsMake(2,0, 0, 0);
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton setTitle:@"Save" forState:UIControlStateNormal];
    okButton.contentMode = UIViewContentModeLeft;
    [okButton setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [okButton addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
   
    [headView addSubview:crossButton];
    [headView addSubview:titleLabel];
    [headView addSubview:okButton];
    [bgScrollView addSubview:headView];
    UILabel *companyLabel = [[UILabel alloc]init];
    companyLabel.text = NSLocalizedString(@"UI_COMPANY_ACCOUNT_B", NULL);
    [bgScrollView addSubview:companyLabel];
    UILabel *hintEnterLabel = [[UILabel alloc]init];
    hintEnterLabel.textColor = [UIColor grayColor];
    [bgScrollView addSubview:hintEnterLabel];
    self.hintEnterLabel = hintEnterLabel;
    UITextField *textField = [[UITextField alloc]init];
    textField.keyboardType = UIKeyboardTypeURL;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.backgroundColor = [UIColor whiteColor];
    [self addSubview:textField];
    self.textField = textField;
    UILabel *lineLabel = [[UILabel alloc]init];
    [self addSubview:lineLabel];
    lineLabel.backgroundColor = [UIColor blackColor];

    UILabel *hintLabel = [[UILabel alloc]init];
    hintLabel.text = NSLocalizedString(@"UI_YOU_CAN_CHANGE_THE_URL", NULL);;
    hintLabel.numberOfLines = 0;
    hintLabel.font = [UIFont systemFontOfSize:15];
    [bgScrollView addSubview:hintLabel];
    UISwitch *remberSwitch = [[UISwitch alloc]init];
    remberSwitch.onTintColor = RMC_MAIN_COLOR;
    [remberSwitch setOn:YES];
    remberSwitch.tintColor = [UIColor colorWithRed:246/256.0 green:246/256.0 blue:246/256.0 alpha:1];
    remberSwitch.thumbTintColor = [UIColor lightGrayColor];
    [bgScrollView addSubview:remberSwitch];
    self.defaultSwitch = remberSwitch;
    remberSwitch.hidden = YES;
    UILabel *remberLabel = [[UILabel alloc]init];
    remberLabel.text = NSLocalizedString(@"UI_MAKE_DEFAULT", NULL);
    remberLabel.font = [UIFont systemFontOfSize:16];
    [bgScrollView addSubview:remberLabel];
    self.defaultLabel = remberLabel;
    remberLabel.hidden = YES;
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setTitle:NSLocalizedString(@"UI_REMOVE_THE_URL", NULL) forState:UIControlStateNormal];
    [removeBtn setTitleColor:[UIColor colorWithRed:100/256.0 green:160/256.0 blue:240/256.0 alpha:1] forState:UIControlStateNormal];
    removeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    removeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [removeBtn addTarget:self action:@selector(removeTheURL:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:removeBtn];
    removeBtn.hidden = YES;
    self.removeBtn = removeBtn;
    UILabel *validLabel = [[UILabel alloc]init];
    validLabel.textColor = [UIColor redColor];
    validLabel.text = NSLocalizedString(@"UI_THE_URL_IS_NOT_VALID", NULL);
    [bgScrollView addSubview:validLabel];
    validLabel.hidden = YES;
    self.validLabel = validLabel;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.alertWindow.rootViewController.view addSubview:self];
    [self.alertWindow makeKeyAndVisible];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideBottom);
                make.leading.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideLeading);
                make.trailing.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideTrailing);
            }];
        }
    }
    else
    {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_alertWindow.rootViewController.view);
            make.bottom.equalTo(_alertWindow.rootViewController.view);
            make.leading.equalTo(_alertWindow.rootViewController.view);
            make.trailing.equalTo(_alertWindow.rootViewController.view);
        }];
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.trailing.equalTo(self).offset(-10);
        make.height.equalTo(self).multipliedBy(0.5);
        make.top.equalTo(self).offset(10);
    }];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgScrollView);
        make.left.equalTo(bgScrollView).offset(10);
        make.right.equalTo(self.containerView).offset(-10);
        make.height.equalTo(@35);
    }];
    [crossButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView).offset(5);
        make.left.equalTo(headView).offset(5);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(crossButton);
        make.width.equalTo(@45);
        make.right.equalTo(headView).offset(-5);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headView);
        make.height.equalTo(headView);
    }];
    [companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(kMargin * 3);
        make.left.equalTo(bgScrollView).offset(kMargin * 2);
        make.width.equalTo(@200);
        make.height.equalTo(@20);
    }];
    [hintEnterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(companyLabel.mas_bottom).offset(kMargin * 2);
        make.left.width.height.equalTo(companyLabel);
    }];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hintEnterLabel.mas_bottom).offset(kMargin);
        make.left.equalTo(companyLabel);
        make.right.equalTo(bgScrollView).offset(-kMargin * 2);
    }];
    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom);
        make.height.equalTo(@1);
        make.left.right.equalTo(textField);
    }];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineLabel.mas_bottom).offset(kMargin);
        make.left.right.equalTo(lineLabel);
        make.height.equalTo(@20);
    }];
    [removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hintLabel.mas_bottom).offset(kMargin * 3);
        make.left.equalTo(hintLabel);
        make.width.equalTo(@200);
        make.height.equalTo(@40);
    }];
    [remberSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(removeBtn);
    }];
    [remberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(remberSwitch);
        make.left.equalTo(remberSwitch.mas_right).offset(kMargin * 3);
        make.right.equalTo(hintLabel);
    }];
    [validLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remberLabel.mas_bottom).offset(kMargin * 3);
        make.left.equalTo(removeBtn);
        make.width.equalTo(@200);
        make.height.equalTo(@30);
    }];
    _containerView.layer.opacity = 0.5f;
    _containerView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.1f delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
                         _containerView.layer.opacity = 1.0f;
                         _containerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:nil
     ];
}
- (void)setChangeType:(NXChangeServerURLViewType)changeType {
    _changeType = changeType;
    switch (changeType) {
        case NXChangeServerURLViewTypeAddURL:
            self.titleLabel.text = NSLocalizedString(@"UI_ADD_A_URL", NULL);
            self.hintEnterLabel.text = NSLocalizedString(@"UI_ENTER_URL", NULL);
            self.defaultLabel.hidden = NO;
            self.defaultSwitch.hidden = NO;
            break;
            
       case NXChangeServerURLViewTypeEditURL:
            self.titleLabel.text = NSLocalizedString(@"UI_CHANGE_THE_URL", NULL);
            self.hintEnterLabel.text = NSLocalizedString(@"UI_EDIT_URL", NULL);
            self.textField.text = self.urlStr;
            self.removeBtn.hidden = NO;
            break;
    }
}
- (void)removeTheURL:(id)sender {
    if (self.removeHandle) {
        self.removeHandle(self.urlStr);
    }
    [self close];
}
- (void)close {
    self.alertWindow.alpha = 0;
    [self.alertWindow removeFromSuperview];
    self.alertWindow.rootViewController = nil;
    self.alertWindow = nil;
    [self hd_removeAllSubviews];
    [self removeFromSuperview];
}
- (void)showErrorMessage {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.validLabel.hidden = YES;
    return YES;
}
- (void)showLoadingView {
    [NXMBManager showLoadingToView:self.containerView];
}
- (void)hiddenLoadingView {
    [NXMBManager hideHUDForView:self.containerView];
}
@end
