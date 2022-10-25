//
//  NXWorkSpaceTableViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceTableViewController.h"
#import "NXWorkSpaceItem.h"
#import "NXEmptyView.h"
#import "Masonry.h"
#import "NXWorkSpaceItemCell.h"
#import "NXMBManager.h"
#import "NXLoginUser.h"
#import "NXProjectFileListSearchResultViewController.h"
#import "NXAlertView.h"
#import "NXCommonUtils.h"
#import "AppDelegate.h"
#import "NXPresentNavigationController.h"
#import "NXFilePropertyVC.h"
#import "NXFileActivityLogViewController.h"
#import "NXAddToProjectFileInfoVC.h"
#import "NXAddToProjectVC.h"
#import "NXOriginalFilesTransfer.h"
#import "NXNetworkHelper.h"
#define kSectionHeaderHeight 25

@interface NXWorkSpaceTableViewController ()<UITableViewDelegate,UITableViewDataSource,NXProjectFileListSearchResultDelegate,DetailViewControllerDelegate,NXOperationVCDelegate,NXWorkSpaceFileUpdateDelegate>
@property(nonatomic, strong)NXEmptyView *emptyView;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, strong) UILabel *navTitleLabel;
@property(nonatomic, strong) NSArray<NSDictionary<NSString *, NSArray*> *> *tableData;

@end
@implementation NXWorkSpaceTableViewController
- (instancetype)initWithCurrentFolder:(NXWorkSpaceFolder *)folder {
    self = [super init];
    if (self) {
        _currentFolder = folder;
        [self commonInit];
        [NXMBManager showLoadingToView:self.view];
    }
    return self;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableview:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.currentFolder.isRoot) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navTitleLabel.text = self.currentFolder.name;

        self.navigationItem.titleView = self.navTitleLabel;
    }
    
    [self getNewDataAndreloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getNewDataAndreloadData{
    [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolder:self.currentFolder shouldReadCache:YES withCompletion:^(NSArray *fileListArray, NXWorkSpaceFolder *parentFoloder, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            [NXMBManager hideHUDForView:self.view];
            if (!error) {
                self.dataArray = [NSMutableArray arrayWithArray:fileListArray];
                if (self.dataArray.count == 0) {
                    self.emptyView.hidden = NO;
                    self.tableView.hidden = YES;
                }else {
                    self.emptyView.hidden = YES;
                    self.tableView.hidden = NO;
                    [self reloadData];
                }
            }else{
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }
        });
       
    }];
}
- (void)setSortOption:(NXSortOption)sortOption {
    _sortOption = sortOption;
    [self reloadData];
}
- (void)reloadData {
    self.tableData = [NXFileSort keySortObjects:self.dataArray option:_sortOption];
    [self.tableView reloadData];
}

-(void)refreshTableview:(NSNotification *)notify
{
    [self reloadData];
}

- (UILabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _navTitleLabel.textColor = self.navigationController.navigationBar.tintColor;
        _navTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _navTitleLabel;
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
    [self.tableView registerClass:[NXWorkSpaceItemCell class] forCellReuseIdentifier:@"cell"];
    
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
#pragma -mark NXSearchDataSourceProtocol

- (NSArray *)getSearchDataSource {
    return self.dataArray;
}
#pragma  mark  ----> tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableData.count?:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableData.count>0) {
        NSDictionary *sec = self.tableData[section];
        NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
        return array.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXWorkSpaceItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *fileModel = array[indexPath.row];
    cell.model = fileModel;
    WeakObj(self);
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
    
    if ([selectedFileItem isKindOfClass:[NXWorkSpaceFolder class]]) {
        NXWorkSpaceTableViewController *vc = [[NXWorkSpaceTableViewController alloc]initWithCurrentFolder:(NXWorkSpaceFolder*)selectedFileItem];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([selectedFileItem isKindOfClass:[NXWorkSpaceFile class]]){
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:selectedFileItem from:self withDelegate:self];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
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

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC accessForItem:(NXFileBase *)item {
   
    if ([item isKindOfClass:[NXWorkSpaceFile class]]) {
        [NXMBManager showLoading];
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:item withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
            BOOL isValidity = YES;
            
            if (rights.getVaildateDateModel) {
                
                if (![NXCommonUtils checkNXLFileisValid:[rights getVaildateDateModel]]) {
                     isValidity = NO;
                 }
            }
            if(error){
                isValidity = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:nil];
                WeakObj(self);
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        StrongObj(self);
                        [self fileListResultVC:nil didSelectItem:item];
                    }];
                    
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        [self fileListResultVC:nil propertyForItem:item];
                    }];
                    
                    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:item];
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
                        if (![NXCommonUtils isOfflineViewSupportFormat:item] || ![rights ViewRight]) {
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
                if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error && isValidity && (([rights DownloadRight] || [rights DecryptRight]) || ([[NXLoginUser sharedInstance] isTenantAdmin] && [rights ViewRight]))) {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                       
                        NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                        VC.currentFile = item;
                        VC.fileOperationType = NXFileOperationTypeAddWorkSPaceFileToOther;
                        
                        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:VC];
                        nav.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:nav animated:YES completion:nil];
                    }];
                    
                }else{
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                        
                    }];
                    
                }
                    
                if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && isValidity && ([rights DownloadRight] || ([[NXLoginUser sharedInstance] isTenantAdmin] && [rights ViewRight]))) {
                        [alertView addItemWithTitle:@"Save as" type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                            [NXMBManager showLoading];

                            [[NXLoginUser sharedInstance].nxlOptManager saveAsNXlFileToLocal:item  withCompletion:^(NXFileBase *file, NSError *error) {
                               
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                       [NXMBManager hideHUD];
                                        if (error) {
                                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                                        }else{
                                            [[NXOriginalFilesTransfer sharedIInstance] exportFile:file toOriginalFilesFromVC:self];
                                            [NXOriginalFilesTransfer sharedIInstance].exprotFileCompletion = ^(UIViewController *currentVC, NSURL *fileUrl, NSError *error1) {

                                                    if (error1) {
                                                        [NXMBManager showMessage:error1.localizedDescription hideAnimated:YES afterDelay:1.5];
                                                    }
                                            };
                                        }
                                   });
                            }];
                        }];
                        
                    }else{
                        [alertView addItemWithTitle:@"Save as" type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                            
                        }];
                        
                    }
                   
                    if ([[NXLoginUser sharedInstance] isTenantAdmin]) {
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL)   type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                            StrongObj(self);
                        [self fileListResultVC:nil infoForItem:item];
                        }];
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_RECLASSIFY",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                            NXAddToProjectFileInfoVC *vc = [[NXAddToProjectFileInfoVC alloc] init];
                            NXWorkSpaceFile *workSpaceFileItem = (NXWorkSpaceFile *)item;
                            vc.currentFile = workSpaceFileItem;
                            vc.fileOperationType = NXFileOperationTypeWorkSpaceFileReclassify;
                            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self.navigationController presentViewController:nav animated:YES completion:nil];
                        }];
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
                        StrongObj(self);
                        [self fileListResultVC:nil deleteItem:item];
                        }];
                    }
                alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
                [alertView show];
            });
        }];
        
    }else{
        NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:nil];
        if ([[NXLoginUser sharedInstance] isTenantAdmin]) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
                [self fileListResultVC:nil deleteItem:item];
            }];
        }
        alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
        [alertView show];
        
    }
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC didSelectItem:(NXFileBase *)item {
    [resultVC.view removeFromSuperview];
    
    NXFileBase *selectedFileItem = item;
    if ([selectedFileItem isKindOfClass:[NXWorkSpaceFolder class]]) {
        NXWorkSpaceTableViewController *vc = [[NXWorkSpaceTableViewController alloc]initWithCurrentFolder:(NXWorkSpaceFolder*)selectedFileItem];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([selectedFileItem isKindOfClass:[NXWorkSpaceFile class]]){
                AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [app showFileItem:selectedFileItem from:self withDelegate:self];
    }
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC propertyForItem:(NXFileBase *)item
{
    NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
    property.fileItem = item;
    property.delegate = self;
    
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC infoForItem:(NXFileBase *)item
{
    NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
    logActivityVC.fileItem = item;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC deleteItem:(NXFileBase *)item
{
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), item.name];
    WeakObj(self);
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) { // user deside to delete this file
            StrongObj(self);
            [NXMBManager showLoadingToView:self.view];
            [[NXLoginUser sharedInstance].workSpaceManager deleteWorkSpaceFile:(NXFileBase *)item withCompletion:^(NXFileBase *spaceItem, NSError *error) {
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
#pragma mark ----> NXOperationVCDelegate
-(void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile{
    [self getNewDataAndreloadData];
}
- (void)pullDownRefreshWork{
    [self getNewDataAndreloadData];
}

#pragma mark ------> NXWorkSpaceManager update file delegate
- (void)nxWorkSpaceManager:(NXWorkSpaceManager *)manager didGetWorkSpaceFiles:(NSArray *)files underFolder:(NXWorkSpaceFolder *)folder withSpaceDict:(NSDictionary *)dict withError:(NSError *)error{
    if ([folder.localPath isEqualToString:self.currentFolder.fullServicePath]) {
        [NXMBManager hideHUDForView:self.view];
        if (!error) {
            self.dataArray = [NSMutableArray arrayWithArray:files];
            if (self.dataArray.count == 0) {
                self.emptyView.hidden = NO;
                self.tableView.hidden = YES;
            }else{
                self.emptyView.hidden = YES;
                self.tableView.hidden = NO;
                [self reloadData];
            }
        }else{
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
        }
    }
}




@end
