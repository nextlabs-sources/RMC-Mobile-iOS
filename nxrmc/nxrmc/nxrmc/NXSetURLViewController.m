//
//  NXSetURLViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/4/24.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXSetURLViewController.h"
#import "Masonry.h"
#import "NXSetSeverURLView.h"
#import "UIView+UIExt.h"
#import "NXRouterLoginPageURL.h"
#import "NXMBManager.h"
#import "NXLoginViewController.h"
#import "NXRegistNewUserViewController.h"
#import "NXSelectSeverURLView.h"
#import "NXManageSeverURLViewController.h"
@interface NXSetURLViewController ()
@property (nonatomic, strong) NXSetSeverURLView *urlView;
@property (nonatomic, strong) UIButton *personalBtn;
@property (nonatomic, strong) UIButton *commanyBtn;
@property (nonatomic, strong) NSString *defaultCompanyURL;
@property (nonatomic, strong) NXSelectSeverURLView * selectUrlView;
@property (nonatomic, strong) NSArray *allCompanyURLs;
@property (nonatomic, assign) BOOL isCompanyLogin;
@property (nonatomic, assign) BOOL isSelectCompany;
@end

@implementation NXSetURLViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.defaultCompanyURL = [NXCommonUtils getUserCurrentSelectedLoginURL];
    self.allCompanyURLs = [NXCommonUtils getUserRememberedAndManagedLoginUrlList];
    if (self.allCompanyURLs) {
        self.urlView.urlViewType = NXSetSeverURLViewTypeCommanySelect;
        self.urlView.URLStr = self.defaultCompanyURL;
    }else{
       self.urlView.urlViewType = NXSetSeverURLViewTypeCommanyEdit;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self commonInit];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)commonInit {
    UIButton *backBtn = [[UIButton alloc]init];
    [backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    backBtn.accessibilityValue = @"SETURL_VIEW_BACK_BUTTON";
    UIImageView *nextLabsImageView = [[UIImageView alloc]init];
    nextLabsImageView.image = [UIImage imageNamed:@"nextlabs-logo"];
    [self.view addSubview:nextLabsImageView];
    UIImageView *logoImageView = [[UIImageView alloc]init];
    if (buildFromSkyDRMEnterpriseTarget) {
        logoImageView.image = [UIImage imageNamed:@"WelcomeImagePro0"];
    }else {
        logoImageView.image = [UIImage imageNamed:@"WelcomeImage0"];
    }
    [self.view addSubview:logoImageView];
    
    
    NXSetSeverURLView *urlView = [[NXSetSeverURLView alloc]init];
    [self.view addSubview:urlView];
    self.urlView = urlView;
    WeakObj(self);
    urlView.pullDownBlock = ^{
        self.selectUrlView.hidden = NO;
        self.selectUrlView.cancelHandle = ^{
            StrongObj(self);
            [self.selectUrlView removeFromSuperview];
            self.selectUrlView = nil;
        };
        self.selectUrlView.doneHandle = ^(NSString *urlStr) {
            StrongObj(self);
            self.urlView.URLStr = urlStr;
            [NXCommonUtils setUserRememberedAndSelectedLoginUrl:urlStr];
            self.defaultCompanyURL = urlStr;
        };
    };
    urlView.manageUrlBlock = ^{
        NXManageSeverURLViewController *VC = [[NXManageSeverURLViewController alloc]init];
        [self.navigationController pushViewController:VC animated:YES];
    };
    UIButton *nextBtn = [[UIButton alloc]init];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
    nextBtn.backgroundColor = RMC_MAIN_COLOR;
    [nextBtn cornerRadian:5];
    nextBtn.accessibilityValue = @"SETURL_PAGE_NEXT_BUTTON";
    [nextBtn addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.left.equalTo(self.view).offset(10);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];

    [nextLabsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
        make.width.equalTo(@120);
        make.height.equalTo(@20);
    }];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(nextLabsImageView.mas_bottom).offset(kMargin * 2);
        make.width.equalTo(@210);
        make.height.equalTo(@44);
    }];

    [urlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).offset(kMargin * 4);
        make.left.equalTo(self.view).offset(kMargin * 2);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(urlView.mas_bottom).offset(kMargin * 4);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@300);
        make.height.equalTo(@40);
    }];
}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)nextPage:(UIButton *) sender {
    if (self.urlView.URLStr.length == 0) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SERVER_URL_EMPTY", NULL) hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    NSString *urlStr = self.urlView.URLStr;
    if ([urlStr isEqualToString:@"https://skydrm.com"] || [urlStr isEqualToString:@"skydrm.com"]) {
        urlStr = @"www.skydrm.com";
      }
    if (![urlStr containsString:@"https://"]) {
        urlStr = [[NSString alloc]initWithFormat:@"https://%@",urlStr];
    }
    if (![NXCommonUtils isValidateURL:urlStr]) {
        [self.urlView showErrorMessage];
        return;
    }
    [NXMBManager showLoading];
    [self.view endEditing:YES];
    NXRouterLoginPageURL *loginPageURL = [[NXRouterLoginPageURL alloc] initWithRequest:nil];
    [loginPageURL requestWithObject:urlStr Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [NXMBManager hideHUD];
             if (!error) {
                 NXRouterLoginPageURLResponse *pageURLResponse = (NXRouterLoginPageURLResponse *)response;
                 NSString *pageURL = pageURLResponse.loginPageURLstr;
                 if (self.urlView.isRemberURL) {
                     [NXCommonUtils updateUserLoginUrl:nil newLoginUrl:urlStr isMakeDefault:YES];
                 }
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

//- (void)personalBtnClick:(UIButton *)sender {
//    if (sender.selected == YES) {
//        return;
//    }
//    self.commanyBtn.selected = NO;
//    self.isSelectCompany = NO;
//    sender.selected = YES;
//    self.urlView.urlViewType = NXSetSeverURLViewTypePersonal;
//}
//- (void)commanyBtnClick:(UIButton *)sender {
//    self.isSelectCompany = YES;
//    self.personalBtn.selected = NO;
//    sender.selected = YES;
//    if (self.allCompanyURLs) {
//        self.urlView.urlViewType = NXSetSeverURLViewTypeCommanySelect;
//        self.urlView.URLStr = self.defaultCompanyURL;
//    }else{
//       self.urlView.urlViewType = NXSetSeverURLViewTypeCommanyEdit;
//    }
//}
- (NXSelectSeverURLView *)selectUrlView {
    if (!_selectUrlView) {
        _selectUrlView = [[NXSelectSeverURLView alloc]init];
        _selectUrlView.selectURL = self.defaultCompanyURL;
        _selectUrlView.allURLs = self.allCompanyURLs;
        [self.view addSubview:_selectUrlView];
        [_selectUrlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _selectUrlView;
}
- (UIButton *)createSelectRightsTypeBtnWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc]init];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, button.imageView.bounds.size.width + 10, 0, 0)];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"Group-Not-selected"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Group-selected"] forState:UIControlStateSelected];
    return button;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
