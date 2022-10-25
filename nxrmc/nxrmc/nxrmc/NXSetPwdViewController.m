//
//  NXSetPwdViewController.m
//  nxrmc
//
//  Created by nextlabs on 12/8/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSetPwdViewController.h"

#import "Masonry.h"

#import "NXAccountInputTextField.h"
#import "UIImage+ColorToImage.h"
#import "NXMBManager.h"
#import "UIImage+Cutting.h"
#import "UIView+UIExt.h"

#import "NXGetCaptchaAPI.h"
#import "NXSetPasswordAPI.h"

#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXResetPasswordAPI.h"
#import "NXLProfile.h"
#define KSTEXTFIELDTAG 1024
@interface NXSetPwdViewController()<UIGestureRecognizerDelegate,UITextFieldDelegate>

@property(nonatomic, strong) NSString *nonce;

@property(nonatomic, weak) UITextField *oldPSWField;
@property(nonatomic, weak) UITextField *myNewSetPSWField;
@property(nonatomic, weak) UITextField *retypeNewPSWField;
@property(nonatomic, weak) UIButton *sureButton;
@property(nonatomic, weak) UILabel *invalidPSWLabel;
@property(nonatomic, weak) UILabel *matchLabel;
@property(nonatomic, weak) UILabel *confirmPswLabel;
@property(nonatomic, assign) BOOL isNewRight;
@property(nonatomic, assign) BOOL isMatch;
@property(nonatomic, strong) UIScrollView *bgScrollView;
@end

@implementation NXSetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self commonInit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.bgScrollView.contentSize = CGSizeMake(0,600);
}

#pragma mark
- (void)changePSWButtonClicked:(id)sender {
//    if (!self.oldPSWField.text.length) {
//        [NXMBManager showMessage:NSLocalizedString(@"Please input current password", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
//        return;
//    }
//    
//    if (!self.myNewSetPSWField.text.length) {
//        [NXMBManager showMessage:NSLocalizedString(@"Please input new password", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
//        return;
//    }
//    
//    if (!self.retypeNewPSWField.text.length) {
//        [NXMBManager showMessage:NSLocalizedString(@"Please confirm new password", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
//        return;
//    }
//    
//    if (![self.retypeNewPSWField.text isEqualToString:self.myNewSetPSWField.text]) {
//        [NXMBManager showMessage:NSLocalizedString(@"The passwords entered twice are not equal", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
//        return;
//    }
//    
//    NSString *validateRegex = @"^(?=.*[A-Za-z])(?=.*\\d)(?=.*[\\W])[A-Za-z\\d\\W]{8,}$";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validateRegex];
//    BOOL isValid = [predicate evaluateWithObject: self.myNewSetPSWField.text];
//    if (!isValid) {
//        self.invalidPSWLabel.hidden = NO;
//        return;
//    }else{
//        self.invalidPSWLabel.hidden = YES;
//    }
    NSDictionary *restPSWModel = @{NXResetPasswordRequestOldPSWKey:self.oldPSWField.text, NXResetPasswordRequestNewPSWKey:self.myNewSetPSWField.text};
    
    NXResetPasswordRequest *restPSWReq = [[NXResetPasswordRequest alloc] init];
    WeakObj(self);
    [NXMBManager showLoadingToView:self.view];
    [restPSWReq requestWithObject:restPSWModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        dispatch_main_async_safe(^{
            [NXMBManager hideHUDForView:self.view];
            if (error) {
                NSString *errorStr = NSLocalizedString(@"MSG_NETWORK_UNUSABLE", NULL);
                if ([error.localizedDescription isEqualToString:errorStr]) {
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil) toView:self.view hideAnimated:YES afterDelay:kDelay * 1.5];
                    return;
                }
                [NXMBManager showMessage:NSLocalizedString(@"MSG_PROFILE_CHANGE_PASSWORD_FAILED", nil) toView:self.view hideAnimated:YES afterDelay:kDelay * 1.5];
                return;
            }
            NXResetPasswordResponse *resetResponse = (NXResetPasswordResponse *)response;
            if (resetResponse.rmsStatuCode != 200) {
                [NXMBManager showMessage:resetResponse.rmsStatuMessage toView:self.view hideAnimated:YES afterDelay:kDelay];
                return;
            }
            [NXMBManager showMessage:NSLocalizedString(@"MSG_PROFILE_CHANGE_PASSWORD_SUSSESS", nil) toView:self.view hideAnimated:YES afterDelay:kDelay * 1.5];
            // update user ticket
            NXLProfile *profile = [NXLoginUser sharedInstance].profile;
            if (resetResponse.ttl) {
                profile.ttl = resetResponse.ttl;
            }
            if (resetResponse.ticket) {
                profile.ticket = resetResponse.ticket;
            }
            
            [[NXLoginUser sharedInstance] updateUserProfile:profile];
            
        });
    }];
}
#pragma mark ---->textField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *allStr = nil;
    
    if (range.length == 1) {
        allStr = [textField.text substringToIndex:textField.text.length-1];
    } else if (range.length == 0) {
       allStr = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    UITextField *currentTextField = [self.view viewWithTag:KSTEXTFIELDTAG];
//    NSString *allStr = [NSString stringWithFormat:@"%@%@",textField.text,string];
    if (textField.tag == KSTEXTFIELDTAG +2) {
        if(![self matchPswRightWithPsw:allStr]) {
            [self.confirmPswLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(textField);
                make.top.equalTo(self.invalidPSWLabel.mas_bottom).offset(5);
                make.height.equalTo(@35);
            }];
            [UIView animateWithDuration:0.5 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.invalidPSWLabel.hidden = NO;
                self.isNewRight = NO;
                self.invalidPSWLabel.text = NSLocalizedString(@"UI_PASSWORD_FORMAT_INVALID", NULL);
            }];
        }else if([currentTextField.text isEqualToString:allStr]){
            [self.confirmPswLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(textField);
                make.top.equalTo(self.invalidPSWLabel.mas_bottom).offset(5);
                make.height.equalTo(@35);
            }];
            [UIView animateWithDuration:0.5 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.invalidPSWLabel.hidden = NO;
                self.isNewRight = NO;
                self.invalidPSWLabel.text = NSLocalizedString(@"UI_PASSWORD_SAME", NULL);
            }];
        }else {
            self.invalidPSWLabel.hidden = YES;
            self.isNewRight = YES;
            [self.confirmPswLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(textField);
                make.top.equalTo(textField.mas_bottom).offset(5);
                make.height.equalTo(@35);
            }];
        }
  
    } else if (textField.tag == KSTEXTFIELDTAG + 3) {
        if (![allStr isEqualToString:self.myNewSetPSWField.text]) {
            self.matchLabel.hidden = NO;
            self.isMatch = NO;
        } else {
            self.matchLabel.hidden = YES;
            self.isMatch = YES;
//            if (self.oldPSWField.text.length>0) {
//                self.sureButton.enabled = YES;
//            }
            
        }
    }
    if (self.oldPSWField.text.length>0&&self.isNewRight&&self.isMatch&&allStr.length>0) {
        self.sureButton.enabled = YES;
    }else {
        self.sureButton.enabled = NO;
    }
        return YES;
}

- (BOOL)matchPswRightWithPsw:(NSString *)pswStr {
    NSString *validateRegex = @"^(?=.*[A-Za-z])(?=.*\\d)(?=.*[\\W])[A-Za-z\\d\\W]{8,}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validateRegex];
    BOOL isValid = [predicate evaluateWithObject:pswStr];
    return isValid;
}
#pragma mark
- (void)commonInit {
    self.navigationItem.backBarButtonItem.title = @"";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    [tap addTarget:self action:@selector(tap:)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"UI_PROFILE_SET_PASSWORD", NULL);
    
    //init background view when pull down tablview.
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = RMC_MAIN_COLOR;
    [self.view addSubview:backgroundView];
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_topLayoutGuideBottom);
    }];
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.backgroundColor = [UIColor whiteColor];
    bgScrollView.bounces = NO;
    [self.view addSubview:bgScrollView];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    self.bgScrollView = bgScrollView;
    UILabel *oldPswLabel = [[UILabel alloc]init];
    oldPswLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_PROFILE_CURRENT_PASSWORD", NULL) subTitle:@"*"];
    [bgScrollView addSubview:oldPswLabel];
    NXAccountInputTextField *oldPSWTextField = [[NXAccountInputTextField alloc] init];
    oldPSWTextField.clearButtonMode =  UITextFieldViewModeWhileEditing;
    [bgScrollView addSubview:oldPSWTextField];
    oldPSWTextField.placeholder = NSLocalizedString(@"UI_PROFILE_INPUT_CURRENT_PASSWORD", NULL);
//    oldPSWTextField.offset = 3;
//    oldPSWTextField.underLineColor = RMC_MAIN_COLOR;
    oldPSWTextField.delegate = self;
    oldPSWTextField.tag = KSTEXTFIELDTAG;
    
    UILabel *newPswLabel = [[UILabel alloc]init];
    newPswLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_PROFILE_NEW_PASSWORD", NULL) subTitle:@"*"];
    [bgScrollView addSubview:newPswLabel];

    NXAccountInputTextField *newPSWTextField = [[NXAccountInputTextField alloc] init];
    [bgScrollView addSubview:newPSWTextField];
    
    UIButton *sureButton = [[UIButton alloc] init];
    [bgScrollView addSubview:sureButton];

    newPSWTextField.placeholder = NSLocalizedString(@"UI_PROFILE_INPUT_NEW_PASSWORD", NULL);
    newPSWTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    newPSWTextField.offset = 3;
//    newPSWTextField.underLineColor = RMC_MAIN_COLOR;
    newPSWTextField.tag = KSTEXTFIELDTAG + 2;
    newPSWTextField.delegate = self;
    UILabel *retypePswLabel = [[UILabel alloc]init];
    retypePswLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_PROFILE_CONFIRM_PASSWORD", NULL) subTitle:@"*"];
    [bgScrollView addSubview:retypePswLabel];
    self.confirmPswLabel = retypePswLabel;
    NXAccountInputTextField *retypePSWTextField = [[NXAccountInputTextField alloc] init];
    [bgScrollView addSubview:retypePSWTextField];
    retypePSWTextField.placeholder = NSLocalizedString(@"UI_PROFILE_INOUT_CONFIRM_PASSWORD", NULL);
//    retypePSWTextField.offset = 3;
//    retypePSWTextField.underLineColor = RMC_MAIN_COLOR;
    retypePSWTextField.tag = KSTEXTFIELDTAG + 3;
    retypePSWTextField.delegate = self;
    retypePSWTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [bgScrollView addSubview:retypePSWTextField];
    
    UILabel *invalidPSWLabel = [[UILabel alloc] init];
//    invalidPSWLabel.contentMode = UIViewContentModeTop;
    invalidPSWLabel.numberOfLines = 0;
    invalidPSWLabel.font = [UIFont systemFontOfSize:14];
//    invalidPSWLabel.lineBreakMode = NSLineBreakByWordWrapping;
    invalidPSWLabel.textColor = [UIColor redColor];
    invalidPSWLabel.adjustsFontSizeToFitWidth = YES;
    invalidPSWLabel.hidden = YES;
    [bgScrollView addSubview:invalidPSWLabel];
    
    UILabel *matchLabel = [[UILabel alloc]init];
    matchLabel.textColor = [UIColor redColor];
    matchLabel.text = NSLocalizedString(@"UI_PASSWORD_NOT_MATCH", NULL);
    matchLabel.hidden = YES;
    matchLabel.font = [UIFont systemFontOfSize:14];
    [bgScrollView addSubview:matchLabel];
    self.matchLabel = matchLabel;
    
    self.myNewSetPSWField = newPSWTextField;
    self.oldPSWField = oldPSWTextField;
    self.retypeNewPSWField = retypePSWTextField;
    self.invalidPSWLabel = invalidPSWLabel;
    
    self.myNewSetPSWField.secureTextEntry = YES;
    self.oldPSWField.secureTextEntry = YES;
    self.retypeNewPSWField.secureTextEntry = YES;
    
    
    [sureButton setTitle:NSLocalizedString(@"UI_COM_PROFILE_CHANGE_PASSWORD", NULL) forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(changePSWButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [sureButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton cornerRadian:3];
    [sureButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    sureButton.enabled = NO;
    self.sureButton = sureButton;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [oldPswLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin * 4);
                make.top.equalTo(bgScrollView.mas_safeAreaLayoutGuideTop).offset(kMargin * 2);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin * 4);
                make.height.equalTo(@35);
            }];
            [oldPSWTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin * 4);
                make.top.equalTo(oldPswLabel.mas_bottom);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin * 4);
                make.height.equalTo(@35);
            }];
            [newPswLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin * 4);
                make.top.equalTo(oldPSWTextField.mas_bottom).offset(kMargin);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin * 4);
                make.height.equalTo(@35);
            }];
            [newPSWTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(oldPSWTextField);
                make.top.equalTo(newPswLabel.mas_bottom);
                make.height.equalTo(@35);
            }];
            [retypePswLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin * 4);
                make.top.equalTo(newPSWTextField.mas_bottom).offset(kMargin);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin * 4);
                make.height.equalTo(@35);
            }];
        }
    }
    else
    {
        [oldPswLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kMargin * 4);
            make.top.equalTo(bgScrollView).offset(kMargin * 2);
            make.right.equalTo(self.view).offset(-kMargin * 4);
            make.height.equalTo(@35);
        }];
        [oldPSWTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kMargin * 4);
            make.top.equalTo(oldPswLabel.mas_bottom);
            make.right.equalTo(self.view).offset(-kMargin * 4);
            make.height.equalTo(@35);
        }];
        [newPswLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kMargin * 4);
            make.top.equalTo(oldPSWTextField.mas_bottom).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin * 4);
            make.height.equalTo(@35);
        }];
        [newPSWTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(oldPSWTextField);
            make.top.equalTo(newPswLabel.mas_bottom);
            make.height.equalTo(@35);
        }];
        [retypePswLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kMargin * 4);
            make.top.equalTo(newPSWTextField.mas_bottom).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin * 4);
            make.height.equalTo(@35);
        }];
    }
   
    [retypePSWTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(newPSWTextField);
        make.top.equalTo(retypePswLabel.mas_bottom);
        make.height.equalTo(@35);
    }];
    
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(retypePSWTextField);
        make.top.equalTo(retypePSWTextField.mas_bottom).offset(kMargin * 4);
        make.height.equalTo(@35);
    }];
    
    [invalidPSWLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(retypePSWTextField);
        make.top.equalTo(newPSWTextField.mas_bottom).offset(kMargin);
//        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.height.equalTo(@50);
    }];
    [matchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(retypePSWTextField);
        make.top.equalTo(retypePSWTextField.mas_bottom).offset(2);
        make.height.equalTo(@20);
    }];
}

- (void)tap:(UIGestureRecognizer *)gesture {
    [self.view endEditing:YES];
}

- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle {
    NSMutableAttributedString *myTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *sub = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :[UIColor redColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [myTitle appendAttributedString:sub];
    return myTitle;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]]) {
        return NO;
    } else {
        return YES;
    }
}

@end
