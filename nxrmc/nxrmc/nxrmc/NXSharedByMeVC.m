//
//  NXSharedByMeVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 8/1/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSharedByMeVC.h"

#import "NXPresentNavigationController.h"
#import "NXFilePropertyVC.h"
#import "NXFileActivityLogViewController.h"
#import "NXVaultManageViewController.h"
#import "NXShareViewController.h"

#import "NXMBManager.h"
#import "NXSharedFileCell.h"
#import "NXMBManager.h"
#import "NXAlertView.h"
#import "NXCommonUtils.h"

#import "AppDelegate.h"

@interface NXSharedByMeVC ()

@property(nonatomic, strong) NXMyVaultListParModel *parModel;

@end

@implementation NXSharedByMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _parModel = [[NXMyVaultListParModel alloc] init];
    _parModel.filterType = NXMyvaultListFilterTypeActivedTransaction;
    
    [NXMBManager showLoadingToView:self.view];
    self.allSortByTypes = @[@(NXSortOptionDateDescending), @(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self pullDownRefreshWork];
}

- (void)refresh:(NSNotification *)notification
{
    [self updateData];
    [self reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - override function
- (void)updateData {
    WeakObj(self);
    [[NXLoginUser sharedInstance].sharedFileManager getSharedByMeFileListWithParameterModel:self.parModel shouldReadCache:YES withCompletion:^(NXMyVaultListParModel *parameterModel, NSArray *fileListArray, NSError *error) {
        StrongObj(self);
        dispatch_main_sync_safe(^{
            [self didFinshedGetFiles:fileListArray error:error];
        })
    }];
}

- (void)startSyncData {
    //TODO
}

- (void)stopSyncData {
    //TODO
}

- (void)pullDownRefreshWork {
    WeakObj(self);
    [[NXLoginUser sharedInstance].sharedFileManager getSharedByMeFileListWithParameterModel:self.parModel shouldReadCache:NO withCompletion:^(NXMyVaultListParModel *parameterModel, NSArray *fileListArray, NSError *error) {
        dispatch_main_async_safe(^{
            StrongObj(self);
            [self.refreshControl endRefreshing];
            [NXMBManager hideHUDForView:self.view];
            [self didFinshedGetFiles:fileListArray error:error];
        });
    }];
}

- (Class)displayCellTypeClass {
    return [NXSharedFileCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:item from:self withDelegate:self];
}

- (void)moreButtonLClicked:(NXFileBase *)item {
    if (![item isKindOfClass:[NXMyVaultFile class]]) {
        return;
    }
    NXMyVaultFile *myVauleFile = (NXMyVaultFile *)item;
    
    NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:@""];
     WeakObj(self);
    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        if (myVauleFile.isDeleted) {
            NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
            vc.fileItem = myVauleFile;
            vc.manageRevokeFinishedBlock = ^(NSError *error) {
                [self updateData];
            };
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        } else {
            AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app showFileItem:myVauleFile from:self withDelegate:self];
        }
    }];

    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        NXFilePropertyVC *vc = [[NXFilePropertyVC alloc] init];
        vc.fileItem = myVauleFile;
        vc.shouldOpen = YES;
        vc.isSteward = YES;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }];
    
    [alertView addItemWithTitle:NSLocalizedString(@"UI_MANAGE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
        vc.fileItem = myVauleFile;
        vc.manageRevokeFinishedBlock = ^(NSError *error) {
            [self updateData];
        };
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }];
    
    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
        logActivityVC.fileItem = item;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }];
    
    // mark as favorite or unfavorite
    if (myVauleFile.isFavorite == YES) {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:myVauleFile withCompletion:^(NXFileBase *file) {
                 StrongObj(self);
                myVauleFile.isFavorite = YES;
                [self.tableView reloadData];
                [self updateData];
            }];
        }];
    }
    else
    {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:myVauleFile withCompleton:^(NXFileBase *file) {
                StrongObj(self);
                myVauleFile.isFavorite = YES;
                [self.tableView reloadData];
                [self updateData];
            }];
        }];
    }
    
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:myVauleFile];
    if (state == NXFileStateOfflineFailed) {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:myVauleFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
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
    }else if (myVauleFile.isOffline == YES || state == NXFileStateOfflined || state == NXFileStateConvertingOffline) {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:myVauleFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
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
    }else if (myVauleFile.isOffline == NO || state == NXFileStateNormal)
    {
        NXAlertViewItemType type = NXAlertViewItemTypeDefault;
        if (![NXCommonUtils isOfflineViewSupportFormat:myVauleFile]) {
            type = NXAlertViewItemTypeClickForbidden;
        }
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_OFFLINE",NULL) type:type handler:^(NXAlertView *alertView) {
            [[NXOfflineFileManager sharedInstance] markFileAsOffline:myVauleFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
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
    
    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
        StrongObj(self);
        [self deleteMyVaultFile:myVauleFile];
    }];
    
    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
}

#pragma mark
- (void)didFinshedGetFiles:(NSArray *)fileList error:(NSError *)error {
    if (error) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_GETFILE_FAIL", nil) toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    self.dataArray = fileList;
    [self reloadData];
}

#pragma mark ---->delegate
- (void)deleteMyVaultFile:(NXMyVaultFile *)file {
    WeakObj(self);
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), file.name];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1){
            StrongObj(self);
            [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_DELETING", NULL) toView:self.view];
            [[NXLoginUser sharedInstance].myVault deleteFile:file withCompletion:^(NXMyVaultFile *file, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                    } else {
//                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_SHAREDBYME_DELETE_SUCCESS", NULL), file.name];
//                        [NXMBManager showMessage:message hideAnimated:YES afterDelay:kDelay*2];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelay*2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            [[NXLoginUser sharedInstance].sharedFileManager updateCacheListArrayWhenDeleteItem:file];
                            [self pullDownRefreshWork];
//                        });
                    }
                });
            }];
        }
    }];
}

#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    return self.dataArray;
}

#pragma mark - NXMyVaultSearchResultDelegate
- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXMyVaultFile *)item {
    [self didSelectItem:item];
}

- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem {
    [self moreButtonLClicked:fileItem];
}

- (void)swipeButtonClick:(SwipeButtonType)type fileItem:(NXFileBase *)fileItem {
    [super swipeButtonClick:type fileItem:fileItem];
}

#pragma mark - DetailViewDelegate
- (void)detailViewController:(DetailViewController *)detailVC SwipeToPreFileFrom:(NXFileBase *)file
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
    if (index == 0 || index == NSNotFound) {
        // first file item, show alert
        [detailVC showAutoDismissLabel:NSLocalizedString(@"MSG_COM_SWIPE_NO_MORE_FILE_TO_SHOW", nil)];
        return;
    }
    NXFileBase *newfile = fileArray[index - 1];
    [detailVC openFile:newfile];
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
    [detailVC openFile:newfile];
}

- (NSArray *)sortedFileArray {
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSDictionary *sectionDatas in self.tableData) {
        if ([sectionDatas.allValues.firstObject isKindOfClass:[NSArray class]] && ((NSArray *)sectionDatas.allValues.firstObject).count) {
            for (NXFileBase *fileItem in ((NSArray *)sectionDatas.allValues.firstObject)) {
                @autoreleasepool {
                    if ([fileItem isKindOfClass:[NXFile class]]) {
                        [tmpArray addObject:fileItem];
                    }
                }
            }
        }
    }
    return tmpArray;
}


@end
