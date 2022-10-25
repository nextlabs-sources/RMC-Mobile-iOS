//
//  NXProjectOfflineFileVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/9/19.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXProjectOfflineFileVC.h"
#import "NXOfflineFileCell.h"
#import "NXMBManager.h"
#import "AppDelegate.h"
#import "NXAlertView.h"
#import "NXFilePropertyVC.h"
#import "NXPresentNavigationController.h"
#import "NXCommonUtils.h"
#import "MyVaultSeachResultViewController.h"
@interface NXProjectOfflineFileVC ()<DetailViewControllerDelegate>

@end

@implementation NXProjectOfflineFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isOfflineVC = YES;
//    self.view.backgroundColor = [UIColor redColor];
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self didFinshedGetFiles:[[NXOfflineFileManager sharedInstance] allOfflineFileListFromProject:self.projectModel.projectId] error:nil];
}
- (void)updateUI:(NSNotification *)noti
{
    [self updateUI];
    [self.tableView reloadData];
}
#pragma mark get all offline files
- (void)didFinshedGetFiles:(NSArray *)fileList error:(NSError *)error {
    if (error) {
        [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    self.dataArray = fileList;
    [self reloadData:fileList];
}
#pragma mark - overwrite
- (void)updateData {
    NSArray<NXFileBase *> *data = [[NXOfflineFileManager sharedInstance] allOfflineFileListFromProject:self.projectModel.projectId];
    [self reloadData:data];
}

- (void)startSyncData {
    
}

- (void)stopSyncData {
    
}
- (void)reloadData:(NSArray<NXFileBase *> *)fileList {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<NSDictionary *> *result = [NXFileSort keySortObjects:[NSMutableArray arrayWithArray:fileList] option:self.sortOption];
        dispatch_main_async_safe(^{
            self.tableData = result;
            [NXMBManager hideHUDForView:self.view];
            //  for the reload data like async, so we need remove loading view here
            
            //            if (self.tableData.count){
            //                [self removeEmptyView];
            //            } else {
            //                [self showEmptyView:NSLocalizedString(@"UI_NO_OFFLINE_FILES", NULL) image:nil];
            //            }
        });
    });
}
- (void)pullDownRefreshWork {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 1.just refresh file list
        [self.refreshControl endRefreshing];
        [NXMBManager hideHUDForView:self.view];
        NSArray<NXFileBase *> *data = [[NXOfflineFileManager sharedInstance] allOfflineFileListFromProject:self.projectModel.projectId];
        [self reloadData:data];
    //2.refresh file token and rights
//        WeakObj(self);
//        [[NXOfflineFileManager sharedInstance] refreshOfflineFileList:self.dataArray withCompletion:^(NSError *error) {
//            dispatch_main_async_safe(^{
//                StrongObj(self);
//                [self.refreshControl endRefreshing];
//                [NXMBManager hideHUDForView:self.view];
//                NSArray<NXFileBase *> *data = [[NXOfflineFileManager sharedInstance] allOfflineFileList];
//                [self reloadData:data];
//            });
//        }];
    });
}

- (Class)displayCellTypeClass {
    return [NXOfflineFileCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:item];
    if (state == NXFileStateOfflineFailed) {
        if ([item isKindOfClass:[NXOfflineFile class]]) {
            switch (item.sorceType) {
                case NXFileBaseSorceTypeProject:
                    {
                        item = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:(NXOfflineFile *)item];
                    }
                    break;
                case NXFileBaseSorceTypeMyVaultFile:
                    {
                        item = [[NXOfflineFileManager sharedInstance] getMyVaultFilePartner:(NXOfflineFile *)item];
                    }
                    break;
                case NXFileBaseSorceTypeShareWithMe:
                    {
                        item = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:(NXOfflineFile *)item];
                    }
                    break;
                case NXFileBaseSorceTypeWorkSpace:
                    {
                        item = [[NXOfflineFileManager sharedInstance] getWorkSpaceFilePartner:(NXOfflineFile *)item];
                    }
                    break;
                case NXFileBaseSorceTypeSharedWithProject:
                    {
                        item = [[NXOfflineFileManager sharedInstance] getShareWithProjectFilePartner:(NXOfflineFile *)item];
                    }
                    break;
                default:
                    break;
            }
        }
        WeakObj(self);
        if (item) {
            [[NXOfflineFileManager sharedInstance] markFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                       StrongObj(self);
                       dispatch_main_async_safe(^{
                           if (!error) {
                               item.isOffline = YES;
                               [self.tableView reloadData];
                           }else{
                               [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                           }
                       });
                   }];
                   return;
        }
    }
    if (item) {
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:item from:self withDelegate:self];
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)moreButtonLClicked:(NXFileBase *)item
{
    if (item.sorceType == NXFileBaseSorceTypeProject) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)item;
        NXProjectFile *projectFile = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:offlineFile];
        item = projectFile;
    }
    
    NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:@""];
    WeakObj(self);
    
    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        [self didSelectItem:item];
    }];
    
    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
        property.fileItem = item;
        property.delegate = self;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }];
    

    // mark as offline or unmark as offline
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:item];
    if (state == NXFileStateOfflineFailed) {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                dispatch_main_async_safe(^{
                    if (!error) {
                        [self updateData];
                    }else{
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                    }
                });
            }];
        }];
        
    }else if (state == NXFileStateOfflined) {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                dispatch_main_async_safe(^{
                    if (!error) {
                        [self updateData];
                    }else{
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                    }
                });
            }];
        }];
    }else{
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
                    }
                });
            }];
        }];
    }
    
    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
}
- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem {
    [self moreButtonLClicked:fileItem];
}
- (void)swipeButtonClick:(SwipeButtonType)type fileItem:(NXFileBase *)fileItem {
    NXProjectFile *projectFile = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:(NXOfflineFile*)fileItem];
    [super swipeButtonClick:type fileItem:projectFile];
}
#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    return self.dataArray;
}

#pragma mark - NXMyVaultSearchResultDelegate
- (void)offlineFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXOfflineFile *)item {
    [self didSelectItem:item];
}
- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXMyVaultFile *)item {
    
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
                if ([fileItem isKindOfClass:[NXFile class]]) {
                    [tmpArray addObject:fileItem];
                }
            }
        }
    }
    return tmpArray;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
