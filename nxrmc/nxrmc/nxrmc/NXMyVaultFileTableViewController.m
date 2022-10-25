//
//  NXMyVaultFileTableViewController.m
//  nxrmc
//
//  Created by helpdesk on 16/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXMyVaultFileTableViewController.h"
#import "NXVaultManageViewController.h"
#import "NXShareViewController.h"
#import "NXPresentNavigationController.h"
#import "NXFileActivityLogViewController.h"

#import "NXMyVaultHeaderView.h"
#import "NXMyVaultCell.h"

#import "NXMBManager.h"
#import "Masonry.h"
#import "NXCommonUtils.h"
#import "NXMyVaultFile.h"
#import "AppDelegate.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "NXFileSort.h"
#import "NXMyVaultListParModel.h"
#import "NXSharePointFile.h"
#import "NXAlertView.h"
#import "NXEmptyView.h"
#import "NXFilePropertyVC.h"
#import "NXOfflineFileStorage.h"
#import "NXAddToProjectVC.h"
#import "NXOriginalFilesTransfer.h"
#import "NXNetworkHelper.h"
#define kSectionHeaderHeight 25
@interface NXMyVaultFileTableViewController ()<UITableViewDataSource, UITableViewDelegate, NXOperationVCDelegate, DetailViewControllerDelegate, NXMyVaultCellDelegate>

@property(nonatomic, strong)NSMutableArray *originArray;
@property(nonatomic ,strong)NSArray<NSDictionary<NSString *, NSArray*> *> *tableData;

@property(nonatomic, readonly, weak)UITableView *tableView;
@property(nonatomic, readonly, weak)UIRefreshControl *refreshControl;
@property(nonatomic, strong)NXEmptyView *emptyView;

@end

@implementation NXMyVaultFileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sortOption = NXSortOptionDateDescending;
    [self commonInit];
    [NXMBManager showLoadingToView:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteFileListDidChange:) name:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableview:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self pullDownRefreshWork];
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

- (void)favoriteFileListDidChange:(NSNotification *)notification
{
    [self updateData];
}

- (void)refreshTableview:(NSNotification *)notification
{
    [self updateData];
    [self reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return self.tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sec = self.tableData[section];
    NSArray<NXMyVaultFile *> *array = [sec objectForKey:[sec allKeys].firstObject];
    return array.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
    NXMyVaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray<NXMyVaultFile *> *array = [sec objectForKey:[sec allKeys].firstObject];
    
    cell.model = array[indexPath.row];
    cell.myVaultCellDelegate = self;
    NXMyVaultFile *model = (NXMyVaultFile *)cell.model;
    WeakObj(self);
    cell.swipeButtonBlock = ^(SwipeButtonType type){
        StrongObj(self);
        [self swipeButtonClick:type fileItem:model];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray<NXMyVaultFile *> *array = [sec objectForKey:[sec allKeys].firstObject];
    NXMyVaultFile *fileItem = array[indexPath.row];
    
    if (fileItem.isDeleted) {
        NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
        vc.fileItem = fileItem;
        vc.manageRevokeFinishedBlock = ^(NSError *error) {
            [self updateData];
        };
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        return;
    }

    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:fileItem from:self withDelegate:self];
}
#pragma mark ---->delegate
- (void)deleteMyVaultFile:(NXMyVaultFile *)file {
    WeakObj(self);
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), file.name];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index==1){
            
            // if current file is offline or converting offline ,unmark first
            NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:file];
            if (state != NXFileStateNormal)
            {
                [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:file withCompletion:^(NXFileBase *fileItem, NSError *error) {
                    dispatch_main_async_safe(^{
                        if (!error) {
                            [self updateData];
                        }else{
                            [self reloadData];
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                        }
                    });
                }];
            }
            
            [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_DELETING", NULL) toView:self.view];
            [[NXLoginUser sharedInstance].myVault deleteFile:file withCompletion:^(NXMyVaultFile *file, NSError *error) {
                StrongObj(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
                        return;
                    }
                    if ([self.originArray containsObject:file]) {
                        file.isDeleted = YES;
                        [self.originArray removeObject:file];
                    }
                    [self pullDownRefreshWork];
                });
            }];

        }
    }];
}
#pragma mark get new data
- (void)updateData {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myVault getMyVaultFileListUnderRootFolderWithFilterModel:self.listParModel shouldReadCache:YES withCompletion:^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
        StrongObj(self);
        dispatch_main_async_safe(^{
            [NXMBManager hideHUDForView:self.view];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                return;
            }
            @autoreleasepool {
                self.originArray = [NSMutableArray arrayWithArray:fileList];
                if (self.originArray.count == 0) {
                    self.emptyView.hidden = NO;
                    self.tableView.hidden = YES;
                }else {
                    self.emptyView.hidden = YES;
                    self.tableView.hidden = NO;
                }
                [self reloadData];
            }
        });
    }];
}

#pragma mark
- (void)pullDownRefreshWork {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myVault getMyVaultFileListUnderRootFolderWithFilterModel:self.listParModel shouldReadCache:NO withCompletion:^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
        StrongObj(self);
        dispatch_main_async_safe(^{
            [NXMBManager hideHUDForView:self.view];
            [self.refreshControl endRefreshing];
            if (error) {
                if (self.refreshControl.isRefreshing) {
                    [self.refreshControl endRefreshing];
                }
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                return;
            }
            @autoreleasepool {
                if(fileList && fileList.count > 0){
                    self.originArray = [NSMutableArray arrayWithArray:fileList];
                }
                if (self.originArray.count == 0) {
                    self.emptyView.hidden = NO;
                    self.tableView.hidden = YES;
                }else {
                    self.emptyView.hidden = YES;
                    self.tableView.hidden = NO;
                    [self reloadData];
                }
                [self reloadData];
            }
        });
    }];
}
#pragma mark ---->reloadData
- (void)setSortOption:(NXSortOption)sortOption {
    _sortOption = sortOption;
    
    [self reloadData];
}
#pragma mark
- (void)reloadData {
    @autoreleasepool {
        self.tableData = [NXFileSort keySortObjects:self.originArray option:_sortOption];
        [self.tableView reloadData];
    };
   
}

#pragma mark - NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    return self.originArray;
}

#pragma mark - NXMyVaultCellDelegate
- (void)onClickMoreButton:(NXMyVaultFile *)myVaultFile
{
   [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [NXMBManager showLoading];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:myVaultFile withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
            NXAlertView *alertView = [NXAlertView alertViewWithTitle:myVaultFile.name andMessage:@""];
             WeakObj(self);
            
            if (myVaultFile.isDeleted == YES) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    StrongObj(self);
                    NXFilePropertyVC *vc = [[NXFilePropertyVC alloc] init];
                    vc.fileItem = myVaultFile;
                    vc.shouldOpen = YES;
                    vc.isSteward = YES;
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                    [self presentViewController:nav animated:YES completion:nil];
                }];
                
                if (myVaultFile.isShared == YES) {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_MANAGE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        StrongObj(self);
                        NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
                        vc.fileItem = myVaultFile;
                        vc.manageRevokeFinishedBlock = ^(NSError *error) {
                            [self updateData];
                        };
                        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
                        [self.navigationController presentViewController:nav animated:YES completion:nil];
                    }];
                }
                
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    StrongObj(self);
                    [self myVaultFileListResultVC:nil didSelectItemInfo:myVaultFile];
                }];
                
                alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
                [alertView show];
                return;
            }
            
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                 StrongObj(self);
                if (myVaultFile.isDeleted) {
                    NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
                    vc.fileItem = myVaultFile;
                    vc.manageRevokeFinishedBlock = ^(NSError *error) {
                        [self updateData];
                    };
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    return;
                }
                
                AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [app showFileItem:myVaultFile from:self withDelegate:self];
            }];

            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                NXFilePropertyVC *vc = [[NXFilePropertyVC alloc] init];
                vc.fileItem = myVaultFile;
                vc.shouldOpen = YES;
                vc.isSteward = YES;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }];
            
            if (myVaultFile.isShared) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_MANAGE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        //            NSLog(@"++++%s+++++","Manage");
                     StrongObj(self);
                    
                    NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
                    vc.fileItem = myVaultFile;
                    vc.manageRevokeFinishedBlock = ^(NSError *error) {
                        [self updateData];
                    };
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }];
            }
            else
            {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        //            NSLog(@"++++%s+++++","Share");
                     StrongObj(self);
                    
                    NXShareViewController *vc = [[NXShareViewController alloc] init];
                    vc.delegate = self;
                    vc.fileItem = myVaultFile;
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }];
            }
            
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        //        NSLog(@"++++%s+++++","View Activity");
                 StrongObj(self);
                
                [self myVaultFileListResultVC:nil didSelectItemInfo:myVaultFile];
            }];
            if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                   
                    NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                    VC.currentFile = myVaultFile;
                    VC.fileOperationType = NXFileOperationTypeAddMyVaultFileToOther;
                    
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:VC];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:nav animated:YES completion:nil];
                }];
                
            }else{
                [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                    
                }];
            }
            if([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error){
                [alertView addItemWithTitle:@"Save as" type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    [NXMBManager showLoading];
                    [[NXLoginUser sharedInstance].nxlOptManager saveAsNXlFileToLocal:myVaultFile  withCompletion:^(NXFileBase *file, NSError *error) {
                        
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
            
                
            
            if (myVaultFile.isDeleted == NO || (myVaultFile.isRevoked == YES && myVaultFile.isDeleted == NO)) {
                // mark as favorite or unfavorite
                if (myVaultFile.isFavorite == YES) {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                          StrongObj(self);
                        [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:myVaultFile withCompletion:^(NXFileBase *file) {
                            myVaultFile.isFavorite = NO;
                            [self.tableView reloadData];
                           // [self updateData];
                        }];
                    }];
                }
                else
                {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:myVaultFile withCompleton:^(NXFileBase *file) {
                            StrongObj(self);
                            myVaultFile.isFavorite = YES;
                            [self.tableView reloadData];
                           // [self updateData];
                        }];
                    }];
                }
                NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:myVaultFile];
                if (state == NXFileStateOfflineFailed) {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        StrongObj(self);
                        [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:myVaultFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
                            dispatch_main_async_safe(^{
                                if (!error) {
                                    [self updateData];
                                }else{
                                    [self reloadData];
                                    [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                                }
                            });
                        }];
                    }];
        //            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        //                [[NXOfflineFileManager sharedInstance] markFileAsOffline:myVauleFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
        //                    StrongObj(self);
        //                    dispatch_main_async_safe(^{
        //                        if (!error) {
        //                            [self updateData];
        //                        }else{
        //                            [self reloadData];
        //                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
        //                        }
        //                    });
        //                }];
        //            }];
                }else if (myVaultFile.isOffline == YES || state == NXFileStateOfflined || state == NXFileStateConvertingOffline) {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        StrongObj(self);
                        [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:myVaultFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
                            dispatch_main_async_safe(^{
                                if (!error) {
                                    [self updateData];
                                }else{
                                    [self reloadData];
                                    [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                                }
                            });
                        }];
                    }];
                }else if (myVaultFile.isOffline == NO || state == NXFileStateNormal)
                {
                    NXAlertViewItemType type = NXAlertViewItemTypeDefault;
                    if (![NXCommonUtils isOfflineViewSupportFormat:myVaultFile]) {
                        type = NXAlertViewItemTypeClickForbidden;
                    }
                    
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_OFFLINE",NULL) type:type handler:^(NXAlertView *alertView) {
                        [[NXOfflineFileManager sharedInstance] markFileAsOffline:myVaultFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
                            StrongObj(self);
                                dispatch_main_async_safe(^{
                                    if (!error) {
                                        [self updateData];
                                    }else{
                                        [self reloadData];
                                         [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                                    }
                                });
                        }];
                    }];
                }
            }
            
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
        //        NSLog(@"++++%s+++++","Delete");
                 StrongObj(self);
                
                [self deleteMyVaultFile:myVaultFile];
            }];
            
            alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
            [alertView show];
            
        });
            
    }];
   
}

#pragma mark
- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem {
    [self onClickMoreButton:(NXMyVaultFile *)fileItem];
}

- (void)swipeButtonClick:(SwipeButtonType)type fileItem:(NXFileBase *)fileItem {
    if (![fileItem isKindOfClass:[NXMyVaultFile class]]) {
        return;
    }
    
    NXMyVaultFile *myVaultFile = (NXMyVaultFile *)fileItem;
    if (self) {
        switch (type) {
            case SwipeButtonTypeManage:
            {
                [self myVaultFileListResultVC:nil didSelectManageItem:myVaultFile];
            }
                break;
            case SwipeButtonTypeActiveLog:
            {
                [self myVaultFileListResultVC:nil didSelectItemInfo:myVaultFile];
            }
                break;
            case SwipeButtonTypeDelete:
            {
                [self deleteMyVaultFile:myVaultFile];
            }
                break;
            case SwipeButtonTypeShare:
            {
                [self myVaultFileListResultVC:nil didSelectShareItem:myVaultFile];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - NXOperationVCDelegate
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
    // reload data here for my vault file state may changed, need refresh UI(For example, protected file may moved to shared file)
    [self updateData];
}

#pragma mark - private method
- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXMyVaultFile *)item {
    [resultVC.view removeFromSuperview];
    
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:item];
    if (state == NXFileStateOfflineFailed) {
        WeakObj(self);
        [[NXOfflineFileManager sharedInstance] markFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
            StrongObj(self);
            dispatch_main_async_safe(^{
                if (!error) {
                    [self updateData];
                }else{
                    [self reloadData];
                    [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                }
            });
        }];
        return;
    }
    
    if (item.isDeleted) {
        NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
        vc.fileItem = item;
        vc.manageRevokeFinishedBlock = ^(NSError *error) {
            [self updateData];
        };
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        return;
    }
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:item from:self withDelegate:self];
}

- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItemInfo:(NXMyVaultFile *)item
{
    NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
    logActivityVC.fileItem = item;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectManageItem:(NXMyVaultFile *)item
{
    if (item.isShared) {
        NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
        vc.fileItem = item;
        vc.manageRevokeFinishedBlock = ^(NSError *error) {
            [self updateData];
        };
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }else{
        NXShareViewController *vc = [[NXShareViewController alloc] init];
        vc.delegate = self;
        vc.fileItem = item;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectShareItem:(NXMyVaultFile *)item
{
    NXShareViewController *vc = [[NXShareViewController alloc] init];
    vc.delegate = self;
    vc.fileItem = item;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark
- (void)commonInit {
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView = [[UITableView alloc]init];
    _tableView = tableView;
    [self.view addSubview:self.tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.sectionHeaderHeight = kSectionHeaderHeight;
    self.tableView.estimatedRowHeight = 70;
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kMargin * 4, 0);
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.tableView registerClass:[NXMyVaultCell class] forCellReuseIdentifier:@"cell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullDownRefreshWork) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor lightGrayColor];
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _refreshControl = refreshControl;
    [self.tableView addSubview:refreshControl];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
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
   if (((NXMyVaultFile*)newfile).isDeleted) {
        [self detailViewController:detailVC SwipeToPreFileFrom:newfile];
        return;
    }

    [detailVC openFile:newfile];
    [self.tableView reloadData];

}
- (void)detailViewController:(DetailViewController *)detailVC SwipeToNextFileFrom:(NXFileBase *)file
{
    NSArray *fileArray = [self sortedFileArray];
    NSUInteger index = [fileArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXFileBase *fileObj = (NXFileBase *)obj;
        if ([fileObj.fullServicePath isEqualToString:file.fullServicePath]) {
            *stop = YES;
            return YES;
        }else{
            *stop = NO;
            return NO;
        }
    }];
    
    if (index == fileArray.count - 1 || index == NSNotFound ) {
        // first file item, show alert
        [detailVC showAutoDismissLabel:NSLocalizedString(@"MSG_COM_SWIPE_NO_MORE_FILE_TO_SHOW", nil)];
        return;
    }
    NXFileBase *newfile = fileArray[index + 1];
    if (((NXMyVaultFile*)newfile).isDeleted) {
        // first file item, show alert
        [self detailViewController:detailVC SwipeToNextFileFrom:newfile];
        return;
    }
    
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
