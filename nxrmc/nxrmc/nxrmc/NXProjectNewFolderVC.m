//
//  NXProjectNewFolderVC.m
//  nxrmc
//
//  Created by helpdesk on 24/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectNewFolderVC.h"
#import "NXFileBase.h"
#import "Masonry.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
@interface NXProjectNewFolderVC ()<UITextFieldDelegate>
@property(nonatomic, weak) UITextField *textField;
@property(nonatomic, weak) UIBarButtonItem *rightBarButtonItem;
@end

@implementation NXProjectNewFolderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
  }
- (void)commonInit {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.title = NSLocalizedString(@"UI_COM_CREATE_NEW_FOLDER", NULL);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_COM_CREATE", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(create:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UITextField *textField = [[UITextField alloc] init];
    [self.view addSubview:textField];
    
    textField.delegate = self;
    textField.placeholder = NSLocalizedString(@"UI_COM_ENTER_FOLDER_NAME", NULL);
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folder - black"]];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tap:)];
    UILabel *warnLabel = [[UILabel alloc] init];
    warnLabel.text = NSLocalizedString(@"UI_COM_TEXTFIELD_REQUEST_WARNING", nil);
    [warnLabel setFont:[UIFont systemFontOfSize:12.0]];
    warnLabel.numberOfLines = 0;
    [warnLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:warnLabel];
    [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.top.equalTo(textField.mas_bottom);
        make.height.equalTo(@40);
    }];
    self.textField = textField;
    self.rightBarButtonItem = rightItem;
    self.rightBarButtonItem.enabled = NO;
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin * 2);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@44);
    }];
}
- (void)tap:(UIGestureRecognizer *)sender {
    [self.view endEditing:YES];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.rightBarButtonItem.enabled = newStr.length;
    return YES;
}
#pragma mark
- (void)cancel:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)create:(UIBarButtonItem *)sender {
    // send request
    [self.textField resignFirstResponder];
    NSString *displayName = self.textField.text;
    displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([displayName isEqualToString:@""])
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_PLESASE_INPUT_NAME", nil) toView:self.view hideAnimated:YES afterDelay:1.0];
        [self.textField becomeFirstResponder];
        return;
    }else if(displayName.length>127)
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_LENGTH_TOOLONG_WARNING_LIMIT_127",NULL) toView:self.view hideAnimated:YES afterDelay:1.5];
        return;
    }else if ([NXCommonUtils JudgeTheillegalCharacter:displayName withRegexExpression:@"^[\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\w \\x22\\x23\\x27\\x2C\\x2D]+$"]) {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_CONTAIN_SPECIAL_WARNING", NULL) toView:self.view hideAnimated:YES afterDelay:1.5];
        return;
    }

     [NXMBManager showLoading:NSLocalizedString(@"UI_COM_CREATE_FOLDERING", nil) toView:self.view];
    [[NXLoginUser sharedInstance].myProject createProjectFolder:displayName isAutoRename:NO underFolder:self.parentFolder withCompletion:^(NXProjectFolder *newProjectFolder, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.view];
        });
        if (!error) {
            DLog(@"create success %@",newProjectFolder.name);
             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription?error.localizedDescription:NSLocalizedString(@"MSG_COM_CREATE_FOLDER_FAILED", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                
            } cancelActionHandle:nil inViewController:self position:self.view];
            DLog(@"ceater folder error is %@",error);
  
        }
      
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
