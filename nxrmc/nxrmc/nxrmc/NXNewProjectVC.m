//
//  NXNewProjectVC.m
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXNewProjectVC.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "UIImage+ColorToImage.h"
#import "NXEmailView.h"
#import "NXMBManager.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXProjectTabBarController.h"
#import "NXCommentInputView.h"
#import "NXContactInfoTool.h"
#import "NXLocalContactsVC.h"
#define NXBarButtonBlueColor  [UIColor colorWithRed:39/256.0 green:123/256.0 blue:236/256.0 alpha:1]
#define NXNameInputViewTag 20170905
@interface NXNewProjectVC ()<NXEmailViewDelegate, UIGestureRecognizerDelegate,UITextFieldDelegate,UITextViewDelegate,NXLocalContactsVCDelegate>
@property(nonatomic, strong) UIButton *createProjectButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIScrollView *contentScrollView;
@property(nonatomic, strong) NXEmailView *emailsView;
@property(nonatomic, strong) NXCommentInputView *projectNameView;
@property(nonatomic, strong) NXCommentInputView *descriptionView;
@property(nonatomic, strong) NXCommentInputView *invitationMsgView;
@property(nonatomic, assign) CGFloat contentScrollViewOriginalContentHeight;
@property(nonatomic, assign) BOOL isEmailViewEdit;
@property(nonatomic, assign) BOOL isNameTFEdit;
@property(nonatomic, strong) UIButton *createButton;
@property(nonatomic, strong) UIView *navigatonView;
@property(nonatomic, assign) CGFloat emailViewHeight;
@property(nonatomic, strong) NXProjectModel *createdProjectModel;
@property(nonatomic, strong) UILabel *warnLabel;
@property(nonatomic, strong) UILabel *descriptionWarnLabel;
@end

@implementation NXNewProjectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name: UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
- (void)closeButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
- (UIView *)navigatonView {
    if (!_navigatonView) {
        _navigatonView = [[UIView alloc]init];
        [self.view addSubview:_navigatonView];
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [_navigatonView addSubview:leftBtn];
        UILabel *connectLabel = [[UILabel alloc]init];
        connectLabel.text = NSLocalizedString(@"UI_NEW_PROJECT", NULL);
        connectLabel.font =[UIFont systemFontOfSize:15];
        connectLabel.textAlignment = NSTextAlignmentCenter;
        [_navigatonView addSubview:connectLabel];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:NSLocalizedString(@"UI_PROJECT_CREATE", NULL) forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        rightBtn.enabled = NO;
        [rightBtn addTarget:self action:@selector(createProjectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.createButton = rightBtn;
        [_navigatonView addSubview:rightBtn];
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_navigatonView addSubview:lineView];

        if (IS_IPHONE_X) {
            if (@available(iOS 11.0, *)) {
                [_navigatonView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                    make.left.right.equalTo(self.view);
                    make.height.equalTo(@44);
                }];
                [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_navigatonView);
                    make.left.equalTo(_navigatonView).offset(15);
                    make.width.equalTo(@40);
                    make.height.equalTo(@40);
                }];
            }
        } else {
            [_navigatonView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.right.equalTo(self.view);
                make.height.equalTo(@64);
            }];
            [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_navigatonView).offset(20);
                make.left.equalTo(_navigatonView).offset(10);
                make.width.equalTo(@40);
                make.height.equalTo(@40);
            }];
        }

        [connectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(leftBtn);
            make.centerX.equalTo(_navigatonView);
            make.width.equalTo(@100);
        }];
        [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(connectLabel);
            make.width.equalTo(@60);
            make.right.equalTo(_navigatonView.mas_right).offset(-10);
        }];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_navigatonView);
            make.height.equalTo(@0.6);
        }];
    }
    return  _navigatonView;
}

#pragma mark
- (void)commonInit {
    self.navigatonView.backgroundColor = [UIColor whiteColor];
    self.contentScrollView = [[UIScrollView alloc] init];
    self.contentScrollView.backgroundColor = [UIColor whiteColor];
    self.contentScrollView.contentSize = CGSizeMake(0,600);
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contentScrollView];
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigatonView.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    NXCommentInputView *projectNameView = [[NXCommentInputView alloc]init];
    projectNameView.textView.accessibilityValue = @"PROJECT_NAME_TEXT_VIEW";
    [self.contentScrollView addSubview:projectNameView];
    self.projectNameView = projectNameView;
    projectNameView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_NAME_OF_THE_PROJECT", NULL)  subTitle:@"*" subTitleColor:[UIColor redColor]];
    projectNameView.maxCharacters = 50;
    projectNameView.textView.placeholder = @"Specify a name of the project";
    projectNameView.delegate = self;
    projectNameView.tag = NXNameInputViewTag;
    
    [projectNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(self.contentScrollView.mas_top);
        make.height.equalTo(@110);
    }];
    
    UILabel *warnLabel = [[UILabel alloc] init];
    warnLabel.text = NSLocalizedString(@"UI_COM_TEXTFIELD_REQUEST_WARNING", nil);
    [warnLabel setFont:[UIFont systemFontOfSize:11.0]];
    [warnLabel setTextColor:[UIColor lightGrayColor]];
    warnLabel.numberOfLines = 0;
    self.warnLabel = warnLabel;
    [self.contentScrollView addSubview:warnLabel];

    [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.top.equalTo(projectNameView.mas_bottom);
        make.height.equalTo(@30);
    }];

    
    NXCommentInputView *descriptionView = [[NXCommentInputView alloc]init];
    descriptionView.textView.accessibilityValue = @"PROJECT_DESCRIPTION_TEXT_VIEW";
    [self.contentScrollView addSubview:descriptionView];
    self.descriptionView = descriptionView;
    descriptionView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_DRSCRIPTION", NULL) subTitle:@"*" subTitleColor:[UIColor redColor]];
    descriptionView.maxCharacters = 250;
    descriptionView.delegate = self;
    descriptionView.textView.placeholder = @"Give a brief description about the project";

    [descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(warnLabel.mas_bottom);
        make.height.equalTo(@150);
    }];

    UILabel *inviteUserLabel = [[UILabel alloc] init];
    //inviteUserLabel.text = NSLocalizedString(@"UI_INVITE_USER_TO_PROJECT", nil);
    inviteUserLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_INVITE_USER_TO_PROJECT", NULL) subTitle:NSLocalizedString(@"UI_INVITATION_OPTIONAL", NULL) subTitleColor:[UIColor grayColor]];
    [self.contentScrollView addSubview:inviteUserLabel];
    [inviteUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(descriptionView.mas_bottom);
        make.height.equalTo(@30);
    }];
    
    NXEmailView *emailView = [[NXEmailView alloc] initWithFrame:CGRectZero];
    emailView.promptMessage = @"";
    [self.contentScrollView addSubview:emailView];
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
    [emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inviteUserLabel.mas_bottom);
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
    }];

    
    self.emailsView = emailView;
    self.emailsView.delegate = self;
    
    UILabel *inviteUserRemarkLabel = [[UILabel alloc] init];
    inviteUserRemarkLabel.text = NSLocalizedString(@"UI_SKIP_INVITE_PEOPLE", nil);
    [inviteUserRemarkLabel setFont:[UIFont systemFontOfSize:10.0]];
    [inviteUserRemarkLabel setTextColor:[UIColor lightGrayColor]];
    [self.contentScrollView addSubview:inviteUserRemarkLabel];

    [inviteUserRemarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(emailView.mas_bottom);
        make.height.equalTo(@30);
    }];

    NXCommentInputView *inputView = [[NXCommentInputView alloc]init];
    inputView.textView.accessibilityValue = @"PROJECT_INVITATION_MESSAGE_TEXT_VIEW";
    [self.contentScrollView addSubview:inputView];
    self.invitationMsgView = inputView;
    inputView.maxCharacters = 250;
    inputView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_INVITATION_MSG", NULL) subTitle:NSLocalizedString(@"UI_INVITATION_OPTIONAL", NULL) subTitleColor:[UIColor grayColor]];
    inputView.textView.placeholder = @"Add message here";

    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(inviteUserRemarkLabel.mas_bottom);
        make.height.equalTo(@150);
    }];

    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [projectNameView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
                make.top.equalTo(self.contentScrollView.mas_top);
                make.height.equalTo(@110);
            }];
            
            [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-20);
                make.top.equalTo(projectNameView.mas_bottom);
                make.height.equalTo(@30);
            }];
            
            [descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
                make.top.equalTo(warnLabel.mas_bottom);
                make.height.equalTo(@150);
            }];
            
            [inviteUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
                make.top.equalTo(descriptionView.mas_bottom);
                make.height.equalTo(@30);
            }];
            
            [emailView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(inviteUserLabel.mas_bottom);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
            }];
            
            [inviteUserRemarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
                make.top.equalTo(emailView.mas_bottom);
                make.height.equalTo(@30);
            }];
            
            [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
                make.top.equalTo(inviteUserRemarkLabel.mas_bottom);
                make.height.equalTo(@150);
            }];
        }
    }
    else
    {
        [projectNameView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
            make.top.equalTo(self.contentScrollView.mas_top);
            make.height.equalTo(@110);
        }];
        
        [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-20);
            make.top.equalTo(projectNameView.mas_bottom);
            make.height.equalTo(@30);
        }];
        
        [descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
            make.top.equalTo(warnLabel.mas_bottom);
            make.height.equalTo(@150);
        }];
        
        [inviteUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
            make.top.equalTo(descriptionView.mas_bottom);
            make.height.equalTo(@30);
        }];
        
        [emailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(inviteUserLabel.mas_bottom);
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
        }];
        
        [inviteUserRemarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
            make.top.equalTo(emailView.mas_bottom);
            make.height.equalTo(@30);
        }];
        
        [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
            make.top.equalTo(inviteUserRemarkLabel.mas_bottom);
            make.height.equalTo(@150);
        }];
    }

    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollViewOriginalContentHeight = self.contentScrollView.contentSize.height;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.contentScrollView addGestureRecognizer:tap];
    tap.delegate = self;
    [tap addTarget:self action:@selector(tap:)];
}

#pragma mark - response to UI action
- (void)cancelButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createProjectButtonClicked:(UIButton *)button
{
    [self tap:nil];
    NSString *displayName = self.projectNameView.textView.text;
    displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([displayName isEqualToString:@""])
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_PLESASE_INPUT_NAME", nil) toView:self.view hideAnimated:YES afterDelay:1.5];
        [self.projectNameView.textView becomeFirstResponder];
        return;
    }else if(displayName.length>50)
    {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_NAME_LENGTH_LONG_WARNING",NULL) toView:self.view hideAnimated:YES afterDelay:1.5];
        [self.projectNameView.textView becomeFirstResponder];
        return;
    }else if ([NXCommonUtils JudgeTheillegalCharacter:displayName withRegexExpression:@"^[\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\w \\x22\\x23\\x27\\x2C\\x2D]+$"]) {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_CONTAIN_SPECIAL_WARNING", NULL) toView:self.view hideAnimated:YES afterDelay:1.5];
        return;
    }
    NSString *displayDescription = self.descriptionView.textView.text;
    displayDescription = [displayDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([displayDescription isEqualToString:@""])
    {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_INPUT_DESSCRIPTION", nil) toView:self.view hideAnimated:YES afterDelay:1.5];
        [self.descriptionView.textView becomeFirstResponder];
        return;
    }else if (displayDescription.length>250) {
        [NXMBManager showMessage:NSLocalizedString(@"UI_DESCRIPTION_LONG_WARNING", nil) toView:self.view hideAnimated:YES afterDelay:1.5];
        return;
    }
    if ([self.emailsView isExistInvalidEmail]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_HAVE_INVALID_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        return;
    }
    NXProjectModel *projectModel = [[NXProjectModel alloc] init];
    projectModel.displayName = displayName;
    projectModel.projectDescription = displayDescription;
    [NXMBManager showLoadingToView:self.view];
    WeakObj(self);
    
    NSString *invitationMsg = [self.invitationMsgView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (invitationMsg.length == 0) {
        invitationMsg = nil;
    }
    [[NXLoginUser sharedInstance].myProject createProject:projectModel invitedEmails:self.emailsView.vaildEmails invitationMsg:invitationMsg withCompletion:^(NXProjectModel *project, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.view];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
            }else {
//                [NXMBManager showMessage:NSLocalizedString(@"MSG_CREATE_PROJECT_SUCCESS", nil) hideAnimated:YES afterDelay:kDelay];
//                [self performSelector:@selector(dismissself) withObject:nil afterDelay:kDelay + 0.5];
                self.createdProjectModel = project;
                [self dismissself];
            }
            
        });
    }];
}

- (void)dismissself
{
    if ([self.tabBarController isKindOfClass:[NXProjectTabBarController class]]) {
        NXProjectTabBarController *tabbar = [[NXProjectTabBarController alloc]initWithProject:self.createdProjectModel];
        tabbar.preTabBarController = ((NXProjectTabBarController *)self.tabBarController).preTabBarController;
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.tabBarController.navigationController.viewControllers];
        [viewControllers removeLastObject];
        [viewControllers addObject:tabbar];
        [self.tabBarController.navigationController setViewControllers:viewControllers];
        tabbar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
    }
    
    if ([self.tabBarController isKindOfClass:[NXMasterTabBarViewController class]]) {
        NXProjectTabBarController *projectTabBar = [[NXProjectTabBarController alloc] initWithProject:self.createdProjectModel];
        projectTabBar.preTabBarController = (NXMasterTabBarViewController *)self.tabBarController;
        [self.tabBarController.navigationController pushViewController:projectTabBar animated:YES];
        projectTabBar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
    }

    [self.navigationController popViewControllerAnimated:NO];
    
    
}
#pragma mark - NXEmailViewDelegate
- (void)emailViewDidBeginEditing:(NXEmailView *)emailView
{
    self.isEmailViewEdit = YES;
}
- (void)emailViewDidEndingEditing:(NXEmailView *)emailView
{
    self.isEmailViewEdit = NO;
}
- (void)emailView:(NXEmailView *)emailView didChangeHeightTo:(CGFloat)height
{
    static CGFloat currentHeight = 0;
    [self viewDidLayoutSubviews];
    CGFloat changeHeight = height - currentHeight;
    _emailViewHeight = height;
    currentHeight = height;
    UIInterfaceOrientation sataus = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(sataus)) {
         self.contentScrollView.contentSize = CGSizeMake(0, self.view.frame.size.height*1.5 + _emailViewHeight);
    }
    else
    {
         self.contentScrollView.contentSize = CGSizeMake(0, self.view.frame.size.height + _emailViewHeight);
    }
    
    if (height == 0 || height == 32) {
        return;
    }
    [self.contentScrollView setContentOffset:CGPointMake(0, self.contentScrollView.contentOffset.y+changeHeight *1.3) animated:YES];

}

#pragma mark - NSNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
//    CGFloat keyboardAnimationDurationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
////    if (keyboardAnimationDurationTime <= 0) {
////        self.contentScrollView.contentOffset = CGPointMake(0,0);
////        return;
////    }
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat change = keyboardEndFrame.origin.y - keyboardBeginFrame.origin.y;
    
    CGFloat offestY;
    UIInterfaceOrientation sataus = [UIApplication sharedApplication].statusBarOrientation;
    if (self.isEmailViewEdit) {
        if (sataus == UIDeviceOrientationPortrait || sataus == UIDeviceOrientationPortraitUpsideDown) {
            if ([NXCommonUtils isiPad]) {
                return;
            }
            offestY = change/1.3;
        }else {
            offestY = change;
            if ([NXCommonUtils isiPad]) {
                offestY = change/3;
            }
        }
        self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
    }else if (self.projectNameView.textView.isFirstResponder) {
        
    }else if (self.descriptionView.textView.isFirstResponder) {
        if ([NXCommonUtils isiPad]) {
            return;
        }
        if (sataus == UIDeviceOrientationLandscapeLeft || sataus == UIDeviceOrientationLandscapeRight) {
            offestY = change/1.5;
            self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
        }else {
            offestY = change/4;
            self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
        }
    }
    else {
        if ([NXCommonUtils isiPad]) {
            if (sataus == UIDeviceOrientationLandscapeLeft || sataus == UIDeviceOrientationLandscapeRight) {
                offestY = change/2.2;
                self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
            }
            return;
        }
        if (sataus == UIDeviceOrientationLandscapeLeft || sataus == UIDeviceOrientationLandscapeRight) {
            offestY = change;
            self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
        }else {
            offestY = change/1.5;
            if ([[UIScreen mainScreen] bounds].size.width<414.0) {
                offestY = change;
            }
            self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
        }
    }

}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]] || [touch.view isKindOfClass:[NXEmailView class]]) {
        return NO;
    } else {
        [self tap:nil];
        return NO;
    }
}
- (void)tap:(UIGestureRecognizer *)gestuer {
    [self.view endEditing:YES];
}

- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle subTitleColor:(UIColor *)color {
    NSMutableAttributedString *myTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *sub = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :color, NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [myTitle appendAttributedString:sub];
    return myTitle;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ---- NXCommentInputViewDelegate
- (void)commentInputViewDidEndEditing:(NXCommentInputView *)inputView {
    if (self.projectNameView.textView.text.length > 0 && self.descriptionView.textView.text.length > 0) {
        [self.createButton setTitleColor:NXBarButtonBlueColor forState:UIControlStateNormal];
        self.createButton.enabled = YES;
    } else {
        [self.createButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.createButton.enabled = NO;
    }
}
- (void)commentInputView:(NXCommentInputView *)inputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.projectNameView.textView.text.length > 0 && self.descriptionView.textView.text.length > 0 ) {
        [self.createButton setTitleColor:NXBarButtonBlueColor forState:UIControlStateNormal];
        self.createButton.enabled = YES;
    } else if (text.length < 1) {
        [self.createButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.createButton.enabled = NO;
    }
    if (inputView.tag == NXNameInputViewTag) {
        if (text.length > 0 && [NXCommonUtils JudgeTheillegalCharacter:text withRegexExpression:@"^[\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\w \\x22\\x23\\x27\\x2C\\x2D]+$"]) {
            self.warnLabel.textColor = [UIColor redColor];
        }else {
            self.warnLabel.textColor = [UIColor lightGrayColor];
        }
    }
}

#pragma -Mark deviceOrientationWillChangeNotification
- (void)deviceOrientationWillChange:(NSNotification *)notification
{
//    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    
//    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
//         self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.5 +_emailViewHeight);
//    }
//    else
//    {
//        self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//    }
}

#pragma mark ----> lcoalContactVC delegate
- (void)selectedEmail:(NSString *)emailStr {
    [self.emailsView addAEmail:emailStr];
}
@end
