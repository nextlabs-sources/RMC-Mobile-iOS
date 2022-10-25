  //
//  NXFileBaseViewController.m
//  nxrmc
//
//  Created by nextlabs on 1/19/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileBaseViewController.h"

#import "NXFilePropertyVC.h"
#import "NXShareViewController.h"
#import "NXProtectViewController.h"
#import "NXPresentNavigationController.h"
#import "NXFileActivityLogViewController.h"
#import "NXVaultManageViewController.h"

#import "Masonry.h"
#import "NXFileItemCell.h"
#import "NXEmptyView.h"
#import "NXAlertView.h"

#import "NXMBManager.h"

#import "AppDelegate.h"
#import "NXCommonUtils.h"
#import "NXRMCDef.h"
#import "NXRepositorySysManager.h"
#import "NXSharePointFile.h"
#import "NXSharePointFolder.h"
#import "NXNetworkHelper.h"
#import "NXMyVaultCell.h"
#import "NXOfflineFileCell.h"
#define kSectionHeaderHeight    25

@interface NXFileBaseViewController ()<NXFileItemCellDelegate>
@end

@implementation NXFileBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    _tableView = tableView;
    [self updateUI];
    self.tableView.estimatedRowHeight = 70;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[self displayCellTypeClass] forCellReuseIdentifier:@"kFileCellIdentifier"];
    [self.tableView registerClass:[NXMyVaultCell class] forCellReuseIdentifier:kCellMyVault];
    self.isRefreshSupported = YES;
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

-(void)updateUI;
{
    if (self.offlineTopView) {
        [self.offlineTopView removeFromSuperview];
    }
    
    if (self.isOfflineVC) {
        
        UIView *offlineTopView = [[UIView alloc] init];
        UILabel *offlineTittleLabel = [[UILabel alloc] init];
        offlineTittleLabel.textColor = [UIColor whiteColor];
        offlineTittleLabel.textAlignment = NSTextAlignmentCenter;
        offlineTittleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        //offlineTittleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:16.0];
        [offlineTopView addSubview:offlineTittleLabel];
        
        UILabel *offlineTipsLabel = [[UILabel alloc] init];
        offlineTipsLabel.text = @"You can only view the files made available for offline use.";
        offlineTipsLabel.textColor = [UIColor whiteColor];
        offlineTipsLabel.textAlignment = NSTextAlignmentCenter;
        offlineTipsLabel.font = [UIFont systemFontOfSize:10.0];
        [offlineTopView addSubview:offlineTipsLabel];
        
        [self.view addSubview:offlineTopView];
        _offlineTopView = offlineTopView;
        
        if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
             offlineTittleLabel.text = @"OFFLINE";
             offlineTopView.backgroundColor = NXColor(233, 84,90);
        }else{
             offlineTittleLabel.text = @"ONLINE";
            offlineTopView.backgroundColor = NXColor(57, 151, 73);
        }
        
        [self.offlineTopView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(4);
            make.height.equalTo(@40);
        }];
        
        [offlineTittleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.offlineTopView);
            make.top.equalTo(self.offlineTopView).mas_offset(2);
            make.height.equalTo(@(24));
        }];
        
        [offlineTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.offlineTopView);
            make.top.equalTo(offlineTittleLabel.mas_bottom).offset(-2);
            make.height.equalTo(@(10));
        }];
        
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom).mas_offset(44);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }else{
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
- (void)updateData {
    assert(0);
}

- (void)startSyncData {
    assert(0);
}

- (void)stopSyncData {
    assert(0);
}

- (void)pullDownRefreshWork {
    assert(0);
}

- (Class)displayCellTypeClass {
    assert(0);
}

- (void)didSelectItem:(NXFileBase *)item {
    assert(0);
}

- (void)moreButtonLClicked:(NXFileBase *)item {
    [self accessButtonClickForFileItem:item];
}

- (void)swipeButtonClick:(NSInteger)type fileItem:(NXFileBase *)fileItem {
    switch (type) {
        case SwipeButtonTypeShare: //share
        {
            NXShareViewController *vc = [[NXShareViewController alloc] init];
            vc.fileItem = fileItem;
            vc.delegate = self;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case SwipeButtonTypeFavorite: //favorite
        {
            fileItem.isFavorite? [[NXLoginUser sharedInstance].myRepoSystem unmarkFavFileItem:fileItem] : [[NXLoginUser sharedInstance].myRepoSystem markFavFileItem:fileItem];
        }
            break;
        case SwipeButtonTypeOffline: //offline
        {
            fileItem.isOffline? [[NXLoginUser sharedInstance].myRepoSystem unmarkOfflineFileItem:fileItem] : [[NXLoginUser sharedInstance].myRepoSystem markOfflineFileItem:fileItem];
        }
            break;
        case SwipeButtonTypeProtect: //protect
        {
            NXProtectViewController *vc = [[NXProtectViewController alloc] init];
            vc.fileItem = fileItem;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case SwipeButtonTypeDelete: //delete
        {
#pragma mark potential bug, here, for shared with me file and my vault file this will be have bug when delete,
            WeakObj(self);
            NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"UI_COM_ARE_YOU_SURE_WANT_TO_DEL", NULL), fileItem.name];
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
                if (index == 1) {
                    StrongObj(self);
                    [[NXLoginUser sharedInstance].myRepoSystem deleteFileItem:fileItem completion:^(NXFileBase *fileItem, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [NXMBManager hideHUDForView:self.view];
                            if (!error) {
                                // No error occur, reload data
                                [self updateData];
                            }else{
                                // error happened during delete file, notify user
                                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_DELETE_FILE_ERROR", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                                    
                                } cancelActionHandle:nil inViewController:self position:self.view];
                                
                            }
                        });
                    }];
                    [NXMBManager showLoadingToView:self.view];
                }
            }];
        }
            break;
        case SwipeButtonTypeActiveLog:
        {
            NXFileActivityLogViewController *logVC = [[NXFileActivityLogViewController alloc] init];
            logVC.fileItem = fileItem;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logVC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case SwipeButtonTypeInfo:
        {
            NXFilePropertyVC *propertyVC = [[NXFilePropertyVC alloc] init];
            propertyVC.fileItem = fileItem;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:propertyVC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case SwipeButtonTypeManage:
        {
            NXVaultManageViewController *manageVC = [[NXVaultManageViewController alloc] init];
            manageVC.fileItem = (NXMyVaultFile *)fileItem;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:manageVC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)reloadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<NSDictionary *> *result = [NXFileSort keySortObjects:[NSMutableArray arrayWithArray:self.dataArray] option:self.sortOption];
        dispatch_main_async_safe(^{
            self.tableData = result;
            [NXMBManager hideHUDForView:self.view]; //  for the reload data like async, so we need remove loading view here
        });
    });
}

- (void)showEmptyView:(NSString *)title image:(UIImage *)image {
    if ([self.tableView viewWithTag:213]) {
        return;
    }
    NXEmptyView *emptyView = [[NXEmptyView alloc] init];
    emptyView.textLabel.text = NSLocalizedString(@"UI_NO_FILE_IN_FOLDER", NULL);
    emptyView.imageView.image = [UIImage imageNamed:@"emptyFolder"];
    emptyView.tag = 213;
    if (title) {
        emptyView.textLabel.text = title;
    }

    if (image) {
        emptyView.imageView.image = image;
    }
    
    [self.tableView addSubview:emptyView];
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.tableView);
        make.width.and.height.equalTo(self.tableView);
    }];
}

- (void)removeEmptyView {
    [[self.tableView viewWithTag:213] removeFromSuperview];
}

#pragma mark - setter getter
- (void)setTableData:(NSArray<NSDictionary<NSString *,NSArray *> *> *)tableData {
    [self.refreshControl endRefreshing];
    _tableData = tableData;
    if (_tableData.count) {
        [self removeEmptyView];
    } else {
        [self showEmptyView:nil image:nil];
    }
    [self.tableView reloadData];
}

- (void)setSortOption:(NXSortOption)sortOption {
    _sortOption = sortOption;
    if (self.dataArray) {
        [self reloadData];
    }
}

- (void)setIsRefreshSupported:(BOOL)isRefreshSupported {
    if (isRefreshSupported == _isRefreshSupported) {
        return;
    }
    
    _isRefreshSupported = isRefreshSupported;
    
    if (!isRefreshSupported) {
        _refreshControl = nil;
    } else {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to Refresh"
//                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        [refreshControl addTarget:self action:@selector(refreshDataInOtherThread) forControlEvents:UIControlEventValueChanged];
        refreshControl.tintColor = [UIColor lightGrayColor];
        refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _refreshControl = refreshControl;
        [self.tableView addSubview:refreshControl];
    }
}

#pragma mark
- (void)refreshDataInOtherThread {
    [self pullDownRefreshWork];
}

- (void)deleteFileItem:(NXFileBase *)fileItem {
    
    WeakObj(self);
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"UI_COM_ARE_YOU_SURE_WANT_TO_DEL", NULL), fileItem.name];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) {
            StrongObj(self);
            [[NXLoginUser sharedInstance].myRepoSystem deleteFileItem:fileItem completion:^(NXFileBase *fileItem, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    if (!error) {
                        // No error occur, reload data
                        [self updateData];
                    }else {
                        // error happened during delete file, notify user
                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_DELETE_FILE_ERROR", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                            
                        } cancelActionHandle:nil inViewController:self position:self.view];
                    }
                });
            }];
            [NXMBManager showLoadingToView:self.view];
        }
    }];
}

#pragma mark
- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem {
//    BOOL isMyDrive = fileItem.serviceType.integerValue == kServiceSkyDrmBox;
//    
//    NXAlertView *alertView = [NXAlertView alertViewWithTitle:fileItem.name andMessage:@""];
//    
//    WeakObj(self);
//    if ([fileItem isKindOfClass:[NXFolder class]] || [fileItem isKindOfClass:[NXSharePointFolder class]]) {
//        if (!isMyDrive) {
//            return;
//        }
//    } else {
//        NSString *extension = [fileItem.name pathExtension];
//        NSString *markExtension = [NSString stringWithFormat:@".%@", extension];
//        BOOL isNXL = [markExtension compare:NXLFILEEXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame;
//        
//        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//            StrongObj(self);
//            [self didSelectItem:fileItem];
//        }];
//        
//        if (isNXL || isMyDrive) {
//            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//                StrongObj(self);
//                NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
//                property.fileItem = fileItem;
//                property.delegate = self;
//                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
//                [self.navigationController presentViewController:nav animated:YES completion:nil];
//            }];
//        }
//        
//        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//            StrongObj(self);
//            NXShareViewController *vc = [[NXShareViewController alloc] init];
//            vc.fileItem = fileItem;
//            vc.delegate = self;
//            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
//            [self.navigationController presentViewController:nav animated:YES completion:nil];
//        }];
//        
//        if (!isNXL) {
//            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_PROTECT", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//                StrongObj(self);
//                NXProtectAndSaveFileFromFilesVC *VC = [[NXProtectAndSaveFileFromFilesVC alloc] init];
//                VC.fileItem = fileItem;
////                NXProtectViewController *vc = [[NXProtectViewController alloc] init];
////                vc.fileItem = fileItem;
////                vc.folder = self.currentFolder;
//                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
//                [self.navigationController presentViewController:nav animated:YES completion:nil];
//            }];
//        }
//        
////        if (FAVORITE_ON) {
////            NSString *favorite = fileItem.isFavorite? NSLocalizedString(@"UnMark as favorite", NULL):NSLocalizedString(@"Mark as favorite", NULL);
////            [alertView addItemWithTitle:favorite type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
////                fileItem.isFavorite? [[NXLoginUser sharedInstance].myRepoSystem unmarkFavFileItem:fileItem] : [[NXLoginUser sharedInstance].myRepoSystem markFavFileItem:fileItem];
////            }];
////        }
////        
////        if (OFFLINE_ON) {
////            NSString *offline = fileItem.isOffline? NSLocalizedString(@"UnMark available offline", NULL):NSLocalizedString(@"Mark available offline", NULL);
////            [alertView addItemWithTitle:offline type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
////                fileItem.isOffline? [[NXLoginUser sharedInstance].myRepoSystem unmarkOfflineFileItem:fileItem] : [[NXLoginUser sharedInstance].myRepoSystem markOfflineFileItem:fileItem];
////            }];
////        }
//    }
//    
//    if (isMyDrive) {
//        if ((![fileItem isKindOfClass:[NXFolder class]])) {
//            // mark as favorite or unfavorite
//            if (fileItem.isFavorite == YES) {
//                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//                    [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:fileItem withCompletion:^(NXFileBase *file) {
//                        fileItem.isFavorite = NO;
//                        [self.tableView reloadData];
//                        [self updateData];
//                    }];
//                }];
//            }
//            else
//            {
//                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//                    [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:fileItem withCompleton:^(NXFileBase *file) {
//                        fileItem.isFavorite = YES;
//                        [self.tableView reloadData];
//                        [self updateData];
//                    }];
//                }];
//            }
//        }
//       
//        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
//            StrongObj(self);
//            [self deleteFileItem:fileItem];
//        }];
//    }
//    
//    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
//    [alertView show];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return self.tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     NSDictionary *sec ;
    if (self.tableData.count > 0) {
         sec = self.tableData[section];
    }
    NSArray *array;
    if (sec.allKeys.count > 0) {
         array  = [sec objectForKey:[sec allKeys].firstObject];
    }
    return array.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NXMyVaultHeaderView *headerView = [[NXMyVaultHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kSectionHeaderHeight)];
//    headerView.model = [self tableView:tableView titleForHeaderInSection:section];
//    return headerView;
    UIView *bgView= [[UIView alloc]init];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *fileItem = array[indexPath.row];
    if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile && !self.isOfflineVC) {
        NXMyVaultCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellMyVault];
        cell.model = fileItem;
           
           WeakObj(self);
           cell.accessBlock = ^(id sender) {
               StrongObj(self);
               [self moreButtonLClicked:fileItem];
           };
           
           cell.swipeButtonBlock = ^(SwipeButtonType type) {
               StrongObj(self);
               [self swipeButtonClick:type fileItem:fileItem];
           };
           
           cell.swipeDelegate = self;
           
           [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
           
           return cell;
    }else{
        NXFileItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        cell.model = fileItem;
           
           WeakObj(self);
           cell.accessBlock = ^(id sender) {
               StrongObj(self);
               [self moreButtonLClicked:fileItem];
           };
           
           cell.swipeButtonBlock = ^(SwipeButtonType type) {
               StrongObj(self);
               [self swipeButtonClick:type fileItem:fileItem];
           };
           
           cell.swipeDelegate = self;
           
           [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
           
           return cell;
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *fileItem = array[indexPath.row];
    [self didSelectItem:fileItem];
}

#pragma mark - NXOperationVCDelegate

- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
    [self updateData];
}

- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didCancelOperationFile:(NXFileBase *)file {
    [self updateData];
}

#pragma mark - NXFileItemCellDelegate
- (void)nxfileItemWillEndSwiping:(MGSwipeTableCell *)cell {
    //开启自动刷新
    [self startSyncData];
}

- (void)nxfileItemWillBeginSwiping:(MGSwipeTableCell *)cell {
    //暂停自动刷新
    [self stopSyncData];
}
#pragma mark - DetailViewControllerDelegate
- (void)detailViewController:(DetailViewController *)detailVC SwipeToPreFileFrom:(NXFileBase *)file
{
    NSArray *fileArray = [self sortedFileArray];
    NSUInteger index = [fileArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXFileBase *fileObj = (NXFileBase *)obj;
        if (fileObj.sorceType == NXFileBaseSorceTypeRepoFile) {
            if ([fileObj.repoId isEqualToString:file.repoId] && [fileObj.fullServicePath isEqualToString:file.fullServicePath]) {
                *stop = YES;
                return YES;
            }else{
                *stop = NO;
                return NO;
            }
        }else{
            if ([fileObj.fullServicePath isEqualToString:file.fullServicePath]) {
                *stop = YES;
                return YES;
            }else{
                *stop = NO;
                return NO;
            }
        }
        
        
    }];
    if (index == 0 || index == NSNotFound) {
        // first file item, show alert
        [detailVC showAutoDismissLabel:NSLocalizedString(@"MSG_COM_SWIPE_NO_MORE_FILE_TO_SHOW", nil)];
        return;
    }
    
    NXFileBase *newfile = fileArray[index - 1];
    [detailVC openFile:newfile];
    [self.tableView reloadData];
}

- (void)detailViewController:(DetailViewController *)detailVC SwipeToNextFileFrom:(NXFileBase *)file
{
    NSArray *fileArray = [self sortedFileArray];
    NSUInteger index = [fileArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXFileBase *fileObj = (NXFileBase *)obj;
        if ([fileObj.repoId isEqualToString:file.repoId] && [fileObj.fullServicePath isEqualToString:file.fullServicePath]) {
            *stop = YES;
            return YES;
        }else{
            *stop = NO;
            return NO;
        }
    }];
    if (index == fileArray.count - 1 || index == NSNotFound) {
        // first file item, show alert
        [detailVC showAutoDismissLabel:NSLocalizedString(@"MSG_COM_SWIPE_NO_MORE_FILE_TO_SHOW", nil)];
        return;
    }
    
    NXFileBase *newfile = fileArray[index + 1];
    [detailVC openFile:newfile];
    [self.tableView reloadData];
}

- (NSArray *)sortedFileArray {
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSDictionary *sectionDatas in self.tableData) {
        if ([sectionDatas.allValues.firstObject isKindOfClass:[NSArray class]] && ((NSArray *)sectionDatas.allValues.firstObject).count) {
            for (NXFileBase *fileItem in ((NSArray *)sectionDatas.allValues.firstObject)) {
                if ([fileItem isKindOfClass:[NXFile class]] || [fileItem isKindOfClass:[NXSharePointFile class]]) {
                    [tmpArray addObject:fileItem];
                }
            }
        }
    }
    return tmpArray;
}

@end
