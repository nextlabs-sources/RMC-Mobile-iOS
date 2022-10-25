//
//  NXProjectInviteMemberView.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 08/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectInviteMemberView.h"
#import "NXDefine.h"
#import "Masonry.h"
#import "UIView+NXExtension.h"
#import "NXCommentInputView.h"
#import "NXRMCDef.h"
#pragma mark - NXAlertWindow
@interface NXCustomAlertWindow ()

@end


@implementation NXCustomAlertWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.windowLevel = 1999.0;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.66] set];
    CGContextFillRect(context, self.bounds);
}

@end

#pragma mark - NXAlertWindow rootViewController

@interface NXCustomAlertWindowRootViewController ()
@end

@implementation NXCustomAlertWindowRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@interface NXProjectInviteMemberView()

@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *declineButton;
@property (nonatomic,strong) UIView *containerView;

@property (nonatomic,strong) NXCustomAlertWindow *alertWindow;
@property (nonatomic, strong) NXCustomAlertWindowRootViewController *rooVC;

@property (nonatomic,assign) BOOL keyBoardIsShow;

@property (nonatomic,assign) CGFloat keyboardHeight;

@end

@implementation NXProjectInviteMemberView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        _rooVC = [[NXCustomAlertWindowRootViewController alloc] init];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTheKeyBoard)];
        [self addGestureRecognizer:tapGesture];
        
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title inviteHander:(onInviteClickHandle)hander;
{
    _title = title;
    _onInviteClickHandle = hander;
    return [self init];
}

#pragma -Mark Configure UI

- (UIView *)createContainerView
{
    if (!_containerView){
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    
    return _containerView;
}


-(NXEmailView *)emailView
{
    if (!_emailView) {
        NXEmailView *emailView = [[NXEmailView alloc] init];
        emailView.backgroundColor = [UIColor whiteColor];
        _emailView = emailView;
        _emailView.textField.accessibilityValue = @"INVITATE_MEMBER_EMAIL_ADDRESS"; 
    }
    return _emailView;
}

/**
 *  init alertWindow
 */
- (NXCustomAlertWindow *)alertWindow {
    if (!_alertWindow) {
        _alertWindow = [[NXCustomAlertWindow alloc] initWithFrame:NXMainScreenBounds];
        _alertWindow.alpha = 1.0;
        _alertWindow.rootViewController = _rooVC;
    }
    
    return _alertWindow;
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
- (void)tempDismiss {
    self.alertWindow.hidden = YES;
//    self.alertWindow.alpha = 0;
//    [self.alertWindow removeFromSuperview];
//    self.alertWindow.rootViewController = nil;
//    self.alertWindow = nil;
    [NXFirstWindow makeKeyAndVisible];
}
- (void)onClickInviteButton:(id)sender
{
    if (_onInviteClickHandle) {
        self.onInviteClickHandle(self);
    }
}

- (void)dismiss
{
    [self onClickCrossButton:nil];
}
- (void)tempShow{
    self.alertWindow.hidden = NO;
}
- (void)show
{
    // create containerView
    _containerView = [self createContainerView];
    _containerView.layer.shouldRasterize = YES;
    _containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIButton *crossButton = [[UIButton alloc] init];
    crossButton.backgroundColor = [UIColor clearColor];
    crossButton.contentMode =  UIViewContentModeBottom;
    [crossButton setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    [crossButton addTarget:self action:@selector(onClickCrossButton:) forControlEvents:UIControlEventTouchUpInside];
    crossButton.imageEdgeInsets = UIEdgeInsetsMake(2,0, 0, 0);
    crossButton.accessibilityValue = @"INVITE_MEMBERS_CANCEL";
    //[crossButton setBackgroundColor:[UIColor yellowColor]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.text =  NSLocalizedString(@"UI_COM_INVITE_MEMBERS", NULL);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:NSLocalizedString(@"UI_COM_INVITE", NULL) forState:UIControlStateNormal];
    inviteButton.contentMode = UIViewContentModeLeft;
    [inviteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    inviteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [inviteButton addTarget:self action:@selector(onClickInviteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [headView addSubview:crossButton];
    [headView addSubview:titleLabel];
    [headView addSubview:inviteButton];
    [_containerView addSubview:headView];
    [_containerView addSubview:self.emailView];
    NXCommentInputView *inputView = [[NXCommentInputView alloc]init];
    inputView.maxCharacters = 250;
    inputView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_INVITATION_MSG", NULL) subTitle:NSLocalizedString(@"UI_INVITATION_OPTIONAL", NULL) subTitleColor:[UIColor grayColor]];
    inputView.backgroundColor = [UIColor whiteColor];
       [_containerView addSubview:inputView];
    self.invitationView = inputView;
    if (_title.length > 0) {
        inputView.textView.text = _title;
    }
    inputView.textView.accessibilityValue = @"INVITATION_MESSAGE_INPUT_VIEW";
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:_containerView];
    
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
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@300);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView);
        make.trailing.equalTo(self.containerView);
        make.width.equalTo(self.containerView);
        make.top.equalTo(self.containerView);
        make.height.equalTo(@50);
    }];
    
    [crossButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headView).offset(5);
        make.width.equalTo(@42);
        make.height.equalTo(@42);
        make.bottom.equalTo(headView);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headView).offset(-5);
        make.height.equalTo(@30);
        make.leading.equalTo(headView).offset(58);
        make.trailing.equalTo(headView).offset(-55);
    }];
    
    [inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headView).offset(-5);
        make.height.equalTo(@30);
        make.width.equalTo(@55);
        make.right.equalTo(headView).offset(-10);
    }];
    
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(20);
        make.right.equalTo(self.containerView).offset(-20);
        make.height.equalTo(@120);
        make.top.equalTo(self.containerView).offset(50);
    }];
    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.emailView);
        make.right.equalTo(self.emailView);
        make.top.equalTo(self.emailView.mas_bottom);
        make.height.equalTo(@130);
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

#pragma -mark Keyboard Event

- (void)keyboardWillShow: (NSNotification *)notification
{
    _keyBoardIsShow  = YES;
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    _keyboardHeight = keyboardSize.height;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (IS_IPAD) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@300);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-(keyboardSize.height/2));
        }];
        return;
    }
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        if (self.emailView.textField.isFirstResponder) {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@280);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).offset(-(keyboardSize.height/2));
            }];
        }else {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@280);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-(keyboardSize.height/1.1));
            }];
        }
            [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(20);
            make.right.equalTo(self.containerView).offset(-20);
            make.height.equalTo(@100);
            make.top.equalTo(self.containerView).offset(50);
            }];
    }
    else
    {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@300);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-(keyboardSize.height/2));
        }];
        
        [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(20);
            make.right.equalTo(self.containerView).offset(-20);
            make.height.equalTo(@120);
            make.top.equalTo(self.containerView).offset(50);
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
            make.height.equalTo(@280);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(20);
            make.right.equalTo(self.containerView).offset(-20);
            make.height.equalTo(@100);
            make.top.equalTo(self.containerView).offset(50);
        }];
    }
    else
    {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@300);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(20);
            make.right.equalTo(self.containerView).offset(-20);
            make.height.equalTo(@120);
            make.top.equalTo(self.containerView).offset(50);
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
                make.height.equalTo(@280);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).offset(-(_keyboardHeight/2));
            }];
            
            [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).offset(20);
                make.right.equalTo(self.containerView).offset(-20);
                make.height.equalTo(@100);
                make.top.equalTo(self.containerView).offset(50);
            }];
        }
        else
        {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@280);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self);
            }];
            
            [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).offset(20);
                make.right.equalTo(self.containerView).offset(-20);
                make.height.equalTo(@100);
                make.top.equalTo(self.containerView).offset(50);
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
                make.height.equalTo(@300);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).offset(-(_keyboardHeight/2));
            }];
            
            [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).offset(20);
                make.right.equalTo(self.containerView).offset(-20);
                make.height.equalTo(@120);
                make.top.equalTo(self.containerView).offset(50);
            }];

        }
        else
        {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self);
                make.trailing.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(@300);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self);
            }];
            
            [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView).offset(20);
                make.right.equalTo(self.containerView).offset(-20);
                make.height.equalTo(@120);
                make.top.equalTo(self.containerView).offset(50);
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
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
