//
//  NXCloudAccountUserInforViewController.m
//  nxrmc
//
//  Created by ShiTeng on 15/5/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXCloudAccountUserInforViewController.h"

#import "NXAccountInputTextField.h"
#import "NXAccountInputCell.h"
#import "UIView+UIExt.h"
#import "NXMBManager.h"
#import "Masonry.h"
#import "UIImage+ColorToImage.h"

#import "NXSharePointManager.h"
#import "NXSharepointOnlineAuthentication.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXKeyChain.h"
#import "NXNetworkHelper.h"
#import "NXRepoAuthWorkerBase.h"
#import "NXAddRepositoryAPI.h"
#import "NXRMCStruct.h"
#import "NXLProfile.h"
@interface NXCloudAccountUserInforViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NXSharePointManagerDelegate, NXSharepointOnlineDelegete>

@property (weak, nonatomic) NXAccountInputTextField *spSiteURL;
@property (weak, nonatomic) NXAccountInputTextField *spUserName;
@property (weak, nonatomic) NXAccountInputTextField *spPassword;

@property (nonatomic, strong) NSString *navigationTitle;
@property (nonatomic, strong) NSArray<NXAccountInputCellModel *> *dataArray;

@property (nonatomic) BOOL isConnecting;
@property (nonatomic, strong) NXSharePointManager* spMgr;
@property (nonatomic, strong) NXSharepointOnlineAuthentication *auth;

@property (nonatomic, strong) NSString *sharepointOnlineAccountId;
@property (nonatomic, strong) NSString *sharepointOnlineToken;
@property (nonatomic, strong) NSString *absoultSPULR;

@property (nonatomic, strong) UILabel *promptLabel;

@property (nonatomic, assign) BOOL AuthCanceled;

@end

@implementation NXCloudAccountUserInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    
    _isConnecting = false;
    _AuthCanceled = YES;
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    switch (_serviceBindType) {
        case kServiceSharepointOnline:
            //  _spSiteURL.text = @"https://nextlabsdev.sharepoint.com/ProjectNova/";
            //  _spUserName.text = @"mxu@nextlabsdev.onmicrosoft.com";
            //  _spPassword.text = @"123blue!";
            //  _spSiteURL.text = [NXLoginUser sharedInstance].profile.userName;

            _promptLabel.text = @"Provider SharePoint Online Credentials to connect";
            self.navigationItem.title = NSLocalizedString(@"CLOUDSERVICE_SHAREPOINTONLINE", nil);
            
            break;
        case kServiceSharepoint:
            //_spSiteURL.text = @"http://rms-sp2013.qapf1.qalab01.nextlabs.com/sites/iosdev";
           // _spSiteURL.text = [NXLoginUser sharedInstance].profile.userName;
            // for test
           // _spUserName.text = @"abraham.lincoln@qapf1.qalab01.nextlabs.com";
            // _spPassword.text = @"abraham.lincoln";
            
            _promptLabel.text = @"Provider SharePoint Credentials to connect";
            _spUserName.text = [NXLoginUser sharedInstance].profile.email;
            _spUserName.enabled = NO;
            
            if (_isReAuth == YES && self.repoId.length > 0) {
                //_spSiteURL.text = @"http://rms-sp2013.qapf1.qalab01.nextlabs.com/sites/iosdev";
                _spSiteURL.text = _accountName;
                 _spSiteURL.enabled = NO;
            }else{
                _spSiteURL.text = @"";
                _spSiteURL.enabled = YES;
            }
           
            self.navigationItem.title = NSLocalizedString(@"CLOUDSERVICE_SHAREPOINT", nil);
            break;
        default:
            break;
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_AuthCanceled == YES && self.siteUrlEnterFinishedBlock && self.serviceBindType == kServiceSharepointOnline) {
         self.siteUrlEnterFinishedBlock(nil);
    }
    
    if (self.serviceBindType == kServiceSharepoint && _AuthCanceled == YES) {
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(cloudAccountUserInfoVCDidPressCancelBtn:))) {
            [self.delegate cloudAccountUserInfoVCDidPressCancelBtn:self];
        }
    }
}

#pragma mark -
- (IBAction)clickBackground:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)clickCancel:(id)sender {
    switch (_serviceBindType) {
        case kServiceSharepointOnline:
            [_auth cancelLogin];
            break;
        case kServiceSharepoint:
            //TBD authentication
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(cloudAccountUserInfoVCDidPressCancelBtn:)]) {
        [self.delegate cloudAccountUserInfoVCDidPressCancelBtn:self];
    }
}

- (IBAction)btnAddAccount:(id)sender {
    if (_isConnecting) {
        return;
    }
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_NETWORK_UNREACH", NULL)];
        return;
    }
    
    NSString *err = nil;
    if (self.serviceBindType == kServiceSharepointOnline) {
        if (self.spSiteURL.text.length <=0) {
            err = NSLocalizedString(@"SHAREPOINT_ONLINE_SITE_EMPTYERROR", NULL);;
        }
    }
    
    if (self.serviceBindType == kServiceSharepoint) {
        if (self.spSiteURL.text.length <=0) {
            err = NSLocalizedString(@"SHAREPOINT_SITE_EMPTYERROR", NULL);;
        }
        
        if(!self.spUserName.text.length){
            err = NSLocalizedString(@"ERROR_EMPTYUSERNAME", NULL);
        }
        
        if(!self.spPassword.text.length){
            err = NSLocalizedString(@"ERROR_EMPTYPASSWORD", NULL);
        }
    }
  
    if (err) {
        [NXMBManager showMessage:err toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    if (!err) {
         self.spSiteURL.text = [self.spSiteURL.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    // trim the last '/' of url
    NSInteger count = 0;
    NSInteger stringLength = self.spSiteURL.text.length;
    unichar charBuffer[self.spSiteURL.text.length];
    [self.spSiteURL.text getCharacters:charBuffer];
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    for (NSInteger i = stringLength - 1; i >= 0; i--) {
        if (![charSet characterIsMember:charBuffer[i]]) {
            break;
        }
        count++;
    }
    
    self.absoultSPULR = [self.spSiteURL.text substringToIndex:(stringLength - count)];
//    self.absoultSPULR = [self.absoultSPULR stringByAppendingString:@"/"];
    
    
    switch (_serviceBindType) {
        case kServiceSharepoint:
        {
            if ([self checkLocalIsAlreadyExistSameSharePoint:self.absoultSPULR]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    NSString* err = NSLocalizedString(@"Sharepoint_ALREADY_EXIST_ERROR", nil);
                    [NXMBManager showMessage:err toView:self.view hideAnimated:YES afterDelay:kDelay];
                }); // main thread
                return;
            }else{
                _spMgr = [[NXSharePointManager alloc] initWithSiteURL:self.absoultSPULR userName:self.spUserName.text passWord:self.spPassword.text Type:kSPMgrSharePoint];
                _spMgr.delegate = self;
                [_spMgr authenticate];
            }
        }
            break;
        case kServiceSharepointOnline:
        {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (self.absoultSPULR.length > 0 && self.siteUrlEnterFinishedBlock) {
                     _AuthCanceled = NO;
                     self.siteUrlEnterFinishedBlock(_absoultSPULR);
                 }else{
                      self.siteUrlEnterFinishedBlock(nil);
                 }
             });
        }
            break;
        default:
            break;
    }
    
    if (_serviceBindType == kServiceSharepoint) {
        _isConnecting = YES;
        [NXMBManager showLoadingToView:self.view];
    }
}

- (BOOL)checkLocalIsAlreadyExistSameSharePoint:(NSString *)siteUrl
{
    NSArray *repoArray = [[NXLoginUser sharedInstance].myRepoSystem allReposiories];
    for (NXRepositoryModel *repoModel in repoArray) {
        if (repoModel.service_type.integerValue == kServiceSharepoint ) {
            BOOL result = [repoModel.service_account caseInsensitiveCompare:siteUrl] == NSOrderedSame;
            if (result && [repoModel.service_isAuthed boolValue] == YES) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark
- (NSArray<NXAccountInputCellModel *> *)dataArray {
    if (!_dataArray) {
        NXAccountInputCellModel *url;
        if (self.serviceBindType == kServiceSharepointOnline) {
          url = [[NXAccountInputCellModel alloc] initWithText:nil placeholder:NSLocalizedString(@"Enter your site URL", NULL) prompt:NSLocalizedString(@"Sharepoint Online Site URL", NULL)];
             _dataArray = @[url];
        }
        else
        {
            url = [[NXAccountInputCellModel alloc] initWithText:nil placeholder:NSLocalizedString(@"Enter your site URL", NULL) prompt:NSLocalizedString(@"Sharepoint Site URL", NULL)];
            NXAccountInputCellModel *name= [[NXAccountInputCellModel alloc] initWithText:nil placeholder:NSLocalizedString(@"Enter your domain/Username", NULL) prompt:NSLocalizedString(@"Domain/Username", NULL)];
            NXAccountInputCellModel *address  = [[NXAccountInputCellModel alloc] initWithText:nil placeholder:NSLocalizedString(@"Enter your password", NULL) prompt:NSLocalizedString(@"Password", NULL)];
            _dataArray = @[url, name, address];
        }
    }
    return _dataArray;
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
    self.navigationItem.title = navigationTitle;
}


#pragma mark - NXSharePointManagerDelegate
-(void) didAuthenticationFail:(NSError*) error forQuery:(SPQueryIdentify)type
{
    if (_isReAuth == YES && self.repoId.length > 0) {
//        self.addRepoAccountFinishBlock = nil;
//        return ;
    }
    
    _isConnecting = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        NSString* err;
        if (error) {
            err = NSLocalizedString(@"Sharepoint_SITE_URL_ERROR", nil);
        }else
        {
            err = NSLocalizedString(@"Sharepoint_SIGNIN_ERROR", nil);
        }
        
        if (error.localizedDescription) {
            err = error.localizedDescription;
        }
        

        [NXMBManager showMessage:err toView:self.view hideAnimated:YES afterDelay:kDelay];
    }); // main thread
}

-(void) didAuthenticationSuccess
{
    _isConnecting = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        // account authen success, store it
        // step1. sotre siteUrl as account and account_id
        // Sharepoint accountid:  siteURL^userName
        
        [NXMBManager hideHUDForView:self.view];
        
        NSString* sharepointAccountId = [NSString stringWithFormat:@"%@^%@", self.absoultSPULR, self.spUserName.text];
        
        NSDictionary *authResultDict = @{AUTH_RESULT_ALIAS:self.repoName,
                                         AUTH_RESULT_REPO_TYPE:[NSNumber numberWithInteger:kServiceSharepoint],
                                         AUTH_RESULT_ACCOUNT:self.absoultSPULR,
                                         AUTH_RESULT_ACCOUNT_ID:sharepointAccountId,
                                         };

        NXRMCRepoItem *repoItem = [NXRMCRepoItem new];

        repoItem.service_account = authResultDict[AUTH_RESULT_ACCOUNT];
        repoItem.service_account_token = @"";
        repoItem.service_account_id = authResultDict[AUTH_RESULT_ACCOUNT_ID];
        repoItem.service_type = authResultDict[AUTH_RESULT_REPO_TYPE];
        repoItem.service_id = authResultDict[AUTH_RESULT_REPO_ID];
        repoItem.service_selected = [NSNumber numberWithBool:YES];
        repoItem.user_id = authResultDict[AUTH_RESULT_USER_ID];
        repoItem.service_isAuthed = YES;
        repoItem.service_alias = authResultDict[AUTH_RESULT_ALIAS];
        
        if (_isReAuth == YES && self.repoId.length > 0) {
            [NXKeyChain save:sharepointAccountId data:self.spPassword.text];
            repoItem.service_id = self.repoId;
            NXRepositoryModel *repoModel = [[NXRepositoryModel alloc] initWithRMCRepoModel:repoItem];
            self.addRepoAccountFinishBlock(repoModel,nil);
            return ;
        }
        
        NXAddRepositoryAPIRequest *request = [[NXAddRepositoryAPIRequest alloc] initWithAddRepoItem:repoItem];
        WeakObj(self);
        [request requestWithObject:repoItem Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            StrongObj(self);
            NXAddRepositoryAPIResponse *rsp = (NXAddRepositoryAPIResponse *)response;
            if (rsp.rmsStatuCode == 200 && !error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *authDict = @{AUTH_RESULT_REPO_ID:rsp.repoId,
                                               AUTH_RESULT_ALIAS:self.repoName,
                                               AUTH_RESULT_REPO_TYPE:[NSNumber numberWithInteger:kServiceSharepoint],
                                               AUTH_RESULT_ACCOUNT:self.absoultSPULR,
                                               AUTH_RESULT_ACCOUNT_ID:sharepointAccountId,
                                               };
                    
                     [NXKeyChain save:sharepointAccountId data:self.spPassword.text];
                    _AuthCanceled = NO;
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(cloudAccountUserInfoDidAuthSuccess:))) {
                        [self.delegate cloudAccountUserInfoDidAuthSuccess:authDict];
                    }
                    self.addRepoAccountFinishBlock(nil,nil);
                });
            }
            else{
                NSString *errorMsg ;
                if (error.localizedDescription.length > 0) {
                    errorMsg = error.localizedDescription;
                }
                else
                {
                    errorMsg = rsp.rmsStatuMessage;
                }
                  dispatch_async(dispatch_get_main_queue(), ^{
                        [NXMBManager showMessage:errorMsg toView:self.view hideAnimated:YES afterDelay:kDelay];
                  });
            }
        }];
    }); // main thread
}

#pragma mark - NXSharepointOnlineDelegete

- (void) Authentication:(NXSharepointOnlineAuthentication *)auth didAuthenticateSuccess:(NXSharePointOnlineUser *)user {
    _isConnecting = NO;
    //token = fedauthInfo + rtfaInfo; accountId = siturl + username(distinguish different sharepointonline user)
    NSLog(@"SharepointOnline Authentication success username:%@, siteurl:%@", user.username, user.siteurl);
    
   _sharepointOnlineAccountId = [NSString stringWithFormat:@"%@^%@", self.absoultSPULR, self.spUserName.text];
   _sharepointOnlineToken = [NSString stringWithFormat:@"%@^%@", user.fedauthInfo, user.rtfaInfo];
    
    //
    NSDictionary *fedAuthCookie = [NSDictionary dictionaryWithObjectsAndKeys:
                                   user.siteurl, NSHTTPCookieOriginURL,
                                   @"FedAuth", NSHTTPCookieName,
                                   @"/", NSHTTPCookiePath,
                                   user.fedauthInfo, NSHTTPCookieValue,
                                   nil];
    
    NSDictionary *rtFaCookie = [NSDictionary dictionaryWithObjectsAndKeys:
                                user.siteurl, NSHTTPCookieOriginURL,
                                @"rtFa", NSHTTPCookieName,
                                @"/", NSHTTPCookiePath,
                                user.rtfaInfo, NSHTTPCookieValue,
                                nil];
    
    
    NSHTTPCookie *fedAuthCookieObj = [NSHTTPCookie cookieWithProperties:fedAuthCookie];
    NSHTTPCookie *rtFaCookieObj = [NSHTTPCookie cookieWithProperties:rtFaCookie];
    
    NSArray *cookiesArray = @[fedAuthCookieObj, rtFaCookieObj];
    _spMgr = [[NXSharePointManager alloc] initWithURL:user.siteurl cookies:cookiesArray Type:kSPMgrSharePointOnline];
    _spMgr.delegate = self;
    [_spMgr allDocumentLibListsOnSite];
    
}

- (void) Authentication:(NXSharepointOnlineAuthentication *)auth didAuthenticateFailWithError:(NSString *)error {
    _isConnecting = NO;
    
    DLog(@"SharepointOnline Authentication failed %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        NSString *err = nil;
        if ([error isEqualToString:@"get cookies failed"]) {
            err = NSLocalizedString(@"SharepointOnline_SIGNIN_ERROR", NULL);
        } else {
            err = NSLocalizedString(@"SharepointOnline_SITE_URL_ERROR", NULL);
        }
        
        [NXMBManager showMessage:err toView:self.view hideAnimated:YES afterDelay:kDelay];
     
    }); // main thread
}

-(void) didFinishSPQuery:(NSArray*) result forQuery:(SPQueryIdentify) type
{
    NSString *account = self.spUserName.text;
    NSString *accountID = self.sharepointOnlineAccountId;
    NSString *accountToken = self.sharepointOnlineToken;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if ([weakSelf.delegate respondsToSelector:@selector(cloudAccountUserInfoDidAuthSuccess:)]) {
                NSDictionary *dict = @{AUTH_RESULT_ACCOUNT:account, AUTH_RESULT_ACCOUNT_ID:accountID, AUTH_RESULT_ACCOUNT_TOKEN:accountToken, AUTH_RESULT_REPO_TYPE:[NSNumber numberWithInteger:_serviceBindType]};
                [weakSelf.delegate cloudAccountUserInfoDidAuthSuccess:dict];
            }
        }];
    }); // main thread

}

-(void) didFinishSPQueryWithError:(NSError*) error forQuery:(SPQueryIdentify) type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        [NXMBManager showMessage:NSLocalizedString(@"SharepointOnline_SITE_URL_ERROR", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
    }); //
}

-(void) inputServiceDisplayName:(void(^)(NSString *))finishBlock
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: [NXCommonUtils currentBundleDisplayName]
                                                                              message: NSLocalizedString(@"UI_COM_INPUT_REPO_NAME", NULL)
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"name";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * displayName = textfields[0];
        if ([displayName.text isEqualToString:@""]) {
            return;
        }
        finishBlock(displayName.text);
        __strong NXCloudAccountUserInforViewController* strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXAccountInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.model = self.dataArray[indexPath.row];
    
    if (indexPath.row == 2) {
        cell.textField.secureTextEntry = YES;
        self.spPassword = cell.textField;
    }
    
    if (indexPath.row == 1) {
        self.spUserName = cell.textField;
    }
    if (indexPath.row == 0) {
        self.spSiteURL = cell.textField;
    }
    
    return cell;
}


#pragma mark
- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:238.0/255.0 alpha:1.0];
    promptLabel.text = @"Provider SharePoint Credentials to connect";
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont systemFontOfSize:12.0];
    self.promptLabel = promptLabel;
    [self.view addSubview:promptLabel];
    
    UITableView *tableView = [[UITableView alloc] init];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    UIButton *addButton = [[UIButton alloc] init];
    
    tableView.estimatedRowHeight = 44;
    tableView.sectionFooterHeight = 0.01;
    tableView.sectionHeaderHeight = 0.01;
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    
    [tableView.tableFooterView addSubview:addButton];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[NXAccountInputCell class] forCellReuseIdentifier:@"cell"];
    
    [addButton setTitle:NSLocalizedString(@"Connect", NULL) forState:UIControlStateNormal];
    addButton.backgroundColor = RMC_MAIN_COLOR;
    [addButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(btnAddAccount:) forControlEvents:UIControlEventTouchUpInside];
    [addButton cornerRadian:3];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.height.equalTo(@(30));
    }];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(promptLabel.mas_bottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(addButton.superview);
        make.width.equalTo(addButton.superview).multipliedBy(0.7);
        make.height.equalTo(addButton.superview).multipliedBy(0.5);
    }];
}

@end
