//
//  NXProjectOtherFileListVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXProjectOtherFileListVC.h"
#import "NXRMCDef.h"
#import "NXMBManager.h"
#import "NXProjectModel.h"
#import "NXEmptyView.h"
#import "Masonry.h"
#import "AppDelegate.h"
#import "NXProjectFileItemCell.h"
#import "NXLoginUser.h"
#import "NXAlertView.h"
#import "NXCommonUtils.h"
#import "NXNXLFileSharingSelectVC.h"
#import "NXPresentNavigationController.h"
#import "NXFileActivityLogViewController.h"
#import "NXFilePropertyVC.h"
#import "NXSharedWithProjectFile.h"
#import "NXProjectFileManageShareVC.h"
#import "NXAddToProjectFileInfoVC.h"
#define kSectionHeaderHeight 25

@interface NXProjectOtherFileListVC ()<UITableViewDelegate,UITableViewDataSource,DetailViewControllerDelegate,NXOperationVCDelegate>
@property(nonatomic, strong) NXProjectModel *project;
@property(nonatomic, strong) NSMutableArray *originArray;
@property(nonatomic, strong) NXEmptyView *emptyView;
@property(nonatomic, strong) NSArray<NSDictionary<NSString *, NSArray*> *> *tableData;
@property(nonatomic, readonly, weak) UITableView *tableView;
@property(nonatomic, readonly, weak) UIRefreshControl *refreshControl;
@end

@implementation NXProjectOtherFileListVC
- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel {
    self = [super init];
    if (self) {
        _project = projectModel;
        [self commonInit];
        [NXMBManager showLoadingToView:self.view];
    }
    return self;
}
- (void)commonInit {

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc]init];
    _tableView = tableView;
    [self.view addSubview:self.tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.sectionHeaderHeight = kSectionHeaderHeight;
    self.tableView.estimatedRowHeight = 70;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[NXProjectFileItemCell class] forCellReuseIdentifier:@"cell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullDownRefreshWork) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor lightGrayColor];
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _refreshControl = refreshControl;
    [self.tableView addSubview:refreshControl];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kMargin * 4, 0);

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.left.and.right.equalTo(self.view);
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NXLoginUser sharedInstance].myProject allProjectsWithCompletion:^(NSArray *projects, NSError *error) {
        
    }];
    [self getNewDataAndreloadData];
}
- (void)getNewDataAndreloadData {
    WeakObj(self);
    self.project = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.project.projectId];
    if (self.project == nil) {
       return;
    }
    switch (self.operationType) {
        case NXProjectFileListByOperationTypeSharebyFiles:
        {
            [[NXLoginUser sharedInstance].myProject getShareByProjectFileListForProject:self.project withCompletion:^(NXProjectModel *project, NSArray *fileList, NSError *error) {
                 StrongObj(self);
                [self showTableUIFromArray:fileList withError:error];
            }];
        }
            break;
        case NXProjectFileListByOperationTypeShareWithFiles:
        {
            
            [[NXLoginUser sharedInstance].myProject getSharedFileListInProject:self.project withCompletion:^(NXProjectModel *project, NSArray *sharedFileListWithProject, NSError *error) {
                StrongObj(self);
                [self showTableUIFromArray:sharedFileListWithProject withError:error];
            }];
            
        }
            break;
        case NXProjectFileListByOperationTypeRevokedFiles:
        {
            [[NXLoginUser sharedInstance].myProject getAllRevokedFileListForProject:self.project withCompletion:^(NXProjectModel *project, NSArray *fileList, NSError *error) {
                 StrongObj(self);
                [self showTableUIFromArray:fileList withError:error];
            }];
        }
            break;
        default:
            break;
    }
    
}
- (void)showTableUIFromArray:(NSArray *)fileList withError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        if (!error) {
            self.originArray = [NSMutableArray arrayWithArray:fileList];
            if (self.originArray.count == 0) {
                self.emptyView.hidden = NO;
                self.tableView.hidden = YES;
            }else {
                self.emptyView.hidden = YES;
                self.tableView.hidden = NO;
                [self reloadData];
            }
        }else {
            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
        }
    });
}
- (void)setSortOption:(NXSortOption)sortOption {
    _sortOption = sortOption;
    [self reloadData];
}

- (void)reloadData {
    self.tableData = [NXFileSort keySortObjects:self.originArray option:_sortOption];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableview:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
    self.view.backgroundColor = [UIColor cyanColor];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableData.count?:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableData.count>0) {
        NSDictionary *sec = self.tableData[section];
        NSArray<NXProjectFile *> *array = [sec objectForKey:[sec allKeys].firstObject];
        return array.count;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    titleLabel.frame = CGRectMake(10, 0, self.tableView.bounds.size.width, kSectionHeaderHeight);
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    NSDictionary *sec = self.tableData[section];
    titleLabel.text = [sec allKeys].firstObject;
    [bgView addSubview:titleLabel];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(bgView.mas_safeAreaLayoutGuideLeft).offset(20);
                make.right.equalTo(bgView.mas_safeAreaLayoutGuideRight);
                make.top.equalTo(bgView.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(bgView.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }
    
    return bgView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXProjectFileItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *fileModel = array[indexPath.row];
    cell.model = fileModel;
    cell.projectModel = self.project;
    
    WeakObj(self);
    cell.swipeButtonBlock = ^(SwipeButtonType type){
        StrongObj(self);
        if (type == SwipeButtonTypeActiveLog) {
            [self fileListResultVC:nil logInfoForItem:fileModel];
        }
    };
    
    cell.accessBlock = ^(id sender) {
        StrongObj(self);
        [self fileListResultVC:nil accessForItem:fileModel];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray<NXFileBase *> *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *selectedFileItem = array[indexPath.row];
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:selectedFileItem from:self withDelegate:self];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC accessForItem:(NXFileBase *)item {
    
    NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:self.project.displayName];
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:item];
    WeakObj(self);
    if ([item isKindOfClass:[NXProjectFile class]] || [item isKindOfClass:[NXSharedWithProjectFile  class]]) {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [self fileListResultVC:nil didSelectItem:item];
        }];
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            [self fileListResultVC:nil propertyForItem:item];
        }];
        
        if (self.project.isOwnedByMe && self.operationType != NXProjectFileListByOperationTypeShareWithFiles) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL)   type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                [self fileListResultVC:nil logInfoForItem:item];
            }];
        }
        if (state == NXFileStateOfflineFailed) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                    dispatch_main_async_safe(^{
                        if (!error) {
                            item.isOffline = NO;
                            [self.tableView reloadData];
                            
                        }else{
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                            [self.tableView reloadData];
                        }
                    });
                }];
            }];
        } else if (state == NXFileStateOfflined || state == NXFileStateConvertingOffline) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                    dispatch_main_async_safe(^{
                        if (!error) {
                            item.isOffline = NO;
                            [self.tableView reloadData];
                        }else{
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                            [self.tableView reloadData];
                        }
                    });
                }];
            }];
        }else if (state == NXFileStateNormal || item.isOffline == NO){
            
            NXAlertViewItemType type = NXAlertViewItemTypeDefault;
            if (![NXCommonUtils isOfflineViewSupportFormat:item]) {
                type = NXAlertViewItemTypeClickForbidden;
            }
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_OFFLINE",NULL) type:type handler:^(NXAlertView *alertView) {
                [[NXOfflineFileManager sharedInstance] markFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                    StrongObj(self);
                    dispatch_main_async_safe(^{
                        if (!error) {
                            item.isOffline = YES;
                            [self.tableView reloadData];
                        }else{
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                            [self.tableView reloadData];
                        }
                    });
                }];
            }];
        }
        switch (self.operationType) {
            case NXProjectFileListByOperationTypeSharebyFiles:{
                [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {

                    NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                    VC.currentFile = item;
                    VC.fromProjectModel = self.project;
                    VC.fileOperationType = NXFileOperationTypeAddProjectFileToProject;

                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:nav animated:YES completion:nil];
                }];
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    NXProjectFileManageShareVC *vc = [[NXProjectFileManageShareVC alloc] init];
                    vc.fileItem = item;
                    vc.fromProjectModel = self.project;
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }];
                //  only project admin can modify rights
                if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_RECLASSIFY",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        NXAddToProjectFileInfoVC *vc = [[NXAddToProjectFileInfoVC alloc] init];
                        NXProjectFile *projectFileItem = (NXProjectFile *)item;
                        projectFileItem.projectId = self.project.projectId;
                        vc.currentFile = projectFileItem;
                        vc.toProject = self.project;
                        vc.fileOperationType = NXFileOperationTypeProjectFileReclassify;
                        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                        [self.navigationController presentViewController:nav animated:YES completion:nil];
                    }];
                }
                if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
                       
//                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_REVOKE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//                        [self fileListResultVC:nil revokeItem:item];
//                    }];
                    if (self.project.isOwnedByMe) {
                           [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
                               StrongObj(self);
                               [self fileListResultVC:nil deleteItem:item];
                           }];
                       }
                }
            }
                break;
            case NXProjectFileListByOperationTypeShareWithFiles:{
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_RESHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    NXNXLFileSharingSelectVC *vc = [[NXNXLFileSharingSelectVC alloc]init];
                    vc.fileItem = item;
                    vc.fromProjectModel = self.project;
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }];
            }
                break;
             case NXProjectFileListByOperationTypeRevokedFiles:
                break;
                
            default:
                break;
        }
       

    }
   
    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
    
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC didSelectItem:(NXFileBase *)item {
    [resultVC.view removeFromSuperview];
    
    NXFileBase *selectedFileItem = item;
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:selectedFileItem from:self withDelegate:self];
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC deleteItem:(NXFileBase *)item {
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), item.name];
    WeakObj(self);
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) { // user deside to delete this file
            StrongObj(self);
            [NXMBManager showLoadingToView:self.view];
            [[NXLoginUser sharedInstance].myProject removeFileItem:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DELETE_FILE_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                    }else{
                        [self getNewDataAndreloadData];
                    }
                });
            }];
        }
    }];
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC revokeItem:(NXFileBase *)item {
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_REVOKE_FILE_WARNING", NULL), item.name];
    WeakObj(self);
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) { // user desire to delete this file
            StrongObj(self);
            [NXMBManager showLoadingToView:self.view];
            [[NXLoginUser sharedInstance].nxlOptManager revokeSharedFileByFileDuid:((NXProjectFile*)item).duid wtihCompletion:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                       [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_REVOKE_FILE_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                    }else{
                       [self getNewDataAndreloadData];
                    }
                });
            }];
            
           
        }
    }];
    
}
    
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC logInfoForItem:(NXFileBase *)item {
    NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
    logActivityVC.fileItem = item;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC propertyForItem:(NXFileBase *)item {
    NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
    property.fileItem = item;
//    property.isFromProjectFile = YES;
    NSString *currentUserId = [NXLoginUser sharedInstance].profile.userId;
    if ([item isKindOfClass:[NXSharedWithProjectFile class]]) {
        property.isSteward = NO;
    }else if ([item isKindOfClass:[NXProjectFile class]]){
        NXProjectFile *file = (NXProjectFile *)item;
        NSNumber *currentFileUserId = file.projectFileOwner.userId;
        if ([[currentFileUserId stringValue] isEqualToString:currentUserId]) {
            property.isSteward = YES;
        }else {
            property.isSteward = NO;
        }
    }
    property.delegate = self;
    
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
    [self presentViewController:nav animated:YES completion:nil];
}

- (NXEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[NXEmptyView alloc]init];
        _emptyView.textLabel.text = NSLocalizedString(@"UI_MYVAULT_NO_FILE", NULL);
        _emptyView.imageView.image = [UIImage imageNamed:@"emptyFolder"];
        [self.view addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    return _emptyView;
}
- (void)pullDownRefreshWork {
    [self getNewDataAndreloadData];
}
- (NSArray *)getSearchDataSource {
    return self.originArray;
}
-(void)refreshTableview:(NSNotification *)notify {
    [self .tableView reloadData];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - NXOperationVCDelegate
-(void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile{
    [self getNewDataAndreloadData];
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
