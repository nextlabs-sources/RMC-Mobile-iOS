//
//  NXUpdateProjectInfoVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 22/8/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXUpdateProjectInfoVC.h"
#import "Masonry.h"
#import "NXCommentInputView.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
#import "NXProjectTabBarController.h"

#define NXBarButtonBlueColor  [UIColor colorWithRed:39/256.0 green:123/256.0 blue:236/256.0 alpha:1]
#define NXNameInputViewTag 201709051
@interface NXUpdateProjectInfoVC ()<UIGestureRecognizerDelegate,UITextViewDelegate,NXCommnetInputViewDelegate>
@property(nonatomic, strong) UIView *navigatonView;
@property(nonatomic, strong) UIButton *saveButton;
@property(nonatomic, strong) UIScrollView *contentScrollView;
@property(nonatomic, strong) UILabel *warnLabel;
@property(nonatomic, strong) UILabel *descriptionWarnLabel;
@property(nonatomic, strong) NXCommentInputView *projectNameView;
@property(nonatomic, strong) NXCommentInputView *descriptionView;
@property(nonatomic, strong) NXCommentInputView *invitationMsgView;
@property(nonatomic, assign) CGFloat contentScrollViewOriginalContentHeight;
@property(nonatomic, strong) NXProjectModel *updatedProjectModel;

@property(nonatomic, weak)UIView *percentageView;
@property(nonatomic, weak)UIView *progressView;
@property(nonatomic, weak)UILabel *usageLabel;
@property(nonatomic, weak)UILabel *freeLabel;
@property(nonatomic, strong)UIView *headerView;

@end

@implementation NXUpdateProjectInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name: UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewDataAndreloadData];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;

    }
- (UIView *)navigatonView {
    if (!_navigatonView) {
        _navigatonView = [[UIView alloc]init];
        [self.view addSubview:_navigatonView];
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
//        [leftBtn setTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) forState:UIControlStateNormal];
//        [leftBtn setTitleColor:NXBarButtonBlueColor forState:UIControlStateNormal];
//        leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//        leftBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_navigatonView addSubview:leftBtn];
        UILabel *connectLabel = [[UILabel alloc]init];
        connectLabel.text = NSLocalizedString(@"UI_PROJECT_CONFIGURATION", NULL);
        connectLabel.font =[UIFont systemFontOfSize:15];
        connectLabel.textAlignment = NSTextAlignmentCenter;
        [_navigatonView addSubview:connectLabel];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:NSLocalizedString(@"UI_PROJECT_SAVE", NULL) forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        rightBtn.enabled = NO;
        [rightBtn addTarget:self action:@selector(saveProjectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.saveButton = rightBtn;
        [_navigatonView addSubview:rightBtn];
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
                    make.width.equalTo(@50);
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
                make.left.equalTo(_navigatonView).offset(15);
                make.width.equalTo(@50);
                make.height.equalTo(@40);
            }];
        }
        [connectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(leftBtn);
            make.centerX.equalTo(_navigatonView);
            make.width.equalTo(@180);
        }];
        [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(connectLabel);
            make.width.equalTo(@60);
            make.right.equalTo(_navigatonView.mas_right).offset(-10);
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
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIView *percentageView = [[UIView alloc]init];
    percentageView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:percentageView];
    percentageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.percentageView = percentageView;
    UIView *progressView = [[UIView alloc]init];
    [percentageView addSubview:progressView];
    progressView.backgroundColor = RMC_MAIN_COLOR;
    self.progressView = progressView;
    UILabel *usageLabel = [[UILabel alloc]init];
    [headerView addSubview:usageLabel];
    self.usageLabel = usageLabel;
    UILabel *freeLabel = [[UILabel alloc]init];
    [headerView addSubview:freeLabel];
    self.freeLabel = freeLabel;
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:lineView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigatonView.mas_bottom).offset(5);
        make.left.right.equalTo(self.view);
    }];
    
    [percentageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(5);
        make.left.equalTo(headerView).offset(40);
        make.right.equalTo(headerView).offset(-40);
        make.height.equalTo(@10);
    }];
    [usageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(percentageView.mas_bottom).offset(4);
        make.left.equalTo(percentageView);
        make.width.equalTo(percentageView).multipliedBy(0.5);
        make.height.equalTo(@10);
        
    }];
    [freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.equalTo(usageLabel);
        make.right.equalTo(percentageView);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(freeLabel.mas_bottom).offset(kMargin);
        make.left.right.width.equalTo(headerView);
        make.height.equalTo(@1);
        make.bottom.equalTo(headerView).offset(-1);
    }];
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    NXCommentInputView *projectNameView = [[NXCommentInputView alloc]init];
    [self.contentScrollView addSubview:projectNameView];
    self.projectNameView = projectNameView;
    projectNameView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_NAME_OF_THE_PROJECT", NULL)  subTitle:@"" subTitleColor:[UIColor redColor]];
    projectNameView.textView.text = self.needUpdateProjectModel.name;
    projectNameView.textView.textColor = [UIColor lightGrayColor];
    projectNameView.textView.selectable = NO;
    projectNameView.maxCharacters = -1;
    projectNameView.delegate = self;
    projectNameView.tag = NXNameInputViewTag;
    projectNameView.textView.editable = NO;

    [projectNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(self.contentScrollView.mas_top);
        make.height.equalTo(@110);
    }];

    
    NXCommentInputView *descriptionView = [[NXCommentInputView alloc]init];
    [self.contentScrollView addSubview:descriptionView];
    self.descriptionView = descriptionView;
    descriptionView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_DRSCRIPTION", NULL) subTitle:@"*" subTitleColor:[UIColor redColor]];
    descriptionView.textView.text = self.needUpdateProjectModel.projectDescription;
    descriptionView.maxCharacters = 250;
    descriptionView.delegate = self;
    descriptionView.textView.placeholder = @"";

    [descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(projectNameView.mas_bottom);
        make.height.equalTo(@150);
    }];

    
    NXCommentInputView *inputView = [[NXCommentInputView alloc]init];
    [self.contentScrollView addSubview:inputView];
    self.invitationMsgView = inputView;
    inputView.promptLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_INVITATION_MSG", NULL) subTitle:NSLocalizedString(@"UI_INVITATION_OPTIONAL", NULL) subTitleColor:[UIColor grayColor]];
    inputView.textView.text = self.needUpdateProjectModel.invitationMsg;
    inputView.maxCharacters = 250;
    inputView.textView.placeholder = @"";
    inputView.delegate = self;

    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(40);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.top.equalTo(descriptionView.mas_bottom);
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
            
            
            [descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
                make.top.equalTo(projectNameView.mas_bottom);
                make.height.equalTo(@150);
            }];
            
            [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-30);
                make.top.equalTo(descriptionView.mas_bottom);
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
    
        [descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
            make.top.equalTo(projectNameView.mas_bottom);
            make.height.equalTo(@150);
        }];
        
        [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
            make.top.equalTo(descriptionView.mas_bottom);
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

#pragma mark ------>back
- (void)closeButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ------>save
- (void)saveProjectButtonClicked:(id)sender {
    [self tap:nil];
    NSString *displayName = self.projectNameView.textView.text;
    NSString *displayDescription = self.descriptionView.textView.text;
    displayDescription = [displayDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *invitationMsg = self.invitationMsgView.textView.text;
    invitationMsg = [invitationMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.needUpdateProjectModel.name = displayName;
    self.needUpdateProjectModel.projectDescription = displayDescription;
    self.needUpdateProjectModel.invitationMsg = invitationMsg;
    [NXMBManager showLoadingToView:self.view];
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject updateProject:self.needUpdateProjectModel withCompletion:^(NXProjectModel *project, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.view];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?: NSLocalizedString(@"MSG_CONFIGURATION_PROJECT_FAILED", nil) hideAnimated:YES afterDelay:kDelay];
            }else {
                self.updatedProjectModel = project;
                [self dismissself];
            }
        });
    }];
}
- (void)dismissself
{
    if ([self.tabBarController isKindOfClass:[NXProjectTabBarController class]]) {
        NXProjectTabBarController *tabbar = [[NXProjectTabBarController alloc]initWithProject:self.updatedProjectModel];
        tabbar.preTabBarController = ((NXProjectTabBarController *)self.tabBarController).preTabBarController;
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.tabBarController.navigationController.viewControllers];
        [viewControllers removeLastObject];
        [viewControllers addObject:tabbar];
        [self.tabBarController.navigationController setViewControllers:viewControllers];
        tabbar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
    }
    if ([self.tabBarController isKindOfClass:[NXMasterTabBarViewController class]]) {
        NXProjectTabBarController *projectTabBar = [[NXProjectTabBarController alloc] initWithProject:self.updatedProjectModel];
        projectTabBar.preTabBarController = (NXMasterTabBarViewController *)self.tabBarController;
        [self.tabBarController.navigationController pushViewController:projectTabBar animated:YES];
        projectTabBar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
    }
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark ---- NXCommentInputViewDelegate
- (void)commentInputViewDidEndEditing:(NXCommentInputView *)inputView {
    if (self.descriptionView.textView.text.length > 0) {
        [self.saveButton setTitleColor:NXBarButtonBlueColor forState:UIControlStateNormal];
        self.saveButton.enabled = YES;
    } else {
        [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    }
}
- (void)commentInputView:(NXCommentInputView *)inputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.descriptionView.textView.text.length > 0 ) {
        [self.saveButton setTitleColor:NXBarButtonBlueColor forState:UIControlStateNormal];
        self.saveButton.enabled = YES;
    } else if (text.length < 1) {
        [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    }
    if (inputView.tag == NXNameInputViewTag) {
        if (text.length > 0 && [NXCommonUtils JudgeTheillegalCharacter:text withRegexExpression:@"^[\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\w \\x22\\x23\\x27\\x2C\\x2D]+$"]) {
            self.warnLabel.textColor = [UIColor redColor];
        }else {
            self.warnLabel.textColor = [UIColor lightGrayColor];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]]) {
        return NO;
    } else {
        [self tap:nil];
        return NO;
    }
}
- (void)tap:(UIGestureRecognizer *)gestuer {
    [self.view endEditing:YES];
}
#pragma mark - NSNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGFloat keyboardAnimationDurationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (keyboardAnimationDurationTime <= 0) {
        self.contentScrollView.contentOffset = CGPointMake(0,0);
        return;
    }
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat change = keyboardEndFrame.origin.y - keyboardBeginFrame.origin.y;
    
    CGFloat offestY;
    UIInterfaceOrientation sataus = [UIApplication sharedApplication].statusBarOrientation;
    if (self.descriptionView.textView.isFirstResponder) {
         if ([NXCommonUtils isiPad]) {
            return;
         }
         if (sataus == UIDeviceOrientationLandscapeLeft || sataus == UIDeviceOrientationLandscapeRight) {
            offestY = change/1.7;
            self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
         }else {
            offestY = change/4;
            self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
         }
     }
     else {
         if ([NXCommonUtils isiPad]) {
             if (sataus == UIDeviceOrientationLandscapeLeft || sataus == UIDeviceOrientationLandscapeRight) {
                 offestY = change/3;
                 self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
             }
             return;
         }
         if (sataus == UIDeviceOrientationLandscapeLeft || sataus == UIDeviceOrientationLandscapeRight) {
             offestY = change;
             self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
         }else {
             offestY = change/2.3;
             if ([[UIScreen mainScreen] bounds].size.height <= 570) {
                offestY = change/1.2;
             }
            self.contentScrollView.contentOffset = CGPointMake(0, self.contentScrollView.contentOffset.y - offestY);
        }
    }
}
#pragma mark -----> getData
- (void)getNewDataAndreloadData {
    WeakObj(self);
    
    [[NXLoginUser sharedInstance].myProject getFileListRecentFileForProject:self.needUpdateProjectModel withCompletion:^(NXProjectModel *project, NSArray *fileList,NSDictionary *spaceDict, NSError *error) {
      StrongObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.view];
            if (!error) {
                if (spaceDict) {
                    [self setProjectSpaceWithSpaceDictionary:spaceDict];
                }
               
                
            }else {
                if (error.code == NXRMC_ERROR_CODE_PROJECT_KICKED ) {
                    return ;
                }
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }
        });
        
    }];
}
- (void)setProjectSpaceWithSpaceDictionary:(NSDictionary *)spaceDict {
    if (!spaceDict) {
        return;
    }
    NSNumber *projectUsage = spaceDict[@"usage"];
    NSNumber *projectQuota = spaceDict[@"quota"];
    NSString *usageStr = [NSByteCountFormatter stringFromByteCount:[projectUsage floatValue] countStyle:NSByteCountFormatterCountStyleBinary];
    self.usageLabel.textColor = [UIColor grayColor];
    self.usageLabel.font = [UIFont systemFontOfSize:10];
    self.usageLabel.text = [NSString stringWithFormat:@"%@ used",usageStr];
    if ([projectUsage floatValue] == 0) {
        self.usageLabel.text = @"0 KB used";
    }
    NSString *freeStr = [NSByteCountFormatter stringFromByteCount:[projectQuota floatValue] - [projectUsage floatValue] countStyle:NSByteCountFormatterCountStyleBinary];
    self.freeLabel.text = [NSString stringWithFormat:@"%@ free",freeStr];
    self.freeLabel.font = [UIFont systemFontOfSize:10];
    self.freeLabel.textAlignment = NSTextAlignmentRight;
    float usagePercentage = [projectUsage floatValue]/[projectQuota floatValue];
    if (usagePercentage > 0 && usagePercentage < 0.01) {
        usagePercentage = 0.01;
    }
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.equalTo(self.percentageView);
        make.width.equalTo(self.percentageView).multipliedBy(usagePercentage);
    }];
}
#pragma mark ------>attributeString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle subTitleColor:(UIColor *)color {
    NSMutableAttributedString *myTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    NSAttributedString *sub = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :color, NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [myTitle appendAttributedString:sub];
    return myTitle;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
