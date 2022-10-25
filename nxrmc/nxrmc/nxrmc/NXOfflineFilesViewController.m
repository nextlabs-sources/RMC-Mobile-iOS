//
//  NXOfflineFilesViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/13.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOfflineFilesViewController.h"
#import "NXRepositorySysManager.h"
#import "NXFileSort.h"
#import "NXLoginUser.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "Masonry.h"
#import "NXMBManager.h"
#import "NXOfflineFileManager.h"
#import "NXOfflineFileCell.h"
#import "NXAlertView.h"
#import "DetailViewController.h"
#import "NXFilePropertyVC.h"
#import "NXPresentNavigationController.h"
#import "NXVaultManageViewController.h"
#import "NXFileActivityLogViewController.h"
#import "NXMyVaultFile.h"
#import "NXCommonUtils.h"
#import "NXProtectViewController.h"
#import "NXShareViewController.h"
#import "NXRMCDef.h"
#import "MyVaultSeachResultViewController.h"

@interface NXOfflineFilesViewController ()<DetailViewControllerDelegate>
@property(nonatomic, strong) NSArray *searchArray;
@property(nonatomic, assign) NXOfflineFileFilter fileFilter;
@end

@implementation NXOfflineFilesViewController
- (instancetype)init {
    NSAssert(NO, @"NXOfflineFilesViewController should declare the offline file filter!");
    return nil;
}

- (instancetype)initWithOfflineFilesFilter:(NXOfflineFileFilter) fileFilter {
    if (self = [super init]) {
        _fileFilter = fileFilter;
    }
    return self;
}

- (void)viewDidLoad {
     self.isOfflineVC = YES;
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    [NXMBManager showLoadingToView:self.view];
    
    self.allSortByTypes = @[@(NXSortOptionDateDescending), @(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
}

- (void)updateUI:(NSNotification *)noti
{
    [self updateUI];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self didFinshedGetFiles:[self offlineFilesByFileFilter] error:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - get offline files
- (NSArray<NXFileBase *> *)offlineFilesByFileFilter {
    NSArray<NXFileBase *> *data = nil;
    switch (self.fileFilter) {
        case NXOfflineFileFilterMyVaultAndSharedWithMe:
        {
            data = [[NXOfflineFileManager sharedInstance] allOfflineFileListFromMyVaultAndSharedWithMe];
        }
             break;
        case NXOfflineFileFilterWorkSpace:
        {
            data = [[NXOfflineFileManager sharedInstance] allOfflineFileListFromWorkSpace];
        }
              break;
            
        case NXOfflineFileFilterSharedWithMe:
        {
          data = [[NXOfflineFileManager sharedInstance] allOfflineFileListFromSharedWithMe];
        }
              break;
        case NXOfflineFileFilterMyVault:
        {
           data = [[NXOfflineFileManager sharedInstance] allOfflineFileListFromMyVault];
        }
              break;
        default:
            break;
    }
    return data;
}

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
    NSArray<NXFileBase *> *data = [self offlineFilesByFileFilter];
    self.dataArray = data;
    [self reloadData:data];
}

- (void)startSyncData {
    
}

- (void)stopSyncData {
    
}

- (void)pullDownRefreshWork {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        [NXMBManager hideHUDForView:self.view];
        NSArray<NXFileBase *> *data = [self offlineFilesByFileFilter];
        [self reloadData:data];
    });
}

- (Class)displayCellTypeClass {
      return [NXOfflineFileCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    
    if (item.sorceType == NXFileBaseSorceTypeProject && [item isKindOfClass:[NXOfflineFile class]]) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)item;
        NXProjectFile *projectFile = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:offlineFile];
        item = projectFile;
    }
    
    if (item.sorceType == NXFileBaseSorceTypeShareWithMe && [item isKindOfClass:[NXOfflineFile class]]) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)item;
        NXSharedWithMeFile *sharedWithMeFile = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:offlineFile];
        item = sharedWithMeFile;
    }
    
    if (item.sorceType == NXFileBaseSorceTypeWorkSpace && [item isKindOfClass:[NXOfflineFile class]]) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)item;
        NXWorkSpaceFile *workSpaceFile = [[NXOfflineFileManager sharedInstance] getWorkSpaceFilePartner:offlineFile];
        item = workSpaceFile;
    }
    
    if (item.sorceType == NXFileBaseSorceTypeSharedWithProject && [item isKindOfClass:[NXOfflineFile class]]) {
         NXOfflineFile *offlineFile = (NXOfflineFile *)item;
         NXSharedWithProjectFile *shareWithProjectFile = [[NXOfflineFileManager sharedInstance] getShareWithProjectFilePartner:offlineFile];
         item = shareWithProjectFile;
     }
    
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:item];
    if (state == NXFileStateOfflineFailed) {
        WeakObj(self);
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
    
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:item from:self withDelegate:self];
}

-(void)moreButtonLClicked:(NXFileBase *)item
{
    if (item.sorceType == NXFileBaseSorceTypeProject) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)item;
        NXProjectFile *projectFile = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:offlineFile];
        item = projectFile;
    }
    
    if (item.sorceType == NXFileBaseSorceTypeShareWithMe) {
        NSLog(@"99999999 -----%ld",(long)item.sorceType);
        NXOfflineFile *offlineFile = (NXOfflineFile *)item;
        NXSharedWithMeFile *sharedWithMeFile = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:offlineFile];
        item = sharedWithMeFile;
    }
    
    if (item.sorceType == NXFileBaseSorceTypeWorkSpace) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)item;
        NXWorkSpaceFile *workSpaceFile = [[NXOfflineFileManager sharedInstance] getWorkSpaceFilePartner:offlineFile];
        item = workSpaceFile;
    }
    
    if (item.sorceType == NXFileBaseSorceTypeSharedWithProject) {
          NXOfflineFile *offlineFile = (NXOfflineFile *)item;
          NXSharedWithProjectFile *shareWithProjectFile = [[NXOfflineFileManager sharedInstance] getShareWithProjectFilePartner:offlineFile];
          item = shareWithProjectFile;
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
    
//    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//        StrongObj(self);
//        NXShareViewController *vc = [[NXShareViewController alloc] init];
//        vc.fileItem = item;
//        vc.delegate = self;
//        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
//    }];
    
    // mark as favorite or unfavorite
    
//    if (item.sorceType == NXFileBaseSorceTypeProject || item.sorceType == NXFileBaseSorceTypeShareWithMe) {
//        // no favorite function for project file, share with me file has no mark as fav func too
//    }else if (item.isFavorite == YES) {
//        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//            [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:item withCompletion:^(NXFileBase *file) {
//                //TODO
//                StrongObj(self);
//                [self updateData];
//            }];
//        }];
//    }else{
//        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//            [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:item withCompleton:^(NXFileBase *file) {
//                //TODO
//                StrongObj(self);
//                [self updateData];
//            }];
//        }];
//    }
    
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
        
//        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
//            [[NXOfflineFileManager sharedInstance] markFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
//                StrongObj(self);
//                dispatch_main_async_safe(^{
//                    if (!error) {
//                        item.isOffline = YES;
//                        [self.tableView reloadData];
//                    }else{
//                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
//                    }
//                });
//            }];
//        }];
    }
    else if (state == NXFileStateOfflined) {
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

#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
     return self.dataArray;
}

#pragma mark - NXMyVaultSearchResultDelegate
- (void)offlineFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXOfflineFile *)item {
    [self didSelectItem:item];
}

- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem {
    [self moreButtonLClicked:fileItem];
}

- (void)swipeButtonClick:(SwipeButtonType)type fileItem:(NXFileBase *)fileItem {
    [super swipeButtonClick:type fileItem:fileItem];
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

@end

