//
//  NXLRMSConfigViewController.m
//  nxSDK
//
//  Created by helpdesk on 9/9/16.
//  Copyright © 2016年 Eren. All rights reserved.


#import "NXLRMSConfigViewController.h"
#import "NXLCommonUtils.h"
#import "NXLTenant.h"
#define RMS_CONFIG            @"RMS"
#define DEFAULT_SKYDRM        @"https://r.skydrm.com"
#define TENANT_NAME           @"tenant name"
#define BOX_OK                @"OK"
#define RESET_TO_DEFAULT_RMS  @"Reset"
@interface NXLRMSConfigViewController ()
@property (strong, nonatomic)  UITextField *rmsSiteURLTextField;
@property (strong, nonatomic)  UITextField *tenantNameTextField;
@property (strong, nonatomic) UIButton *configButton;
@property (strong, nonatomic) UIButton *resetToDefaultButton;
@end

@implementation NXLRMSConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self commitInit];
}

- (void) commitInit {
    self.navigationItem.title = RMS_CONFIG;
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _rmsSiteURLTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _rmsSiteURLTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _rmsSiteURLTextField.borderStyle = UITextBorderStyleRoundedRect;
    _rmsSiteURLTextField.placeholder = NSLocalizedString(@"RMS_URL", nil);
    _rmsSiteURLTextField.clearButtonMode = UITextFieldViewModeAlways;
    _rmsSiteURLTextField.text =  DEFAULT_SKYDRM;
    [_rmsSiteURLTextField setFont:[UIFont systemFontOfSize:14.0]];
    [self.view addSubview:_rmsSiteURLTextField];
    
    _tenantNameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _tenantNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _tenantNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    _tenantNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    _tenantNameTextField.text = [NXLTenant currentTenant].tenantID;
    _tenantNameTextField.placeholder = TENANT_NAME  ;
    [_tenantNameTextField setFont:[UIFont systemFontOfSize:14.0]];
    [self.view addSubview:_tenantNameTextField];
    
    
    _configButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _configButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_configButton setTitle:BOX_OK forState:UIControlStateNormal];
    [_configButton addTarget:self action:@selector(userDidClickOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_configButton];
    
    [_configButton.layer setMasksToBounds:YES];
    [_configButton.layer setCornerRadius:20];
    _configButton.backgroundColor = [UIColor colorWithRed:25.f/255.f green:184.f/255.f blue:121.f/255.f alpha:1.0f];
    
    _resetToDefaultButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _resetToDefaultButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_resetToDefaultButton setTitle:RESET_TO_DEFAULT_RMS forState:UIControlStateNormal];
    [_resetToDefaultButton addTarget:self action:@selector(userDidClickResetToDefaultConfig:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetToDefaultButton];
    [_resetToDefaultButton.layer setMasksToBounds:YES];
    [_resetToDefaultButton.layer setCornerRadius:20];
    _resetToDefaultButton.backgroundColor = [UIColor redColor];
    
     NSDictionary *viewDict = @{@"rmsSiteURLTextField":_rmsSiteURLTextField, @"tenantNameTextField":_tenantNameTextField, @"configButton":_configButton, @"resetToDefaultButton":_resetToDefaultButton};
    
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rmsSiteURLTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:40.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tenantNameTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_rmsSiteURLTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetToDefaultButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_tenantNameTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_configButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_tenantNameTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetToDefaultButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_rmsSiteURLTextField attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetToDefaultButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetToDefaultButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_configButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_rmsSiteURLTextField attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_configButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_configButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapBackgroundView:)];
    [self.view addGestureRecognizer:tap];


}
#pragma mark - Response to User interface
-(void) userDidClickOK:(UIButton *) button
{
    [_rmsSiteURLTextField resignFirstResponder];
    [_configButton resignFirstResponder];
    
    if ([self.rmsSiteURLTextField.text isEqualToString:@""]) {
        [NXLCommonUtils showAlertViewInViewController:self title:NSLocalizedString(@"ALERTVIEW_TITLE", nil) message:@"Please enter RMS URL"];
        return;
    }
    
    if ([self.tenantNameTextField.text isEqualToString:@""]) {
        [NXLCommonUtils showAlertViewInViewController:self title:NSLocalizedString(@"ALERTVIEW_TITLE", nil) message:@"Please enter tenant name"];
        return;
    }
    
//    [NXCommonUtils updateSkyDrm:self.rmsSiteURLTextField.text];
//    [NXCommonUtils updateRMSTenant:self.tenantNameTextField.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) userDidClickResetToDefaultConfig:(UIButton *) button
{
    [_rmsSiteURLTextField resignFirstResponder];
    [_configButton resignFirstResponder];
    
//    [NXCommonUtils updateSkyDrm:DEFAULT_SKYDRM];
//    [NXCommonUtils updateRMSTenant:DEFAULT_TENANT];
    
    self.rmsSiteURLTextField.text = DEFAULT_SKYDRM;
//    self.tenantNameTextField.text = DEFAULT_TENANT;
}

-(void) userDidTapBackgroundView:(UITapGestureRecognizer *) tapGesture
{
    [_rmsSiteURLTextField resignFirstResponder];
    [_configButton resignFirstResponder];
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
