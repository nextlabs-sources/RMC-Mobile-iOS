//
//  NXFileActivityLogViewController.m
//  nxrmc
//
//  Created by helpdesk on 7/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXFileActivityLogViewController.h"
#import "NXDetailLogInfoViewController.h"
//#import "NXMasterSplitViewController.h"
#import "NXFilterViewController.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXLogInfoTableViewCell.h"
#import "NXMBManager.h"
#import "NXFileSort.h"
#import "NXFileBase.h"
#import "NXFileActivityLogAPI.h"
#import "NXWebFileManager.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXNXLFileLogManager.h"
#import "NXFileActivityLogSearchResultViewController.h"
#import "NXSearchViewController.h"
#import "AppDelegate.h"
#import "NXLMetaData.h"
@interface NXFileActivityLogViewController ()<UITableViewDelegate, UITableViewDataSource, NXNXLFileLogManagerDelegate, NXFilterViewControllerDelegate, NXSearchVCUpdateDelegate, NXSearchVCResignActiveDelegate, NXFileActivityLogSearchResultDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NXMBProgressView *progressView;
@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) NXNXLFileLogManager *logManager;
@property(nonatomic, strong) NSString *downloadOptID;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, assign) NXSortOption curSortOption;
@property(nonatomic, strong) NXSearchViewController *searchVC;
@property(nonatomic, strong) NSString *curFileDUID;
@end

@implementation NXFileActivityLogViewController
- (instancetype)init {
    if (self = [super init]) {
        self.showSortSearch = YES;
        _allSortByTypes = @[@(NXSortOptionDateDescending), @(NXSortOptionNameAscending), @(NXSortOptionOperationAscending), @(NXSortOptionOperationResultAscending)];
        _curSortOption = NXSortOptionDateDescending;
        WeakObj(self);
        // response to search and sort
        self.sortCallBack = ^(id sender) {
            StrongObj(self);
            if (self) {
                NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
                filterVC.providesPresentationContextTransitionStyle = true;
                filterVC.definesPresentationContext = true;
                filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                filterVC.segmentItems = self.allSortByTypes;
                filterVC.selectedSortType = self.curSortOption;
                filterVC.delegate = self;
                [self presentViewController:filterVC animated:YES completion:nil];
            }
        };
        
        self.searchCallBack = ^(id sender) {
            StrongObj(self);
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self hiddenNavigatinBarItems];
            NXFileActivityLogSearchResultViewController *resultVC = [[NXFileActivityLogSearchResultViewController alloc] init];
            resultVC.delegate = self;
            NXSearchViewController *searchVC = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC shouldAutoDisplay:NO];
            searchVC.updateDelegate = self;
            resultVC.resignActiveDelegate = self;
            searchVC.searchBar.showsCancelButton = YES;
            searchVC.searchBar.placeholder = NSLocalizedString(@"UI_BEGIN_YOUR_SEARCH", NULL);
            [searchVC.searchBar sizeToFit];
            searchVC.hidesNavigationBarDuringPresentation = NO;
            self.definesPresentationContext = YES;
            self.searchVC = searchVC;
            self.navigationItem.titleView = searchVC.searchBar;
            
            
            [self hideTopView];

            [self.searchVC.searchBar becomeFirstResponder];
        };
    }
    return self;
}

- (void)hiddenNavigatinBarItems
{
    if ([NXCommonUtils isiPad]) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onTapCancelButton:)];
        self.navigationItem.rightBarButtonItems = @[cancelButton];
    }else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = nil;
}

- (void)onTapCancelButton:(id)sender
{
  //  [self configureNavigationBar];
    self.searchVC.active = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _logManager = [[NXNXLFileLogManager alloc] init];
    _logManager.delegate = self;
    _curFileDUID = @"";
    [self commonInit];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchVC setActive:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [self.tableView addShadow:UIViewShadowPositionTop | UIViewShadowPositionLeft | UIViewShadowPositionBottom | UIViewShadowPositionRight color:[UIColor darkGrayColor] width:0.9 Opacity:0.6];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NXWebFileManager sharedInstance] cancelDownload:self.downloadOptID];
}

#pragma mark
- (void)initData {
    if ([self.fileItem isKindOfClass:[NXMyVaultFile class]]) {
        [NXMBManager showLoading:NSLocalizedString(@"UI_COM_DOWNLOADING", NULL) toView:self.mainView];
        NXMyVaultFile *file = (NXMyVaultFile *)self.fileItem;
        if (!file.duid) {
            WeakObj(self);
            [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:file withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
                if (duid) {
                    file.duid = duid;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        StrongObj(self);
                        if (self) {
                             self.curFileDUID = duid;
                             [self requestLogsInfo:file.duid];
                        }
                    });
                }
            }];
        }
        else
        {
            self.curFileDUID = file.duid;
            [self requestLogsInfo:file.duid];
        }
    }else if ([self.fileItem isKindOfClass:[NXProjectFile class]]) {
        [NXMBManager showLoading:NSLocalizedString(@"UI_COM_DOWNLOADING", NULL) toView:self.mainView];
        NXProjectFile *file = (NXProjectFile *)self.fileItem;
         self.curFileDUID = file.duid;
        [self requestLogsInfo:file.duid];
    } else if([self.fileItem isKindOfClass:[NXWorkSpaceFile class]]) {
        [NXMBManager showLoading:NSLocalizedString(@"UI_COM_DOWNLOADING", NULL) toView:self.mainView];
        NXWorkSpaceFile *file = (NXWorkSpaceFile *)self.fileItem;
        self.curFileDUID = file.duid;
        [self requestLogsInfo:file.duid];
       
    }else{
         [self updateRepositoryFileData];
    }
}

- (void)updateRepositoryFileData {
    if (!self.fileItem.localPath) {
        self.progressView = [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_DOWNLOADING", NULL) progress:0 mode:NXMBProgressModeDeterminateHorizontalBar toView:self.mainView];
        WeakObj(self);
        NXWebFileDownloaderProgressBlock progressBlock = ^(int64_t receivedSize, int64_t totalCount, double fractionCompleted){
            StrongObj(self);
            self.progressView.progress = fractionCompleted;
        };
        self.downloadOptID = [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)self.fileItem withProgress:progressBlock completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
            StrongObj(self);
            [self didFinishDownloadFile:file error:error];
        }];
    } else {
        [self didFinishDownloadFile:self.fileItem error:nil];
    }
}

- (void)didFinishDownloadFile:(NXFileBase *)file error:(NSError *)error {
    [NXMBManager hideHUDForView:self.mainView];
    if (error) {
        [self showAlertPage:NSLocalizedString(@"MSG_ACTIVITY_FAILED", NULL)];
        return;
    }
    
    NSString *uuid;
    NSString *owner;
    NSError *uuidError = nil;
    [NXLMetaData getNxlFile:file.localPath duid:&uuid publicAgrement:nil owner:&owner ml:nil error:&uuidError];
    if (error) {
        [self showAlertPage:NSLocalizedString(@"MSG_ACTIVITY_FAILED", NULL)];
        return;
    }

    if (!uuid) {
        [self showAlertPage:NSLocalizedString(@"MSG_ACTIVITY_FAILED", NULL)];
        return;
    }
    [self requestLogsInfo:uuid];
}

- (void)requestLogsInfo:(NSString *)uuid {
    WeakObj(self);
    self.curFileDUID = uuid;
    [self.logManager activityLogForFile:uuid sortBy:self.curSortOption onlyLocalData:NO withCompletion:^(NSArray *activityLogs, NSString *duid, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            if (self) {
                [NXMBManager hideHUDForView:self.mainView];
                if (!error) {
                    self.dataArray = [NSMutableArray arrayWithArray:activityLogs];
                    [self.tableView reloadData];
                } else {
                    [self showAlertPage:error.localizedDescription];
                }
            }
        });
    }];
}

#pragma mark
- (void)closeThisPage {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)showAlertPage:(NSString *)message {
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
    } cancelActionHandle:nil inViewController:self position:nil];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXLogInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NXNXLFileLogModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    if (indexPath.row + 1  == self.dataArray.count) {
        //remove sperator line
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.bounds.size.width);
    } else {
        //spearator line leading to border
        cell.separatorInset = UIEdgeInsetsMake(0, -60, 0, 0);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXDetailLogInfoViewController *detailVC = [[NXDetailLogInfoViewController alloc]init];
    detailVC.logModel = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark
- (void)commonInit {
    self.topView.model = self.fileItem;
    
    self.topView.operationTitle = NSLocalizedString(@"UI_ACTIVITY_LOG", NULL);
    WeakObj(self);
    self.topView.backClickAction = ^(id sender) {
        StrongObj(self);
        [self closeThisPage];
    };
    
    [self.bottomView removeFromSuperview];
    
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    self.mainView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.mainView addSubview:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[NXLogInfoTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView).offset(kMargin/2);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
        make.bottom.equalTo(self.view).offset(-kMargin);
    }];
}

#pragma mark
- (NSMutableArray*)dataArray{
    if (!_dataArray) {
        _dataArray=[NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - NXNXLFileLogManagerDelegate
- (void)nxNXLFileLogManager:(NXNXLFileLogManager *)nxFileLogManger duid:(NSString *)duid didUpdateLog:(NSArray *)activityLogs {
    WeakObj(self);
    [self.logManager activityLogForFile:duid sortBy:self.curSortOption onlyLocalData:YES withCompletion:^(NSArray *activityLogs, NSString *duid, NSError *error) {
        StrongObj(self);
        if (self) {
            if (!error) {
                self.dataArray = [NSMutableArray arrayWithArray:activityLogs];;
                [self.tableView reloadData];
            }
        }
    }];
}
- (void)searchVCShouldResignActive
{
//    [self.searchVC setActive:NO];
    
}

#pragma mark - NXFilterViewControllerDelegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    if(sortType == self.curSortOption) {
        return;
    }
    self.curSortOption = sortType;
    if ([self.curFileDUID isEqualToString:@""]) {
        return;
    }
    WeakObj(self);
    [self.logManager activityLogForFile:self.curFileDUID sortBy:sortType onlyLocalData:YES withCompletion:^(NSArray *activityLogs, NSString *duid, NSError *error) {
        StrongObj(self);
        if (self) {
            if (!error) {
                self.dataArray = [NSMutableArray arrayWithArray:activityLogs];;
                [self.tableView reloadData];
            }
        }
    }];
}


- (void)updateSearchResultsForSearchController:(NXSearchViewController *)vc resultSeachVC:(NXSearchResultViewController *)resultVC
{
    NSString *searchString = [vc.searchBar text];
    if (![searchString isEqualToString:@""]) {
        resultVC.dataArray = [self.logManager searchActivityLogForFile:self.curFileDUID sortBy:self.curSortOption searchString:searchString];
        [resultVC updateData];
    }
}

- (void)searchControllerWillDissmiss:(NXSearchViewController *)searchController {
    [self.searchVC.searchBar removeFromSuperview];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self showTopView];
    [self.view layoutIfNeeded];
}

- (void)searchControllerDidPresent:(NXSearchViewController *)searchController {
    dispatch_async(dispatch_get_main_queue(),^{
        [searchController.searchBar becomeFirstResponder];
    });
}

- (void)cancelButtonClicked:(NXSearchViewController *)searchController {
    dispatch_async(dispatch_get_main_queue(),^{
        [searchController.searchBar resignFirstResponder];
    });
}

- (void)searchControllerWillPresent:(NXSearchViewController *)searchController {
    
}


#pragma mark - NXFileActivityLogSearchResultDelegate
- (void)fileActivityLogSearchResultVC:(NXFileActivityLogSearchResultViewController *)resultVC didSelectItem:(NXNXLFileLogModel *)item {
    NXDetailLogInfoViewController *detailVC = [[NXDetailLogInfoViewController alloc]init];
    detailVC.logModel = item;
    [self.navigationController pushViewController:detailVC animated:YES];
}



@end
