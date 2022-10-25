//
//  NXVaultAddPeopleVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXVaultAddPeopleVC.h"

#import "NXEmailView.h"
#import "NXCommentInputView.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXMBManager.h"
#import "UIImage+ColorToImage.h"

#import "NXLoginUser.h"
#import "NXMyVaultFile.h"
#import "NXCommonUtils.h"
#import "NXLocalContactsVC.h"
#import "NXContactInfoTool.h"
@interface NXVaultAddPeopleVC ()<UIGestureRecognizerDelegate, NXEmailViewDelegate,NXLocalContactsVCDelegate>

//@property(nonatomic, strong)UIView *topView;

@property(nonatomic, weak) NXEmailView *emailsView;
@property(nonatomic, strong) NXCommentInputView *commentInputView;
@property(nonatomic, weak) UIButton *shareButton;

@property(nonatomic, assign) CGFloat mainContentHeightOffset;

@end

@implementation NXVaultAddPeopleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name: UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = CGRectGetHeight(self.emailsView.bounds) + kMargin + CGRectGetHeight(self.commentInputView.bounds);
    
    CGFloat contentHeight = height + kMargin + _mainContentHeightOffset;
    
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        //kMargin * 4 should be researched. for now just a demo
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight);
    }
}
#pragma mark
- (void)tap:(id)sender {
    [self.view endEditing:YES];
}

- (void)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareButtonClicked:(id)sender {
    self.shareButton.enabled = NO;
    //1 check email
    if (self.emailsView.vaildEmails.count == 0) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_NO_VAILD_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        self.shareButton.enabled = YES;
        return;
    }
    
    if ([self.emailsView isExistInvalidEmail]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_HAVE_INVALID_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        self.shareButton.enabled = YES;
        return;
    }
    
    NXMyVaultFile *myVaultFile = (NXMyVaultFile *)self.fileItem;
    if ([NXCommonUtils checkNXLFileisExpired:myVaultFile.validateFileModel]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_VALIDITY_EXPIRED", NULL) hideAnimated:YES afterDelay:kDelay];
        self.shareButton.enabled = YES;
        return;
    }
    
    NSArray *newRecipients = self.emailsView.vaildEmails;
    WeakObj(self);
    [NXMBManager showLoadingToView:self.mainView];
    [[NXLoginUser sharedInstance].nxlOptManager updateSharedFileRecipients:self.fileItem newRecipients:newRecipients removedRecipients:@[] comment:self.commentInputView.textView.text withCompletion:^(NSArray *newRecipients, NSArray *removedRecipients, NSError *error) {
        StrongObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.mainView];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?error.localizedDescription:NSLocalizedString(@"MSG_UPDATE_RECIPIENTS_FAILED", nil) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                self.shareButton.enabled = YES;
            }else{
                NSMutableString *message = [[NSMutableString alloc] init];
                if (newRecipients.count) {
                    NSString *sharedMessage = [NSString stringWithFormat:NSLocalizedString(@"MSG_UPDATE_ADD_SUCCESS", NULL), [newRecipients componentsJoinedByString:@" "]];
                    [message appendString:sharedMessage];
                }
                if (removedRecipients.count) {
                    NSString *revokedMessage = [NSString stringWithFormat:NSLocalizedString(@"MSG_UPDATE_REMOVE_SUCCESS", NULL), [removedRecipients componentsJoinedByString:@" "]];
                    [message appendString:revokedMessage];
                }
                if (message.length) {
                    [NXMBManager showMessage:message toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                } else {
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_UPDATE_RECIPIENT_SUCCESS", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                }
                
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                    [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:nil];
                }
                [self performSelector:@selector(backClicked:) withObject:nil afterDelay:(kDelay + 0.5)];
            }
        });
    }];
}

#pragma mark - NSNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = [UIScreen mainScreen].bounds.size.height - keyboardEndFrame.origin.y;
    CGFloat bottomHeight = self.bottomView.bounds.size.height;
    if (keyboardHeight - bottomHeight > 0) {
        self.mainContentHeightOffset = keyboardEndFrame.size.height - bottomHeight;
    } else {
        self.mainContentHeightOffset = 0;
    }
    [self viewDidLayoutSubviews];
    
    [self scrollMainView];
}


#pragma mark - NXEmailViewDelegate
- (void)emailView:(NXEmailView *)emailView didInputEmail:(NSString *)email {
    //
}

- (void)emailViewDidBeginEditing:(NXEmailView *)emailView {
    
}

- (void)emailViewDidEndingEditing:(NXEmailView *)emailView {
    
}

- (void)emailView:(NXEmailView *)emailView didChangeHeightTo:(CGFloat)height {
    [self viewDidLayoutSubviews];
    [self scrollMainView];
}

- (void)emailViewDidReturn:(NXEmailView *)emailView {
    //for return textview will have one "\n" character, can not fixed yet.
//    if (self.commentInputView.bounds.size.height) {
//        [self.commentInputView.textView becomeFirstResponder];
//    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]] || [touch isKindOfClass:[UITextView class]]) {
        return NO;
    } else {
        [self tap:nil];
        return NO;
    }
}
#pragma mark
- (void)scrollMainView {
    if (self.mainContentHeightOffset) {
        CGFloat y = self.mainView.contentSize.height - self.mainView.bounds.size.height;
        if ([self.emailsView.textField isFirstResponder]) {
            y = y - self.commentInputView.bounds.size.height;
        }
        [self.mainView setContentOffset:CGPointMake(0, y>0?y:0) animated:YES];
    }
}


#pragma mark
- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topView.model = self.fileItem;
    WeakObj(self);
    self.topView.backClickAction = ^(id sender) {
        StrongObj(self);
        [self backClicked:nil];
    };
    
    [self.emailsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView).offset(kMargin);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
    
    [self.mainView addSubview:self.commentInputView];
    [self.commentInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailsView.mas_bottom).offset(kMargin);
        make.left.and.right.equalTo(self.emailsView);
        make.height.equalTo(@150);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(self.shareButton.mas_height).multipliedBy(4);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.mainView addGestureRecognizer:tap];
    tap.delegate = self;
    [tap addTarget:self action:@selector(tap:)];
}

- (NXEmailView *)emailsView {
    if (!_emailsView) {
        NXEmailView *emailView = [[NXEmailView alloc] init];
        [self.mainView addSubview:emailView];
        emailView.delegate = self;
        emailView.promptMessage = NSLocalizedString(@"UI_SHARE_WITH_MORE_PEOPLE", NULL);
        emailView.rightBtnClicked = ^{
            NXLocalContactsVC *contactVC = [[NXLocalContactsVC alloc]init];
            contactVC.delegate = self;
            switch ([NXContactInfoTool checkAuthorizationStatus]) {
                case NXContactAuthStatusAlreadyDenied:{
                    NSString *appName = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_SETTING_ACCESS_ADDRESS_BOOK", NULL),appName];
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                            }
                        });
                        
                    } cancelActionHandle:nil inViewController:self position:self.view];
                }
                    break;
                case NXContactAuthStatusAlreadyAuthorized:{
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:contactVC];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }
                    break;
                case NXContactAuthStatusNotDetermined:
                    [NXContactInfoTool requestAccessEntityWithCompletion:^(BOOL granted, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (granted) {
                                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:contactVC];
                                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                                [self.navigationController presentViewController:nav animated:YES completion:nil];
                            }else{
                                
                            }
                        });
                    }];
                    break;
            }
        };
        _emailsView = emailView;
    }
    return _emailsView;
}

- (NXCommentInputView *)commentInputView {
    if (!_commentInputView) {
        NXCommentInputView *commentInputView = [[NXCommentInputView alloc] init];
        _commentInputView = commentInputView;
    }
    return _commentInputView;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        UIButton *shareButton = [[UIButton alloc] init];
        [self.bottomView addSubview:shareButton];
        
        [shareButton setTitle:NSLocalizedString(@"UI_COM_SHARE", NULL) forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
        [shareButton cornerRadian:3];
        shareButton.enabled = YES;
        _shareButton = shareButton;
    }
    return _shareButton;
}
#pragma mark -----> localContactVC delegate
-(void)selectedEmail:(NSString *)emailStr {
    [self.emailsView addAEmail:emailStr];
}
@end
