//
//  NXGuideViewControler.m
//  nxrmc
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGuideViewControler.h"

#import "NXCarouselView.h"
#import "NXPageView.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "UIImage+ColorToImage.h"
#import "NXRegistNewUserViewController.h"
#import "NXCommonUtils.h"
#import "NXLoginViewController.h"
#import "NXSetURLViewController.h"
#import "NXChooseAccountVC.h"
#import "NXMBManager.h"
#import "NXRouterLoginPageURL.h"
@interface NXGuideViewControler()<NXCarouseViewDataSource>
@property(nonatomic,assign) BOOL isLogin;
@property(nonatomic, weak) NXCarouselView *scrollView;
//@property(nonatomic, weak) UIButton *signUpButtin;
//@property(nonatomic, weak) UIButton *signInButton;

@end

@implementation NXGuideViewControler

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews  {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    DLog(@"");
}

#pragma mark -

- (void)signInClicked:(id)sender {
#if defined NXRMC_ENTERPRISE_FLAG
//    NXChooseAccountVC *urlVC = [[NXChooseAccountVC alloc]init];
//    urlVC.isFromLoginIn = YES;
//    [self.navigationController pushViewController:urlVC animated:YES];
     NXSetURLViewController * urlVC = [[NXSetURLViewController alloc]init];
      urlVC.isFromLoginIn = YES;
      [NXCommonUtils setUserLoginStatus:NXUserLoginStatusTypeCompany];
      [self.navigationController pushViewController:urlVC animated:YES];
#else
    self.isLogin = YES;
    [self userDidTapPersonalView];

#endif
    
}

- (void)signUpClicked:(id)sender {
#if defined NXRMC_ENTERPRISE_FLAG
//    NXChooseAccountVC *urlVC = [[NXChooseAccountVC alloc]init];
//    urlVC.isFromLoginIn = NO;
//    [self.navigationController pushViewController:urlVC animated:YES];
         NXSetURLViewController * urlVC = [[NXSetURLViewController alloc]init];
         urlVC.isFromLoginIn = NO;
         [NXCommonUtils setUserLoginStatus:NXUserLoginStatusTypeCompany];
         [self.navigationController pushViewController:urlVC animated:YES];
#else
    self.isLogin = NO;
    [self userDidTapPersonalView];
#endif
    
}
- (void)userDidTapPersonalView {
    [NXMBManager showLoading];
    [NXCommonUtils setUserLoginStatus:NXUserLoginStatusTypePersonal];
    NSString *urlStr = [NXCommonUtils getDefaultPresonalLoginURL];
    NXRouterLoginPageURL *loginPageURL = [[NXRouterLoginPageURL alloc]initWithRequest:nil];
    [loginPageURL requestWithObject:urlStr Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
            if (!error) {
                NXRouterLoginPageURLResponse *pageURLResponse = (NXRouterLoginPageURLResponse *)response;
                NSString *pageURL = pageURLResponse.loginPageURLstr;
                if (pageURL) {
                    [NXCommonUtils saveRmserver:pageURL];
                    if (self.isLogin) {
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        NXLoginViewController *vcs = [storyboard instantiateViewControllerWithIdentifier:@"NXLoginVC"];
                        [self.navigationController pushViewController:vcs animated:YES];
                    }else {
                        NXRegistNewUserViewController *registNewUserVC = [[NXRegistNewUserViewController alloc] init];
                        [self.navigationController pushViewController:registNewUserVC animated:YES];
                    }
                }else{
                    [NXMBManager showMessage:response.rmsStatuMessage hideAnimated:YES afterDelay:1.5];
                }
            } else {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
            }
        });
    }];
}
#pragma mark - NXCarouseViewDelegate, NXCarouseViewDataSource

- (NSInteger)numberofPagecarouseView:(NXCarouselView *)carouseView {
    return 5;
}

- (UIView *)pageAtIndex:(NSInteger)index carouseView:(NXCarouselView *)carouseView {
    NXPageView *view = [[NXPageView alloc] init];
    
    NSDictionary *normalProperty = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    NSDictionary *coloredProperty = @{NSForegroundColorAttributeName:RMC_MAIN_COLOR, NSObliquenessAttributeName:@(0.2)};
    
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] init];
    switch (index) {
        case 0:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Protect, monitor,", NULL)attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc]initWithString:NSLocalizedString(@" and ", NULL) attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"share\n", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"your documents securely\n", NULL) attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"anywhere.", NULL) attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
        }
            break;
        case 1:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Share files securely using\n", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"digital rights\n", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"with anyone, anywhere!", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
        }
            break;
        case 2:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Protect documents\n", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"across multiple\n", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"cloud repositories!", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
        }
            break;
        case 3:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Access files managed in a\n", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"document vault\n", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"from any device!", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
        }
            break;
        case 4:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Revoke, track and monitor\n", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"usage\n", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"of your documents!", NULL) attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
        }
            break;
        default:
            break;
    }
    view.mainTextLabel.attributedText = titleAttribute;
    
    if (buildFromSkyDRMEnterpriseTarget && index == 0) {
         view.imageView.image = [UIImage imageNamed:@"WelcomeImagePro0"];
    }else {
        view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"WelcomeImage%ld", (long)index]];
    }
    
    view.pageControl.numberOfPages = 5;
    view.pageControl.currentPage = index;
    view.pageControl.currentDotImage = [UIImage imageNamed:@"dotCurrentImage"];
    view.pageControl.dotImage = [UIImage imageNamed:@"dotImage"];
    return view;
}

- (void)carouseView:(NXCarouselView *)carouseView didClickPage:(UIView *)view atIndex:(NSInteger)index {
    NSLog(@"");
}

#pragma mark 

- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    
    NXCarouselView *carouselView = [[NXCarouselView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:carouselView];
    
    UIButton *signInBtn = [[UIButton alloc] init];
    [self.view addSubview:signInBtn];
    
//    UIButton *signInBtn = [[UIButton alloc] init];
//    [self.view addSubview:signInBtn];
    
    carouselView.dataSource = self;
    carouselView.showPageControl = NO;
    [carouselView reloadData];
    [carouselView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor] width:1 Opacity:0.5];
    
    [signInBtn setTitle:NSLocalizedString(@"UI_LOGIN", NULL) forState:UIControlStateNormal];
    [signInBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signInBtn cornerRadian:3];
    [signInBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [signInBtn addTarget:self action:@selector(signInClicked:) forControlEvents:UIControlEventTouchUpInside];
    signInBtn.backgroundColor = [UIColor whiteColor];
    signInBtn.layer.borderColor = [UIColor blackColor].CGColor;
    signInBtn.layer.borderWidth = 2;
    
    NSMutableAttributedString *promptText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"No account? ", NULL) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    NSAttributedString *loginText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Create one for free!", NULL) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:RMC_MAIN_COLOR}];
    [promptText appendAttributedString:loginText];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.attributedText = promptText;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.userInteractionEnabled = NO;
    
    [self.view addSubview:promptLabel];
    
    UIButton *signUpButton = [[UIButton alloc] init];
    [signUpButton addTarget:self action:@selector(signUpClicked:) forControlEvents:UIControlEventTouchUpInside];
    signUpButton.userInteractionEnabled = YES;
    [self.view addSubview:signUpButton];
    
    [carouselView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin * 5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(signInBtn.mas_top).offset(-kMargin * 2);
    }];
    
    [signInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.6);
        make.bottom.equalTo(promptLabel.mas_top).offset(-kMargin * 2);
        make.height.equalTo(@(kMargin * 5));
    }];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(kMargin * 4));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-kMargin * 3);
    }];
    
    [signUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(promptLabel).multipliedBy(1.2);
        make.width.equalTo(promptLabel).multipliedBy(0.7);
        make.centerY.and.right.equalTo(promptLabel);
    }];
    
    [self.view bringSubviewToFront:signUpButton];
    
#if 0
    signUpBtn.backgroundColor = [UIColor greenColor];
    carouselView.backgroundColor = [UIColor lightGrayColor];
    promptLabel.backgroundColor = [UIColor redColor];
#endif
}

@end
