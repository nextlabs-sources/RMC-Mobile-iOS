//
//  NXRepositoryViewController.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRepositoryViewController.h"

#import "NXAddRepositoryViewController.h"
#import "NXRepositoryInfoViewController.h"

#import "NXRepositoryHeaderView.h"
#import "Masonry.h"
#import "NXNormalCell.h"
#import "NXProfileSectionHeaderView.h"
#import "UIView+UIExt.h"
#import "NXMBManager.h"
#import "UIImage+ColorToImage.h"

#import "NXLoginUser.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "AppDelegate.h"
#import "NXFileChooseFlowViewController.h"
#import "NXCloudAccountUserInforViewController.h"
#import "NXLProfile.h"
@interface NXRepositoryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;

@property(nonatomic, strong) NSArray *tableArray;
@property(nonatomic, strong) NSDictionary *repoIconDict;

@end

@implementation NXRepositoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToRepositoryUpdate:) name:NOTIFICATION_REPO_UPDATED object:nil];
    [self commonInit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark

- (void)addRepoButtonClicked:(id)sender {
    NXAddRepositoryViewController *vc = [[NXAddRepositoryViewController alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.primaryNavigationController pushViewController:vc animated:YES];
}

- (void)responseToRepositoryUpdate:(NSNotification *)notification {
    [self reloadData];
}

- (void)reloadData {
    NSArray<NXRepositoryModel *> *dataArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
    
    NXRepositoryModel *myDriveModel = nil;
    NSMutableArray *repositories = [NSMutableArray array];
    
    for (NXRepositoryModel *model in dataArray) {
        if (model.service_type.integerValue == kServiceSkyDrmBox) {
            myDriveModel = model;
        } else  { 
            [repositories addObject:model];
        }
    }
    
    NSMutableArray *tableData = [NSMutableArray array];
    if (repositories.count) {
        [tableData addObject:@[NSLocalizedString(@"UI_CONNECT_REPO", NULL), repositories]];
    }
    if(myDriveModel){
         [tableData addObject:@[NSLocalizedString(@"UI_NEXTLABS_REPO", NULL), [NSArray arrayWithObject:myDriveModel]]];
    }
   
    
    self.tableArray = [NSArray arrayWithArray:tableData];
    [self.tableView reloadData];
}

#pragma mark - getter setter
- (NSDictionary *)repoIconDict {
    if (!_repoIconDict) {
        _repoIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - black"],
                          [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - black"],
                          [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - black"],
                          [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - black"],
                          [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-color"],
                          [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - black"],
                          [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive"],
                          [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - black"],
                          [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:[UIImage imageNamed:@"sharepoint - black"]
        };
    }
    return _repoIconDict;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionData = self.tableArray[section];
    NSArray *array = sectionData.lastObject;
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NXProfileSectionHeaderView *headerView = [[NXProfileSectionHeaderView alloc] init];
    
    NSArray *sectionData = self.tableArray[section];
    headerView.model = sectionData.firstObject;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.editing = YES;
    [cell reSet];
    
    NSArray *sectionData = self.tableArray[indexPath.section];
    NSArray *respositoriesArray = sectionData.lastObject;
    NXRepositoryModel *boundService = respositoriesArray[indexPath.row];
    
    [cell setMainTitle:boundService.service_alias forState:UIControlStateNormal];
    [cell setSubTitle:boundService.service_account forState:UIControlStateNormal];
    [cell setLeftImage:self.repoIconDict[boundService.service_type] forState:UIControlStateNormal];
    //for sharepoint/online  we should use user profile user name as sub title
    if (boundService.service_type.integerValue == kServiceSharepoint) {
        [cell setSubTitle:[NXLoginUser sharedInstance].profile.userName forState:UIControlStateNormal];
    }
    
    if ( boundService.service_type.integerValue == kServiceSharepointOnline) {
        [cell setSubTitle:boundService.service_account_id forState:UIControlStateNormal];
    }
    [cell setRightImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [cell setSubTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    if (boundService.service_isAuthed.boolValue == YES) {
        [cell setRightImage:[UIImage imageNamed:@"accessoryIcon"] forState:UIControlStateNormal];
    } else {
        [cell setRightImage:[UIImage imageNamed:@"HighPriority"] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionData = self.tableArray[indexPath.section];
    NSArray *respositoriesArray = sectionData.lastObject;
    NXRepositoryModel *repo = respositoriesArray[indexPath.row];
    
    if (repo.service_type.integerValue == kServiceSkyDrmBox) {
        return NO;
    }else{
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WeakObj(self);
        
        NSArray *sectionData = self.tableArray[indexPath.section];
        NSArray *respositoriesArray = sectionData.lastObject;
        NXRepositoryModel *repo = respositoriesArray[indexPath.row];
        
        NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"UI_COM_ARE_YOU_SURE_WANT_TO_DEL", NULL), repo.service_alias];
        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
            if (index == 1) {
                StrongObj(self);
                [NXMBManager showLoadingToView:self.view];
                [[NXLoginUser sharedInstance].myRepoSystem deleteRepository:repo completion:^(NXRepositoryModel *repoModel, NSError *error) {
                    dispatch_main_async_safe(^{
                        [NXMBManager hideHUDForView:self.view];
                        if (error) {
                            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DEL_REPO_ERROR", nil) toView:self.view hideAnimated:YES afterDelay:kDelay];
                        }else{
                            [self reloadData];
                        }
                        
                    });
                }];
            }else{
                StrongObj(self);
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionData = self.tableArray[indexPath.section];
    NSArray *respositoriesArray = sectionData.lastObject;
    NXRepositoryModel *repoModel = respositoriesArray[indexPath.row];
    
    if (repoModel.service_isAuthed.boolValue == YES) {
        NXRepositoryInfoViewController *vc = [[NXRepositoryInfoViewController alloc] initWithRepository:repoModel];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.primaryNavigationController pushViewController:vc animated:YES];
    } else {
        if (repoModel.service_type.integerValue == kServiceSharepoint) {
            [[NXLoginUser sharedInstance].myRepoSystem authRepositoyInViewController:self forRepo:repoModel completion:^(NXRepositoryModel *repoModel, NSError *error) {
                if (!error) {
                    [self reloadData];
                }
            }];
            return;
        }
        
        WeakObj(self);
        [[NXLoginUser sharedInstance].myRepoSystem authRepositoyInViewController:self forRepo:repoModel completion:^(NXRepositoryModel *repo, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongObj(self);
                if (error) {
                    if (error.code != NXRMC_ERROR_CODE_CANCEL) {
                        if(error.code == NXRMC_ERROR_CODE_AUTH_ACCOUNT_NOT_SAME){
                            [NXMBManager showMessage:error.localizedDescription?NSLocalizedString(@"MSG_AUTH_REPOSITORY_NOT_SAME_WITH_RMS", NULL):error.localizedDescription toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
                        }else{
                             [NXMBManager showMessage:error.localizedDescription?NSLocalizedString(@"MSG_AUTH_REPOSITORY_FAILED", NULL):error.localizedDescription toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
                        }
                    }
                    return;
                }
            });
        }];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark 
- (void)commonInit {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = NSLocalizedString(@"UI_HOMEVC_REPOSITORY", NULL);
    
    NXRepositoryHeaderView *headerView = [[NXRepositoryHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 75)];
    headerView.title = NSLocalizedString(@"UI_ADD_REPOSITORY", NULL);
    
    WeakObj(self);
    headerView.clickBlock = ^(id sender) {
        StrongObj(self);
        [self addRepoButtonClicked:nil];
    };
    
    UITableView *tableView = [[UITableView alloc]init];
    [self.view addSubview:tableView];
    
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.tableHeaderView = headerView;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    
    [tableView registerClass:[NXNormalCell class] forCellReuseIdentifier:@"kCellIdentifier"];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    self.tableView = tableView;
}

@end
