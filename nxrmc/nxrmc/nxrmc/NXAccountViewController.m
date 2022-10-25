//
//  NXAccountViewController.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAccountViewController.h"

#import "NXLoginNavigationController.h"
#import "NXSetPwdViewController.h"

#import "Masonry.h"

#import "UIView+UIExt.h"
#import "NXAccountHeaderView.h"
#import "NXAccountEmailView.h"
#import "NXAccountInputCell.h"
#import "NXProfileCell.h"
#import "nxphotoselecter/NXPhotoSelector.h"
#import "NXMBManager.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXGetProfileAPI.h"

#import "NXUpdateProfileAPI.h"
#import "UIImage+Cutting.h"
#import "NXLProfile.h"
#import "NXLClient.h"
@interface NXAccountViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) NXAccountEmailView *emailView;
@property(nonatomic, weak) NXAccountHeaderView *headerView;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, strong) UITextField *nameText;
@property(nonatomic, strong) NXPhotoSelector *selecter;

@property(nonatomic, strong) NSArray<NSArray *> *dataArray;

@end

@implementation NXAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name: UIKeyboardWillChangeFrameNotification object:nil];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"Back";
//    self.navigationItem.backBarButtonItem = backItem;
    self.emailView.tapclickBlock = ^(id sender){
        DLog(@"email clicked");
        [self changeDisplayName];
    };
    self.headerView.nameStr = [NXLoginUser sharedInstance].profile.userName;
    
/* hide user photo
    if ([NXLoginUser sharedInstance].profile.avatar) {
        self.headerView.avatarImageView.image = [UIImage imageWithBase64Str:[NXLoginUser sharedInstance].profile.avatar];
    }
    else
    {
        self.headerView.avatarImageView.image = [UIImage imageNamed:@"Account"];
    }
*/
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView bringSubviewToFront:self.emailView];
    [self.emailView addShadow:UIViewShadowPositionBottom | UIViewShadowPositionTop | UIViewShadowPositionLeft | UIViewShadowPositionRight color:[UIColor darkGrayColor] width:0.5 Opacity:0.5];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    DLog();
}

#pragma mark
//- (NSArray<NSArray *> *)dataArray {
//    if (!_dataArray) {
//        NXAccountInputCellModel *name = [[NXAccountInputCellModel alloc] initWithText:[NXLoginUser sharedInstance].profile.userName placeholder:NSLocalizedString(@"Enter your full name", NULL) prompt:NSLocalizedString(@"Name", NULL)];
//        NXAccountInputCellModel *address = [[NXAccountInputCellModel alloc] initWithText:[NXLoginUser sharedInstance].profile.email placeholder:NSLocalizedString(@"Enter your email address", NULL) prompt:NSLocalizedString(@"Email address", NULL)];
////        NXAccountInputCellModel *phoneNumber = [[NXAccountInputCellModel alloc] initWithText:nil placeholder:NSLocalizedString(@"Enter your phone phone number", NULL) prompt:NSLocalizedString(@"Phone Number", NULL)];
////        NXProfilePageCellModel *changeName = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"Change Name", NULL) message:@""];
////        NXProfilePageCellModel *changepwd = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"Change Password", NULL) message:@""];
////        NXProfilePageCellModel *logout = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"Logout", NULL) message:@""];
////        if([NXLoginUser sharedInstance].nxlCLient.idpType == NXLClientIdpTypeBasic){
////            _dataArray = @[@[], @[name, address], @[changeName,changepwd, logout]];
////        }else{
////            _dataArray = @[@[], @[name, address], @[changeName,logout]];
////        }
////        
//    }
//    return _dataArray;
//}

- (NXPhotoSelector *)selecter {
    if (!_selecter) {
        _selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
        _selecter.type = NXPhotoSelectRetunTypeDefault;
    }
    return _selecter;
}

#pragma mark
- (void)logOut:(id)sender {
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_SIGN_OUT_ALERT_MESSAGE", NULL) style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action)  {
        if ([[NXLoginUser sharedInstance] isLogInState]) {
            [[NXLoginUser sharedInstance] logOut];
        }
        NXLoginNavigationController *nav = [[NXLoginNavigationController alloc] init];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    } cancelActionHandle:nil inViewController:self position:sender];
}

- (void)showPhotoPicker:(NXPhotoSelectType)type {
    WeakObj(self);
    [self.selecter showPhotoPicker:type complete:^(NSArray *selectedItems, BOOL authen) {
        StrongObj(self);
        if (selectedItems.count) {
            UIImage *image = [selectedItems objectAtIndex:0];
            
            NSData *data = [UIImage zipImage:image size:5 * 1024];
            NSString *imgStr = [UIImage base64StrWithImage:[UIImage imageWithData:data]];

            NXUpdateProfileAPIRequestModel *model = [[NXUpdateProfileAPIRequestModel alloc]initWithDisplayName:nil isChangeImage:YES avatorData:imgStr userid:[NXLoginUser sharedInstance].profile.userId ticket:[NXLoginUser sharedInstance].profile.ticket];
            NXUpdateProfileAPI *api = [[NXUpdateProfileAPI alloc] initWIthModel:model];
            WeakObj(self);
            [NXMBManager showLoading:NSLocalizedString(@"UI_SETTING", NULL) toView:self.view];
            [api requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    StrongObj(self);
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_CHANGE_ACCOUNT_ICON_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                        return;
                    }
                    NXSuperRESTAPIResponse *model = (NXSuperRESTAPIResponse *)response;
                    if (model.rmsStatuCode != 200) {
                        [NXMBManager showMessage:model.rmsStatuMessage hideAnimated:YES afterDelay:kDelay];
                        return;
                    }
                    self.headerView.avatarImageView.image = [UIImage imageWithData:data];
                    [NXLoginUser sharedInstance].profile.avatar = imgStr;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_INFO_UPDATED object:nil];
                });
            }];
        }
    }];
}

#pragma mark
- (void)tap:(UIGestureRecognizer *)gesture {
    [self.view endEditing:YES];
}

#pragma mark - NSNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];

    CGFloat change = keyboardEndFrame.origin.y - keyboardBeginFrame.origin.y;
    [self.tableView layoutSubviews]; //fix rotation make tableview
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height - change);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 0 ? 45 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
    } else {
        view.backgroundColor = self.view.backgroundColor;
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NXAccountInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kAccountCell"];
        
        NXAccountInputCellModel *model = self.dataArray[indexPath.section][indexPath.row];
        if (indexPath.row == 0) {
            self.nameText = cell.textField;
        }
        cell.textField.userInteractionEnabled = NO;
        cell.model = model;
        return cell;
    } else {
        NXProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kProfileCell"];
        
        NXProfilePageCellModel *model = self.dataArray[indexPath.section][indexPath.row];
        cell.model = model;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if ([NXLoginUser sharedInstance].profile.idpType == NXLClientIdpTypeBasic) {
        if (indexPath.row == 2 && indexPath.section == 2) {
            [self logOut:nil];
            return;
        }
        else if (indexPath.row == 0 && indexPath.section == 2) {
            [self changeDisplayName];
        }
        else if (indexPath.row == 1 && indexPath.section == 2) {
            NXSetPwdViewController *vc = [[NXSetPwdViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }else{
        if (indexPath.row == 0 && indexPath.section == 2) {
            [self changeDisplayName];
          }else if (indexPath.row == 1 && indexPath.section == 2) {
            [self logOut:nil];
            return;
        }
    }
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark
- (void)commonInit {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = [self textTwoLongDotsInMiddleWithStr:[NXLoginUser sharedInstance].profile.userName];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_COM_PROFILE_LOGOUT", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //init background view when pull down tablview.
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = RMC_MAIN_COLOR;
    [self.view addSubview:backgroundView];
    
    //init tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    
    tableView.showsVerticalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 44;
    
    tableView.backgroundColor = [UIColor clearColor];
    
    [tableView registerClass:[NXProfileCell class] forCellReuseIdentifier:@"kProfileCell"];
    [tableView registerClass:[NXAccountInputCell class] forCellReuseIdentifier:@"kAccountCell"];
    
    CGFloat tabelHeaderHeight = 150;
    CGFloat emailViewHeight = 45;
    NXAccountHeaderView *headerView = [[NXAccountHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, tabelHeaderHeight)];
    tableView.tableHeaderView = headerView;
    CGRect frame = headerView.frame;
    headerView.frame = frame;

//    if ([NXLoginUser sharedInstance].profile.avatar) {
//        headerView.avatarImageView.image = [UIImage imageWithBase64Str:[NXLoginUser sharedInstance].profile.avatar];
//    }
    headerView.nameStr = [NXLoginUser sharedInstance].profile.userName;
    NXAccountEmailView *emailView = [[NXAccountEmailView alloc] init];
    emailView.backgroundColor = [UIColor whiteColor];
    [tableView addSubview:emailView];
    NSString *nameStr = [NXLoginUser sharedInstance].profile.userName;
    emailView.emaiLabel.text = [nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    UILabel *emailInfoLabel = [[UILabel alloc]init];
    emailInfoLabel.font = [UIFont systemFontOfSize:15];
    emailInfoLabel.backgroundColor = [UIColor whiteColor];
    emailInfoLabel.accessibilityValue = @"PROFILE_PAGE_EMAILINFO_LABEL";
    emailInfoLabel.text = [NSString stringWithFormat:@"   %@",[NXLoginUser sharedInstance].profile.email] ;
    [tableView addGestureRecognizer:tap];
    tableView.tableFooterView = [[UIView alloc]init];
    tap.delegate = self;
    [tap addTarget:self action:@selector(tap:)];
    
    self.emailView = emailView;
    self.emailView.accessibilityValue = @"PROFILE_PAGE_ACCOUNT_CHANGE_EMAIL_VIEW";
    self.headerView = headerView;
    self.headerView.accessibilityValue = @"PROFILE_PAGE_ACCOUNT_CHANGE_HEADERVIEW";
    self.tableView = tableView;
    self.tableView.accessibilityValue = @"PROFILE_PAGE_ACCOIUNT_TABLEVIEW";
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.25);
    }];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    [emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tableView).offset(tabelHeaderHeight - emailViewHeight/2);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
        make.height.equalTo(@(emailViewHeight));
    }];
    
    UIView *emailInfoLablView = [[UIView alloc] init];
    emailInfoLablView.backgroundColor = emailView.backgroundColor;
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
          
            [emailInfoLablView addSubview:emailInfoLabel];
            [tableView addSubview:emailInfoLablView];
            [emailInfoLablView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(emailView.mas_bottom).offset(1);
                make.left.right.height.equalTo(emailView);
            }];
            
            [emailInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(emailInfoLablView.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(emailInfoLablView.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(emailInfoLablView.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(emailInfoLablView.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }
    else
    {
       [tableView addSubview:emailInfoLabel];
        
        [emailInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(emailView.mas_bottom).offset(1);
            make.left.right.height.equalTo(emailView);
        }];
    }
}
- (void)changeDisplayName {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: [NXCommonUtils currentBundleDisplayName]
                                                                              message: NSLocalizedString(@"UI_COM_PLESASE_INPUT_NAME", NULL)
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"UI_COM_CANNOT_CONTAIN_SPECIAL", NULL);
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
        
    }]];

    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
         UITextField * nameTextfield = textfields[0];
        NSString *displayName = nameTextfield.text;
        displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (![self isEnableTextFieldNameWithStr:displayName]) {
            [self changeDisplayName];
            return ;
        }

        NXUpdateProfileAPIRequestModel *model = [[NXUpdateProfileAPIRequestModel alloc]initWithDisplayName:nameTextfield.text isChangeImage:NO avatorData:nil userid:[NXLoginUser sharedInstance].profile.userId ticket:[NXLoginUser sharedInstance].profile.ticket];
        NXUpdateProfileAPI *api = [[NXUpdateProfileAPI alloc] initWIthModel:model];
        WeakObj(self);
        [NXMBManager showLoading:NSLocalizedString(@"Setting...", NULL) toView:self.view];
        [api requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongObj(self);
                [NXMBManager hideHUDForView:self.view];
                if (error) {
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_PROFILE_CHANGE_NAME_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                    return;
                }
                NXSuperRESTAPIResponse *model = (NXSuperRESTAPIResponse *)response;
                if (model.rmsStatuCode != 200) {
                    [NXMBManager showMessage:model.rmsStatuMessage hideAnimated:YES afterDelay:kDelay];
                    return;
                }
                self.emailView.emaiLabel.text = displayName;
                self.navigationItem.title = [self textTwoLongDotsInMiddleWithStr:nameTextfield.text];
                self.headerView.nameStr = displayName;
                [NXLoginUser sharedInstance].profile.userName = displayName;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_INFO_UPDATED object:nil];
            });
        }];


    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (BOOL)isEnableTextFieldNameWithStr:(NSString *)str {
    if([str isEqualToString:@""])
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_PLESASE_INPUT_NAME", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }else if(str.length>150)
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_LENGTH_TOOLONG_WARNING_LIMIT_150", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }else if ([NXCommonUtils JudgeTheillegalCharacter:str withRegexExpression:@"^((?![\\~\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)\\_\\+\\=\\[\\]\\{\\}\\;\\:\\\"\\\\\\/\\<\\>\\?]).)+$"]) {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_CONTAIN_SPECIAL_WARNING", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }
    return YES;
}

- (NSString *)textTwoLongDotsInMiddleWithStr:(NSString *)str {
    NSString *newStr = nil;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length>20) {
        NSString *frontStr = [str substringToIndex:8];
        NSString *behindStr = [str substringFromIndex:str.length-8];
        NSString *dotStr = @"...";
        newStr = [NSString stringWithFormat:@"%@%@%@",frontStr,dotStr,behindStr];
        return newStr;
    }
    return str;
}


@end
