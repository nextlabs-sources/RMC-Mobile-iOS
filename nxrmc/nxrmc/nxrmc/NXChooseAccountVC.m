//
//  NXChooseAccountVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/10/16.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXChooseAccountVC.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXCommonUtils.h"
#import "NXRouterLoginPageURL.h"
#import "NXMBManager.h"
#import "NXLoginViewController.h"
#import "NXRegistNewUserViewController.h"
#import "NXSetURLViewController.h"
@interface NXChooseAccountVC ()
@property(nonatomic, strong) UIView *accountBgView;
@end

@implementation NXChooseAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonUIInit];
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.accountBgView addShadow:UIViewShadowPositionTop | UIViewShadowPositionLeft | UIViewShadowPositionBottom | UIViewShadowPositionRight color:[UIColor lightGrayColor]];

}
- (void)commonUIInit{
    UIButton *backBtn = [[UIButton alloc]init];
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.accessibilityValue = @"CHOOSE_ACCOUNT_BACK_BUTTON";
    [self.view addSubview:backBtn];
    CGFloat topSpace = 40;
    if ([UIScreen mainScreen].bounds.size.height > 700) {
        topSpace = 80;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *nextLabImage = [[UIImageView alloc]init];
    nextLabImage.image = [UIImage imageNamed:@"nextlabs-logo"];
    [self.view addSubview:nextLabImage];
    nextLabImage.accessibilityValue = @"NEXT_LAB_IMAGE";
    
    UIImageView *skyDrmImage = [[UIImageView alloc]init];
    if (buildFromSkyDRMEnterpriseTarget) {
        skyDrmImage.image = [UIImage imageNamed:@"WelcomeImagePro0"];
    }else {
        skyDrmImage.image = [UIImage imageNamed:@"WelcomeImage0"];
    }
    [self.view addSubview:skyDrmImage];
    skyDrmImage.accessibilityValue = @"WELCOME_SKYDRM_IMAGE";
    
    UIImageView *bgImage = [[UIImageView alloc]init];
    bgImage.contentMode =  UIViewContentModeScaleToFill;
    bgImage.image = [UIImage imageNamed:@"green-gradient-bg"];
    bgImage.userInteractionEnabled = YES;
    [self.view addSubview:bgImage];
    bgImage.accessibilityValue = @"CHOOSE_ACCOUNT_PAGE_BG_IMAGE";
    
    UILabel *hintLabel = [[UILabel alloc]init];
    hintLabel.text = @"You can switch accounts after logging out";
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.font = [UIFont systemFontOfSize:15];
    hintLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:hintLabel];
    hintLabel.accessibilityValue = @"SWITCH_ACCOUNTS_HINT_LABEL";
     UIView *accountBgView = [[UIView alloc]init];
    [self.view addSubview:accountBgView];
   
    UILabel *accountTypeLabel = [[UILabel alloc]init];
    accountTypeLabel.text = @"Select an account type";
    [accountBgView addSubview:accountTypeLabel];
    accountTypeLabel.accessibilityValue = @"SELECT_ACCOUNT_TYPE_LABEL";
    
    accountTypeLabel.textAlignment = NSTextAlignmentCenter;
    [accountBgView addSubview:accountTypeLabel];
    accountTypeLabel.textColor = [UIColor grayColor];
    UIView *acconutView = [self commonInitAccountView];

    [self.view addSubview:acconutView];
    self.accountBgView = accountBgView;
    accountBgView.backgroundColor = [UIColor whiteColor];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.left.equalTo(self.view).offset(10);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    [nextLabImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(topSpace);
        make.width.equalTo(@120);
        make.height.equalTo(@20);
    }];
    [skyDrmImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nextLabImage.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@210);
        make.height.equalTo(@44);
    }];
    [bgImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(15);
        make.left.equalTo(self.view).offset(-10);
        make.right.equalTo(self.view).offset(10);
        make.height.equalTo(self.view).multipliedBy(0.6);
    }];
    
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-30);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@30);
    }];
    [accountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(hintLabel.mas_top).offset(-30);
        make.height.equalTo(bgImage);
        make.width.equalTo(self.view).multipliedBy(0.8);
    }];
    [accountTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountBgView).offset(30);
        make.centerX.equalTo(accountBgView);
        make.width.equalTo(accountBgView).multipliedBy(0.8);
        make.height.equalTo(@20);
    }];
    [acconutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountTypeLabel).offset(25);
        make.center.equalTo(accountBgView);
        make.width.equalTo(accountBgView).multipliedBy(0.8);
    }];
    
}
- (UIView *)commonInitAccountView {
    UIView *accountBgView = [[UIView alloc]init];
    UIView *personalView = [self setUpaccountViewWithImage:@"userIcon" withAccountName:@"My personal account" withAccountDescribe:@"on SkyDRM.com"];
    [accountBgView addSubview:personalView];
    personalView.accessibilityValue = @"MY_PERSONAL_ACCOUNT_VIEW";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapPersonalView:)];
    [personalView addGestureRecognizer:tap];
    
    UIView *companyView = [self setUpaccountViewWithImage:@"company_icon" withAccountName:@"My company account" withAccountDescribe:@""];
    [accountBgView addSubview:companyView];
    companyView.accessibilityValue = @"MY_COMPANY_ACCOUNT_VIEW";
    
     UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapCompanyView:)];
    [companyView addGestureRecognizer:tap1];
    
    if ([NXCommonUtils isiPad]) {
        [personalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(accountBgView);
            make.width.equalTo(accountBgView).multipliedBy(0.8);
            make.bottom.equalTo(accountBgView.mas_centerY).offset(-kMargin * 4);
        }];
        [companyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(accountBgView.mas_centerY).offset(kMargin * 4);
            make.centerX.equalTo(personalView);
            make.width.equalTo(accountBgView).multipliedBy(0.8);
            
        }];
    }else{
        [personalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(accountBgView);
            make.width.equalTo(accountBgView).multipliedBy(0.8);
            make.bottom.equalTo(accountBgView.mas_centerY).offset(-kMargin * 2);
        }];
        [companyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(accountBgView.mas_centerY).offset(kMargin * 2);
            make.centerX.equalTo(personalView);
            make.width.equalTo(accountBgView).multipliedBy(0.8);
            
        }];
    }
    
    
    return accountBgView;
}
- (UIView *)setUpaccountViewWithImage:(NSString *)imageName withAccountName:(NSString *)accountName withAccountDescribe:(NSString *)describe {
    UIView *bgView = [[UIView alloc]init];
    UIImageView *iconImage = [[UIImageView alloc]init];
    iconImage.image = [UIImage imageNamed:imageName];
    [bgView addSubview:iconImage];
    UILabel *accountLabel = [[UILabel alloc]init];
    accountLabel.text = accountName;
    accountLabel.textAlignment = NSTextAlignmentCenter;
    accountLabel.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:accountLabel];
    UILabel *describeLabel = [[UILabel alloc]init];
    describeLabel.text = describe;
    describeLabel.textAlignment = NSTextAlignmentCenter;
    describeLabel.numberOfLines = 2;
    describeLabel.textColor = [UIColor grayColor];
    describeLabel.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:describeLabel];
    
    [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView);
        make.top.equalTo(bgView).offset(10);
        make.width.height.equalTo(@50);
    }];
    [accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView);
        make.top.equalTo(iconImage.mas_bottom).offset(10);
        make.width.equalTo(@180);
        make.height.equalTo(@20);
    }];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView);
        make.top.equalTo(accountLabel.mas_bottom).offset(5);
        make.width.equalTo(accountLabel);
        make.height.equalTo(@20);
        make.bottom.equalTo(bgView.mas_bottom).offset(-kMargin/2);
    }];
    return bgView;
}
- (void)userDidTapPersonalView:(id)sender {
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
                    if (self.isFromLoginIn) {
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
- (void)userDidTapCompanyView:(id)sender {
    
    NXSetURLViewController * urlVC = [[NXSetURLViewController alloc]init];
    urlVC.isFromLoginIn = self.isFromLoginIn;
    [NXCommonUtils setUserLoginStatus:NXUserLoginStatusTypeCompany];
    [self.navigationController pushViewController:urlVC animated:YES];
}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
