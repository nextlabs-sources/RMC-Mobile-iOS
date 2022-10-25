//
//  NXProfileViewController.m
//  AlphaVC
//
//  Created by helpdesk on 8/11/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXProfileViewController.h"

#import "NXRepositoryViewController.h"
#import "NXAccountViewController.h"
#import "NXLoginNavigationController.h"
#import "NXURLViewController.h"

#import "Masonry.h"
#import "NXProfileFooterView.h"
#import "NXProfileHeaderView.h"
#import "NXProfileSectionHeaderView.h"
#import "NXProfileCell.h"
#import "NXProfileRepoView.h"

#import "NXProfilePageCellModel.h"
#import "NXGetProfileAPI.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
#import "UIImage+Cutting.h"
#import "NXSyncRepoHelper.h"
#import "NXCacheManager.h"
#import "AppDelegate.h"
#import "NXSetPwdViewController.h"
#import "NXAboutSkyDRMViewController.h"
#import "NXPreferencesViewController.h"
#import "UIView+Extension.h"
#import "NXChangeServerURLView.h"
#import "NXRouterLoginPageURL.h"
#import "NXSetSeverURLView.h"
#import "NXOfflineFileManager.h"
#import "NXLProfile.h"
#import "NXLoginUser.h"
#import "NXOpenSourceLicensesViewController.h"
#define kHeaderViewHeight 160

@interface NXProfileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
//@property(nonatomic, weak) NXProfileRepoView *repoView;
@property(nonatomic, weak) NXProfileRepoView *changePassWordView;
@property(nonatomic, weak) NXProfileHeaderView *headerView;

@property(nonatomic, assign) BOOL isSyncing;

@property(nonatomic, strong) NSArray<NSArray<NXProfilePageCellModel*> *> *tableData;
@property(nonatomic, assign) BOOL canChangingPsword;
@end

@implementation NXProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundRepositoryDidUpdate:) name:NOTIFICATION_REPO_UPDATED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated:) name:NOTIFICATION_USER_INFO_UPDATED object:nil];
}

//- (void)boundRepositoryDidUpdate:(NSNotification *)notificaiton
//{
//    [self.repoView updateData];
//}

- (void)userInfoUpdated:(NSNotification *)notification
{
    [self.headerView updateUserInfoData:[NXLoginUser sharedInstance].profile.avatar name:[NXLoginUser sharedInstance].profile.userName email:[NXLoginUser sharedInstance].profile.email];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
    //    [self.repoView updateData];
    
    NSString *avatarImageStr = [NXLoginUser sharedInstance].profile.avatar;
    NSString *userNameStr = [NXLoginUser sharedInstance].profile.displayName;
    NSString *userEmailStr = [NXLoginUser sharedInstance].profile.email;

    [self.headerView updateUserInfoData:avatarImageStr name:userNameStr email:userEmailStr];
    
   
    
    NXGetProfileAPI *api = [[NXGetProfileAPI alloc] init];
    WeakObj(self);
    [api requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            DLog(@"%@", error.localizedDescription);
            return;
        }
        StrongObj(self);
        NXGetProfileResponse *ret = (NXGetProfileResponse *)response;
        if (ret.rmsStatuCode != 200) {
            DLog(@"%@", ret.rmsStatuMessage);
            return;
        }
        
        NXLProfile *profile = [[NXLoginUser sharedInstance] profileWithUserinfo:ret.result];
        NSString *avatar = [avatarImageStr isEqualToString:profile.avatar]?nil:profile.avatar;
        NSString *name = [userNameStr isEqualToString:profile.displayName]?nil:profile.displayName;
        NSString *email = [userEmailStr isEqualToString:profile.email]?nil:profile.email;
        
        if(avatar || name || email){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NXLoginUser sharedInstance] updateUserinfo:ret.result];
                [self.headerView updateUserInfoData:avatar name:name email:email];
            });
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN object:nil];
   
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView bringSubviewToFront:self.changePassWordView];
    self.changePassWordView.backgroundColor = [UIColor whiteColor];
}

- (NSArray<NSArray *> *)tableData {
    if (!_tableData) {
        NXProfilePageCellModel *session = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"UI_PROFILE_SESSION", NULL) message:@""operation:@""];
        NXProfilePageCellModel *sync = [[NXProfilePageCellModel alloc] initWithTitle:NSLocalizedString(@"UI_PROFILE_LAST_SYNC", NULL) message:@""operation:NSLocalizedString(@"UI_PROFILE_SYNC_NOW", NULL)];
        NXProfilePageCellModel *cache = [[NXProfilePageCellModel alloc] initWithTitle:NSLocalizedString(@"UI_PROFILE_CACHE", NULL) message:@""operation:NSLocalizedString(@"UI_PROFILE_CLEAN", NULL)];
        NXProfilePageCellModel *serverURL = [[NXProfilePageCellModel alloc] initWithTitle:NSLocalizedString(@"UI_PROFILE_SERVER_URL", NULL) message:[NXCommonUtils isCompanyAccountLogin] ? [NXCommonUtils getUserCurrentSelectedLoginURL] : [NXCommonUtils getDefaultPresonalLoginURL] operation:@""];
        
        NXProfilePageCellModel *preferences = [[NXProfilePageCellModel alloc] initWithTitle:NSLocalizedString(@"UI_PROFILE_PREFERENCES", NULL) message:@"" operation:@""];
//        NXProfilePageCellModel *licenses = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"UI_PROFILE_OPEN_LICENSES", NULL) message:@"" operation:@""];
        NXProfilePageCellModel *help = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"UI_PROFILE_HELP", NULL) message:@""operation:@""];
        NXProfilePageCellModel *contact = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"UI_PROFILE_CONTACT", NULL) message:@""operation:@""];
        
        NXProfilePageCellModel *aboutSkyDrm = nil;
        if (buildFromSkyDRMEnterpriseTarget) {
            aboutSkyDrm = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"UI_ABOUT_SKYDRM_PRO", NULL) message:@""operation:@""];
        }else {
            aboutSkyDrm = [[NXProfilePageCellModel alloc]initWithTitle:NSLocalizedString(@"UI_PROFILE_ABOUTSKYDRM", NULL) message:@""operation:@""];
        }
//        _tableData = @[@[], @[session, sync, cache], @[licence, help, contact]];
        _tableData = @[@[], @[session, sync, serverURL,cache], @[preferences,help,contact,aboutSkyDrm]];
    }
    return _tableData;
}

- (void)reloadData {
    NXProfilePageCellModel *sesstion = self.tableData[1][0];
    sesstion.message = [NXCommonUtils sessionTimeOutString];
    NXProfilePageCellModel *lastSync = self.tableData[1][1];
    
    lastSync.message = [NXCommonUtils displaySyncDateString];
    
    [self.tableView reloadData];
}

- (void)sync {
    self.isSyncing = YES;
    [NXMBManager showLoadingToView:self.view];
    WeakObj(self);
   [[NXLoginUser sharedInstance].myRepoSystem syncRepositoryWithCompletion:^(NSArray *repoArray, NSTimeInterval syncTime, NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           StrongObj(self);
           [NXMBManager hideHUDForView:self.view];
           NXSyncDateModel *dataModel = [[NXSyncDateModel alloc] initWithDate:[NSDate date] successed:error?NO:YES];
           [NXCommonUtils storeSyncDateModel:dataModel];
           [self reloadData];
           self.isSyncing = NO;
           if(error){
               NSString *errorMsg = error.localizedDescription?:NSLocalizedString(@"MSG_COM_UPDATE_REPO_INFO_ERROR", nil);
               [NXMBManager showMessage:errorMsg hideAnimated:YES afterDelay:kDelay];
           }
           
//           NSString *repoId;
//           for (NXRepositoryModel *model in repoArray) {
//               if ([model.service_type.stringValue isEqualToString:@"0"]) {
//                   repoId = model.service_id;
//                   break;
//               }
//           }
       });
   }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!self.canChangingPsword) {
        return 30;
    }
    return  section?30:50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bgView= [[UIView alloc]init];
    bgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NXProfileSectionHeaderView *headerView = [[NXProfileSectionHeaderView alloc]init];
    headerView.model = @[NSLocalizedString(@"UI_PROFILE_SECTION_SESSION", NULL), NSLocalizedString(@"UI_PROFILE_SECTION_ABOUT", NULL), @""][section];
    [bgView addSubview:headerView];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(bgView.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(bgView.mas_safeAreaLayoutGuideRight);
                make.top.equalTo(bgView.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(bgView.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }else {
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(bgView);
        }];
    }
    return bgView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NXProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifier"];
    if (!cell) {
        cell = [[NXProfileCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"kCellIdentifier"];
    }
    
    cell.messageLabel.font = [UIFont systemFontOfSize:14];
    cell.messageLabel.textColor = [UIColor colorWithRed:40/256.0 green:125/256.0 blue:240/256.0 alpha:1];
//    if (indexPath.section == 1 && indexPath.row == 2) {
//        cell.messageLabel.textColor = RMC_MAIN_COLOR;
//        cell.messageLabel.font = [UIFont boldSystemFontOfSize:16];
//    } else if (indexPath.section == 1 && indexPath.row == 1) {
//        if (![NXCommonUtils userSyncDateModel].syncSuccessed) {
//            cell.messageLabel.textColor = [UIColor redColor];
//        } else {
//            cell.messageLabel.textColor = [UIColor darkGrayColor];
//        }
//    } else {
//        cell.messageLabel.textColor = [UIColor darkGrayColor];
//        
//    }
    if (indexPath.section == 1 ) {
        cell.accssViewHidden = YES;
    } else {
        cell.accssViewHidden = NO;
    }

    NXProfilePageCellModel *model = self.tableData[indexPath.section][indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: //session
            {
                
            }
                break;
            case 1: //Last Sync
            {
                if (!self.isSyncing) {
                    [self sync];
                }
            }
                break;
            case 2: // server url
            {

            }
                break;
            case 3: // Cache
            {
                WeakObj(self);
                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_PROFILE_CONFIRM_CLEAN_CACHE", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
                    StrongObj(self);
                    [self cleanCache];
                } cancelActionHandle:nil inViewController:self position:self.view];
            }
                break;
            default:
                break;
        }
    }
    if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0://preferences
            {
                NXPreferencesViewController * vc = [[NXPreferencesViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
//            case  1://licenses
//            {
////                NXOpenSourceLicensesViewController *licensesVC = [[NXOpenSourceLicensesViewController alloc] init];
////
////                [self.navigationController pushViewController:licensesVC animated:YES];
//
//            }
//                break;
            case 1: //Help
            {
                NSURL *helpUrl;
                if ([NXCommonUtils isCompanyAccountLogin]) {
                    NSString *severUrl = [NXCommonUtils getRmServer];
                    helpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",severUrl,@"/help_clients/ios/index.html"]];
                }else{
                    helpUrl = [NSURL URLWithString:SKYDRM_HELP_URL];
                }
                NXURLViewController *urlVC = [[NXURLViewController alloc] init];
                urlVC.url = helpUrl;
                urlVC.hidesBottomBarWhenPushed = YES;
                urlVC.navigationItem.title = NSLocalizedString(@"UI_PROFILE_HELP", NULL);
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.primaryNavigationController pushViewController:urlVC animated:YES];
            }
                break;
            case 2: //Contact
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://support@skydrm.com"] options:@{} completionHandler:nil];
            }
                break;
            case 3:// about skyDRM
            {
                NXAboutSkyDRMViewController *aboutSkyDRMVC = [[NXAboutSkyDRMViewController alloc]init];
                aboutSkyDRMVC.hidesBottomBarWhenPushed = YES;
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.primaryNavigationController pushViewController:aboutSkyDRMVC animated:YES];
            }
            default:
                break;
        }
    }
}

#pragma mark
- (void)logOut:(id)sender {
    BOOL hasMarkingTask = [[NXOfflineFileManager sharedInstance] hasMarkingAsOfflinedFile];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:hasMarkingTask? NSLocalizedString(@"MSG_SIGN_OUT_WHEN_HAS_MARINTASK", NULL):NSLocalizedString(@"MSG_SIGN_OUT_ALERT_MESSAGE", NULL) style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action)  {
        if ([[NXLoginUser sharedInstance] isLogInState]) {
            if (hasMarkingTask) {
                [[NXOfflineFileManager sharedInstance] cancelAllMarkTask];
                [[NXLoginUser sharedInstance] logOut];
            }else{
                [[NXLoginUser sharedInstance] logOut];
            }
            
        }
        NXLoginNavigationController *nav = [[NXLoginNavigationController alloc] init];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    } cancelActionHandle:nil inViewController:self position:sender];
}

- (void)cleanCache {
    NSNumber *cacheSize = [NXCommonUtils calculateCachedFileSize];
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.allowsNonnumericFormatting = NO;
    formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    NSString *strSize = [formatter stringFromByteCount:cacheSize.longLongValue];
    NSString *info = [NSString stringWithFormat:@"%@: %@%@. %@", NSLocalizedString(@"MSG_PROFILE_CLEAN_CACHE_SUSSESS", NULL),@"\n", strSize, NSLocalizedString(@"", NULL)];
    [NXCommonUtils deleteCachedFilesOnDisk];
    [NXMBManager showMessage:info image:[UIImage imageNamed:@"repo selected - green"] hideAnimated:YES afterDelay:kDelay];
}

#pragma mark
- (void)commonInit {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.title = NSLocalizedString(@"UI_PROFILE_PROFILE", NULL);
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_COM_PROFILE_LOGOUT", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //init background view when pull down tablview.
    UIView *backgroundView = [[UIView alloc] init];
    [self.view addSubview:backgroundView];
    
    //init tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    NXProfileHeaderView *headerView = [[NXProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kHeaderViewHeight)];
    
//    NXProfileFooterView *footerView = [[NXProfileFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 160)];
    
    NXProfileRepoView *changepPswView = [[NXProfileRepoView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [tableView addSubview:changepPswView];
    
    backgroundView.backgroundColor = RMC_MAIN_COLOR;
    
    tableView.tableHeaderView = headerView;
//    tableView.tableFooterView = footerView;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 50;
    
    tableView.backgroundColor = [UIColor clearColor];
    
    headerView.nameLabel.text = [NXLoginUser sharedInstance].profile.userName;
    headerView.emailLabel.text = [NXLoginUser sharedInstance].profile.email;
    headerView.tapclickBlock = ^(id sender){
        NXAccountViewController  *vc = [[NXAccountViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.spliteViewController showDetailViewController:vc sender:self];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    changepPswView.tapclickBlock = ^(id sender){
//        NXRepositoryViewController *vc = [[NXRepositoryViewController alloc] init];
    NXSetPwdViewController *setPwdVC = [[NXSetPwdViewController alloc]init];
        setPwdVC.hidesBottomBarWhenPushed = YES;
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.spliteViewController showDetailViewController:setPwdVC sender:self];
        [self.navigationController pushViewController:setPwdVC animated:YES];
       
    };
    changepPswView.hidden = YES;
    changepPswView.userInteractionEnabled = NO;
    self.canChangingPsword = NO;
//    if ([NXLoginUser sharedInstance].profile.idpType && [NXLoginUser sharedInstance].profile.idpType.integerValue == 0/*DB*/) {
//        self.canChangingPsword = YES;
//    } else {
//        changepPswView.hidden = YES;
//        changepPswView.userInteractionEnabled = NO;
//        self.canChangingPsword = NO;
//    }
    
    self.headerView = headerView;
    self.changePassWordView = changepPswView;
    self.tableView = tableView;
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.25);
    }];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    CGFloat height = 44;
    
    [changepPswView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tableView).offset(kHeaderViewHeight - height/2);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
        make.height.equalTo(@(height));
    }];
}

@end
