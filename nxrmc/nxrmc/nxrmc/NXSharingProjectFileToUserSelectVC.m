//
//  NXSharingProjectFileToUserSelectVC.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharingProjectFileToUserSelectVC.h"
#import "NXEmailView.h"
#import "NXCommentInputView.h"
#import "NXLocalContactsVC.h"
#import "NXContactInfoTool.h"
#import "NXCommonUtils.h"
#import "Masonry.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "NXMBManager.h"
#import "NXFileBase.h"
#import "NXMessageViewManager.h"

#import "NXRMCUIDef.h"

@interface NXSharingProjectFileToUserSelectVC ()<UIGestureRecognizerDelegate, NXEmailViewDelegate,NXLocalContactsVCDelegate>

@property(nonatomic, weak) UIScrollView *mainView;
@property(nonatomic, weak) UIView *bottomView;
@property(nonatomic, weak) NXEmailView *emailsView;
@property(nonatomic, strong) NXCommentInputView *commentInputView;
@property(nonatomic, assign) CGFloat mainContentHeightOffset;
@property(nonatomic, weak) UIButton *addButton;
@property(nonatomic, strong) NSString *downloadOptIdentify;
@property(nonatomic, strong) NSString *shareOptId;

@end

@implementation NXSharingProjectFileToUserSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back1"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.title = @"User(s)";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIScrollView *mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.scrollEnabled = YES;
    mainScrollView.backgroundColor = [UIColor whiteColor];
    self.mainView = mainScrollView;
    self.mainView.bounces = YES;
    [self.view addSubview:mainScrollView];
    
    UIView *bottomView = [[UIView alloc] init];
    [self.mainView addSubview:bottomView];
    _bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [self.mainView addGestureRecognizer:tap];
        tap.delegate = self;
        [tap addTarget:self action:@selector(tap:)];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
          make.center.equalTo(self.bottomView);
          make.width.equalTo(@250);
          make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
          make.height.lessThanOrEqualTo(@(40));
      }];

  [self.emailsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView.mas_top).offset(kMargin);
            make.left.equalTo(self.mainView).offset(kMargin);
            make.right.equalTo(self.mainView).offset(-kMargin);
        }];
    
    [self.mainView addSubview:self.commentInputView];

    [self.commentInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailsView.mas_bottom).offset(kMargin);
        make.left.and.right.equalTo(self.emailsView);
        make.height.equalTo(@150);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.commentInputView.mas_bottom).offset(kMargin * 2);
          make.left.and.right.equalTo(self.mainView);
          make.height.equalTo(self.view).multipliedBy(0.12);
          make.width.equalTo(self.view);
      }];
    
  
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cancel:(id)sender{
     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    CGFloat height = CGRectGetHeight(self.emailsView.bounds) + CGRectGetHeight(self.commentInputView.bounds);

    CGFloat contentHeight = height + kMargin + self.mainContentHeightOffset;
    
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight);
    }
}

#pragma mark
- (void)tap:(UIGestureRecognizer *)gestuer {
    [self.view endEditing:YES];
}

#pragma mark NXEmailViewDelegate
- (void)emailViewDidBeginEditing:(NXEmailView *)emailView {
}

- (void)emailViewDidEndingEditing:(NXEmailView *)emailView {
}

- (void)emailView:(NXEmailView *)emailView didChangeHeightTo:(CGFloat)height {
    [self viewDidLayoutSubviews];
    [self scrollMainView];
}

- (void)emailView:(NXEmailView *)emailView didInputEmail:(NSString *)email {
}

- (void)emailViewDidReturn:(NXEmailView *)emailView {
}

#pragma mark -UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]] || [touch.view isKindOfClass:[UITextView class]]) {
        return NO;
    } else {
        [self tap:nil];
        return NO;
    }
}

#pragma mark -KeyBoard NSNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = [UIScreen mainScreen].bounds.size.height - keyboardEndFrame.origin.y;
    CGFloat bottomHeight = kMargin;
    if (keyboardHeight - bottomHeight > 0) {
        self.mainContentHeightOffset = keyboardEndFrame.size.height - bottomHeight;
    } else {
        self.mainContentHeightOffset = 0;
    }
    [self viewDidLayoutSubviews];
    [self scrollMainView];
}

#pragma mark -Method
- (void)scrollMainView {
    if (self.mainContentHeightOffset) {
        CGFloat y = self.mainView.contentSize.height - self.mainView.bounds.size.height;
        if ([self.emailsView.textField isFirstResponder]) {
            y = y - self.commentInputView.bounds.size.height;
        }
        [self.mainView setContentOffset:CGPointMake(0, y>0?y:0) animated:YES];
    }
}

- (NXEmailView *)emailsView {
    if (!_emailsView) {
        NXEmailView *emailView = [[NXEmailView alloc] init];
        [self.mainView addSubview:emailView];
        emailView.delegate = self;
        _emailsView = emailView;
        _emailsView.rightBtnClicked = ^{
            NXLocalContactsVC *contactVC = [[NXLocalContactsVC alloc]init];
            contactVC.delegate = self;
            switch ([NXContactInfoTool checkAuthorizationStatus]) {
                case NXContactAuthStatusAlreadyDenied:{
                    NSString *appName = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_SETTING_ACCESS_ADDRESS_BOOK", NULL),appName];
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                                   if (success) {
                                         NSLog(@"Opened url success!");
                                    }
                                }];
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

- (UIButton *)addButton {
    if (!_addButton) {
        UIButton *addButton = [[UIButton alloc] init];
        [self.bottomView addSubview:addButton];
        addButton.enabled = YES;
        [addButton setTitle:@"Add" forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //    [shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
        [addButton cornerRadian:3];
        _addButton = addButton;
        _addButton.accessibilityValue = @"ADD_USER_FOR_RESHARE_BTN";
    }
    return _addButton;
}

- (void)addButtonClicked:(id)sender
{
    self.addButton.enabled = NO;
   //1 check email
    if (self.emailsView.vaildEmails.count == 0) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_NO_VAILD_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        self.addButton.enabled = YES;
        return;
    }
    
    if ([self.emailsView isExistInvalidEmail]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_HAVE_INVALID_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        self.addButton.enabled = YES;
        return;
    }
    
//        NXProjectFile *projectFile = [[NXProjectFile alloc] init];
//           if ([self.currentFile isKindOfClass:[NXProjectFile class]]) {
//               projectFile = (NXProjectFile *)self.currentFile;
//           }
//       NXLRights *rights = [[NXLRights alloc] initWithRightsObs:projectFile.rights obligations:nil];
    
   [NXMBManager showLoading:NSLocalizedString(@"MSG_SHARING", NULL) toView:self.mainView];
      WeakObj(self);
      self.downloadOptIdentify = [[NXLoginUser sharedInstance].nxlOptManager downloadNXLFileAndDecrypted:self.currentFile completion:^(NXFileBase *file,NXLRights *originalNXLFileRights,NSString *duid,NSString *ownerID,NSError *error) {
          StrongObj(self);
          dispatch_async(dispatch_get_main_queue(), ^{
              if (error) {
                  [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                  self.addButton.enabled = YES;
                  return ;
              }
              self.shareOptId = [[NXLoginUser sharedInstance].nxlOptManager shareProjectFile:file recipients:self.emailsView.vaildEmails permissions:originalNXLFileRights comment:self.commentInputView.textView.text originalFile:(NXFile *)self.currentFile originalFileOwnnerID:ownerID originalFileDuid:duid withCompletion:^(NSString *sharedFileName,NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [NXMBManager hideHUDForView:self.mainView];
                      if (error) {
                          [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                          self.addButton.enabled = YES;
                      } else {
                          [self cancel:nil];
                              NSMutableString *alreadyMessage = [[NSMutableString alloc] init];
                              if (alreadySharedArray.count) {
                                  NSString *alreadyShared = [NSString stringWithFormat:NSLocalizedString(@"MSG_SUCCESS_ALREADY_SHARE", NULL), [alreadySharedArray componentsJoinedByString:@" "]];
                                  [alreadyMessage appendString:alreadyShared];
                              }
                              NSString *emails = [newSharedArray componentsJoinedByString:@" "];
                              [NXMessageViewManager showMessageViewWithTitle:sharedFileName?sharedFileName:self.currentFile.name details:emails.length?NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL):nil appendInfo:emails.length?emails:nil appendInfo2:alreadyMessage image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                      }
                  });
              }];
          });
      }];
      
    //    NXProjectFile *projectFile = [[NXProjectFile alloc] init];
    //    if ([self.currentFile isKindOfClass:[NXProjectFile class]]) {
    //        projectFile = (NXProjectFile *)self.currentFile;
    //    }
    //
    //    NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForFile: projectFile];
    
//    [[NXLoginUser sharedInstance].nxlOptManager shareProjectFile:self.currentFile fromPorject:projectModel toRecipinets:self.emailsView.vaildEmails comment:self.commentInputView.textView.text withCompletion:^(NSString *sharedFileName, NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
////        if (!error) {
////               self.addButton.enabled = YES;
////        }else{
////               self.addButton.enabled = YES;
////        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//             [NXMBManager hideHUDForView:self.mainView];
//             if (error) {
//                 [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
//                 self.addButton.enabled = YES;
//             } else {
////                 if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
////                     [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:self.fileItem];
////                 }
//                 [self cancel:nil];
//
////                 if (self.isNXL) {
////                     NSMutableString *alreadyMessage = [[NSMutableString alloc] init];
////                     if (alreadySharedArray.count) {
////                         NSString *alreadyShared = [NSString stringWithFormat:NSLocalizedString(@"MSG_SUCCESS_ALREADY_SHARE", NULL), [alreadySharedArray componentsJoinedByString:@" "]];
////                         [alreadyMessage appendString:alreadyShared];
////                     }
////                     NSString *emails = [newSharedArray componentsJoinedByString:@" "];
////                     [NXMessageViewManager showMessageViewWithTitle:sharedFileName?sharedFileName:self.currentFile.name details:emails.length?NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL):nil appendInfo:emails.length?emails:nil appendInfo2:alreadyMessage image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
////
////                 } else {
//                     NSString *email = [self.emailsView.vaildEmails componentsJoinedByString:@" "];
//                     [NXMessageViewManager showMessageViewWithTitle:self.currentFile.name details:NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL) appendInfo:email appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_MYVAULT", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
////                 }
//             }
//         });
//    }];
}

- (void)updateSubViews {
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}

#pragma -mark NXLocalContactsVCDelegate

- (void)selectedEmail:(NSString *)emailStr {
    [self.emailsView addAEmail:emailStr];
}

- (void)cancelSelctedEmail{
}

@end
