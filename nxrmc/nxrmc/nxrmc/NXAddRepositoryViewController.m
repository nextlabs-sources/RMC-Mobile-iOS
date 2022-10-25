//
//  NXAddRepositoryViewController.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAddRepositoryViewController.h"

#import "Masonry.h"

#import "NXProfileSectionHeaderView.h"
#import "UIView+UIExt.h"

#import "NXAddRepoPageCellModel.h"
#import "NXRepoAuthStrategy.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
#import "NXCloudAccountUserInforViewController.h"
#import "NXMasterTabBarViewController.h"

@interface NXAddRepositoryViewController ()<UITableViewDelegate, UITableViewDataSource, NXRepositorySysManagerBoundRepoDelegate>

@property(nonatomic, weak) UITableView *tableView;
//@property(nonatomic, weak) UIButton *closeButton;

@property(nonatomic, strong) NSMutableArray<NXAddRepoPageCellModel *> *dataArray;

@property(nonatomic, strong) id<NXRepoAutherBase> repoAuther;
//@property(nonatomic, strong) UIView *navigatonView;
@end

@implementation NXAddRepositoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repoAdded:) name:NOTIFICATION_REPO_ADDED object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
- (void)closeButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
- (NSMutableArray<NXAddRepoPageCellModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        NSArray *serviceTypes = [[NXLoginUser sharedInstance].myRepoSystem allSupportedServiceTypes];
        for (NSNumber *serviceType in serviceTypes) {
            if (serviceType.intValue < kServiceOneDriveApplication) {
                [_dataArray addObject:[[NXAddRepoPageCellModel alloc] initWithServiceType:serviceType.integerValue]];
            }
        }
    }
    return _dataArray;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NXProfileSectionHeaderView *headerView = [[NXProfileSectionHeaderView alloc] init];
    headerView.model = NSLocalizedString(@"UI_SELECT_PROVIDER", NULL);
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
        [accessoryView setFrame:CGRectMake(0, 0, 20, 20)];
        cell.accessoryView = accessoryView;
    }
    
    NXAddRepoPageCellModel *model = self.dataArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:model.imagename];
    cell.textLabel.text = model.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXAddRepoPageCellModel *model = self.dataArray[indexPath.row];
    [[NXLoginUser sharedInstance].myRepoSystem boundRepositoryInViewController:self repoType:model.type withDelegate:self];
}

#pragma mark - repo notification
- (void) repoAdded:(NSNotification *) notification {
    [NXMBManager hideHUDForView:self.view];
    if([notification.userInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary *addRepoResultDict = (NSDictionary *) notification.userInfo;
        if (addRepoResultDict[NOTIFICATION_REPO_ADDED_ERROR_KEY]) {  // error happens when user add repo info to local
            NSString *errorString = addRepoResultDict[NOTIFICATION_REPO_ADDED_ERROR_KEY];
            if ([errorString isEqualToString:RMS_ADD_REPO_ERROR_NET_ERROR] || [errorString isEqualToString:RMS_ADD_REPO_RMS_OTHER_ERROR]) {
                
                [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_ADD_REPO_SYNC_RMS_ERROR", nil)];
            }else if([errorString isEqualToString:RMS_ADD_REPO_DUPLICATE_NAME])
            {
                [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_ADD_REPO_ACCOUNT_DISPLAY_NAME_DUMPLICATE", nil)];
            }else if([errorString isEqualToString:RMS_ADD_REPO_ALREADY_EXIST])
            {
                [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_REPO_ACCOUNT_EXISTED", nil)];
            }
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inputServiceDisplayName:(void(^)(NSString *))finishBlock {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: [NXCommonUtils currentBundleDisplayName]
                                                                              message: NSLocalizedString(@"UI_COM_INPUT_REPO_NAME", NULL)
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Can not contain special characters";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
    }];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * displayNameTextField = textfields[0];
        NSString *displayName = displayNameTextField.text;
        displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![self isEnableTextFieldNameWithStr:displayName]) {
            [self inputServiceDisplayName:finishBlock];
            return ;
        }
        finishBlock(displayName);
        __strong NXAddRepositoryViewController* strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)commonInit {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = NSLocalizedString(@"UI_CONNECT", NULL);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClicked:)];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    self.tableView = tableView;
}

#pragma mark - NXRepositorySysManagerBoundRepoDelegate
- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr boundRepo:(NXRepositoryModel *)repo inputRepositoryAliasHandler:(void(^)(NXRepositorySysManagerBoundRepoInputAliasOption processOpt, NSString *inputAlias)) processHandler
{
    WeakObj(self); 
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongObj(self);
        [self inputServiceDisplayName:^(id dispalyName) {
            if ([dispalyName isKindOfClass:[NSString class]]) {
                // Check multi-character
                if ([NXCommonUtils checkStringContainMultiByte:dispalyName]) {
                    [NXMBManager showMessage:[NSString stringWithFormat:NSLocalizedString(@"UI_REPO_NAME_CONTAINS_INVALID_CHARACTERS", NULL)] hideAnimated:YES afterDelay:2.0];
                    return;
                }
                // if user input name
                //[NXMBManager showLoadingToView:self.view];
                BOOL shouldProcess = YES;
                for (NXBoundService *service in [NXRepositoryStorage loadAllBoundServices]) {
                    if ([service.service_alias isEqualToString:dispalyName]) {
                        shouldProcess = NO;
                        [NXMBManager showMessage:[NSString stringWithFormat:NSLocalizedString(@"MSG_AUTH_REPOSITORY_ALREADY_EXISTED", NULL),dispalyName] hideAnimated:YES afterDelay:2.0];
                          [NXMBManager hideHUDForView:self.view];
                        break;
                    }
                }
                if (shouldProcess) {
                    processHandler(NXRepositorySysManagerBoundRepoInputAliasProcess, dispalyName);
                }
            }else{
                processHandler(NXRepositorySysManagerBoundRepoInputAliasCancel, nil);
                [NXMBManager hideHUDForView:self.view];
                [self.navigationController popViewControllerAnimated:NO];
            }
            
        }];

    });
}

- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr didSuccessfullyBoundRepo:(NXRepositoryModel *)repo
{
    WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongObj(self);
        [NXMBManager hideHUDForView:self.view];
        [self.navigationController popViewControllerAnimated:NO];
        [self.tabBarController setSelectedIndex:kNXMasterTabBarControllerIndexRepositories];

    });
}
- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr didFailedBoundRepo:(NXRepositoryModel *)repo withError:(NSError *)error
{
    WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongObj(self);
        NSString *alertContent = @"";
        if (error.localizedDescription) {
            alertContent = error.localizedDescription;
        }else{
            switch (repo.service_type.integerValue) {
                case kServiceGoogleDrive:
                {
                    alertContent = NSLocalizedString(@"GOOGLEDRIVE_SIGNIN_ERROR", NULL);
                }
                    break;
                case kServiceDropbox:
                {
                    alertContent = NSLocalizedString(@"DROPBOX_SIGNIN_ERROR", NULL);
                }
                    break;
                case kServiceOneDrive:
                {
                    alertContent = NSLocalizedString(@"ONEDRIVE_GETUSERINFO_FAIL", NULL);
                }
                    break;
                case kServiceSharepointOnline:
                {
                    alertContent = NSLocalizedString(@"SharepointOnline_BOUND_ERROR", NULL);
                }
                    break;
                case kServiceBOX:
                {
                    alertContent = NSLocalizedString(@"Box_SIGNIN_ERROR", NULL);
                }
                    break;
                default:
                    break;
            }
        }
       
        [NXCommonUtils showAlertViewInViewController:self
                                               title:[NXCommonUtils currentBundleDisplayName]
                                             message:alertContent];
        [NXMBManager hideHUDForView:self.view];
    });
}
- (void)nxRepositorySysManager:(NXRepositorySysManager *)repoSysMgr didCancelBoundRepo:(NXRepositoryModel *)repo
{
    WeakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongObj(self);
        [NXMBManager hideHUDForView:self.view];
    });
}

- (BOOL)isEnableTextFieldNameWithStr:(NSString *)str {
    if([str isEqualToString:@""])
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_PLESASE_INPUT_NAME", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }else if(str.length>40)
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_LENGTH_TOOLONG_WARNING_LIMIT_40", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }else if ([NXCommonUtils JudgeTheillegalCharacter:str withRegexExpression:@"^[\\w- ]+$"]) {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_CONTAIN_SPECIAL_WARNING", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }
    return YES;
}
@end
