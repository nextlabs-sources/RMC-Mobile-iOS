//
//  NXAboutSkyDRMViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXAboutSkyDRMViewController.h"
#import "Masonry.h"
#import "NXWaterMarkView.h"
#import "NXGetUserPreferenceAPI.h"
#import "NXOpenSourceLicensesViewController.h"
@interface NXAboutSkyDRMViewController ()

@end

@implementation NXAboutSkyDRMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (buildFromSkyDRMEnterpriseTarget) {
        self.navigationItem.title = NSLocalizedString(@"UI_ABOUT_SKYDRM_PRO", NULL);
    }else {
        self.navigationItem.title = NSLocalizedString(@"UI_ABOUT_SKYDRM", NULL);
    }
}

#pragma mark
- (NSAttributedString *)rightsText {
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"UI_RIGHTS_YEAR", NULL) attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    NSAttributedString *nextlabsStr = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"UI_RIGHTS_NEXTLABS_INC", NULL) attributes:@{ NSLinkAttributeName:@"https://www.nextlabs.com", NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    [attri appendAttributedString:nextlabsStr];
    
    NSAttributedString *rightsStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"UI_ALL_RIGHTS_RESERVED", NULL) attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    [attri appendAttributedString:rightsStr];
    
    return attri;
}
#pragma mark
- (void)commonInit {
    UIView *aboutInfoView = [[UIView alloc]init];
    [self.view addSubview:aboutInfoView];
    UIImage *skyDRMImage;
    if (buildFromSkyDRMEnterpriseTarget) {
        skyDRMImage = [UIImage imageNamed:@"SkyDRM-Logo-Color-Enterprise"];
    }else{
        skyDRMImage = [UIImage imageNamed:@"rmsLogo"];
    }
    
    UIImageView *skyDrmImageView = [[UIImageView alloc] initWithImage:skyDRMImage];
    [aboutInfoView addSubview:skyDrmImageView];//
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = [UIColor blackColor];
    versionLabel.font = [UIFont systemFontOfSize:16];
    versionLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UI_VERSION", NULL), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    [aboutInfoView addSubview:versionLabel];
    
    UITextView *rightTextView = [[UITextView alloc]init];
    [self.view addSubview:rightTextView];

    UIButton *openLicenses = [[UIButton alloc] init];
    [openLicenses setTitle:@"Open source licenses" forState:UIControlStateNormal];
    [openLicenses setTitleColor:[UIColor colorWithRed:40/256.0 green:125/256.0 blue:240/256.0 alpha:1] forState:UIControlStateNormal];
    [openLicenses addTarget:self action:@selector(openSourceLicenses:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openLicenses];
    rightTextView.tintColor = [UIColor blackColor];
    rightTextView.attributedText = [self rightsText];
    rightTextView.textAlignment = NSTextAlignmentCenter;
    rightTextView.editable = NO;
    rightTextView.scrollEnabled = NO;
    
    [aboutInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.8);
    }];

    [skyDrmImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(aboutInfoView).offset(-50);
        make.centerX.equalTo(aboutInfoView);
        make.width.equalTo(@240);
        make.height.equalTo(@50);
    }];
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(skyDrmImageView.mas_bottom).offset(10);
        make.centerX.equalTo(skyDrmImageView);
        make.width.equalTo(self.view).multipliedBy(0.4);
        make.height.equalTo(@40);
    }];
    [openLicenses mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(versionLabel);
        make.top.equalTo(versionLabel.mas_bottom).offset(20);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
    }];
    [rightTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.width.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
}
- (void)openSourceLicenses:(id)sender {
    NXOpenSourceLicensesViewController *licensesVC = [[NXOpenSourceLicensesViewController alloc] init];
    [self.navigationController pushViewController:licensesVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
