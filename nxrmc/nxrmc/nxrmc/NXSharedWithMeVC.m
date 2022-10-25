//
//  NXSharedWithMeVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 8/1/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSharedWithMeVC.h"
#import "NXNetworkHelper.h"
#import "NXPresentNavigationController.h"
#import "NXFilePropertyVC.h"
#import "NXShareViewController.h" 

#import "NXMBManager.h"
#import "NXSharedFileCell.h"
#import "NXAlertView.h"

#import "NXLoginUser.h"
#import "AppDelegate.h"
#import "NXSharePointFolder.h"
#import "NXFolder.h"
#import "NXSharedWithMeFile.h"
#import "NXOfflineFileManager.h"
#import "NXCommonUtils.h"
#import "NXLRights.h"
#import "NXOriginalFilesTransfer.h"
#import "NXSharedWithMeFileListParameterModel.h"
#import "NXAddToProjectVC.h"
#import "NXNetworkHelper.h"
@interface NXSharedWithMeVC ()

@property(nonatomic, strong) NXSharedWithMeFileListParameterModel *parModel;

@end

@implementation NXSharedWithMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _parModel = [[NXSharedWithMeFileListParameterModel alloc] init];
    _parModel.orderByType = NXSharedWithMeFileListOrderBySharedByDescending;
    
    [NXMBManager showLoadingToView:self.view];
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionSizeAscending), @(NXSortOptionSharedByAscending)];
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

- (void)refresh:(NSNotification *)notification
{
    [self updateData];
    [self reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
- (void)updateData {
    WeakObj(self);
    [[NXLoginUser sharedInstance].sharedFileManager getSharedWithMeFileListWithParameterModel:nil shouldReadCache:YES wtihCompletion:^(NXSharedWithMeFileListParameterModel *parameterModel, NSArray *fileListArray, NSError *error) {
        [NXMBManager hideHUDForView:self.view];
        StrongObj(self);
        dispatch_main_sync_safe(^{
            [NXMBManager hideHUDForView:self.view];
            [self didFinshedGetFiles:fileListArray error:error];
        })
    }];
}

- (void)startSyncData {
    
}

- (void)stopSyncData {
    
}

- (void)pullDownRefreshWork {
    WeakObj(self);
    [[NXLoginUser sharedInstance].sharedFileManager getSharedWithMeFileListWithParameterModel:self.parModel shouldReadCache:NO wtihCompletion:^(NXSharedWithMeFileListParameterModel *parameterModel, NSArray *fileListArray, NSError *error) {
        StrongObj(self);
        dispatch_main_async_safe(^{
            [NXMBManager hideHUDForView:self.view];
            [self.refreshControl endRefreshing];
            [self didFinshedGetFiles:fileListArray error:error];
        })
    }];
}

- (Class)displayCellTypeClass {
    return [NXSharedFileCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    if ([item isKindOfClass:[NXFolder class]] ||
        [item isKindOfClass:[NXSharePointFolder class]]) {
        //TODO
    } else {
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:item from:self withDelegate:self];
    }
}
- (void)moreButtonLClicked:(NXFileBase *)item {
    if (![item isKindOfClass:[NXSharedWithMeFile class]]) {
        return;
    }
    [NXMBManager showLoading];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:item withWatermark:YES withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        NXSharedWithMeFile *fileItem = (NXSharedWithMeFile *)item;
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
            NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:@""];
            WeakObj(self);
            if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && ([rights getRight:NXLRIGHTVIEW] || fileItem.isOwner)) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [app showFileItem:fileItem from:self withDelegate:self];
                }];
            }else{
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                    
                }];
            }
        
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                NXFilePropertyVC *vc = [[NXFilePropertyVC alloc] init];
                vc.fileItem = fileItem;
                vc.shouldOpen = NO;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }];
        
            if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && ([rights getRight:NXLRIGHTSHARING] || fileItem.isOwner)) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_RESHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    StrongObj(self);
                    NXShareViewController *vc = [[NXShareViewController alloc] init];
                    vc.fileItem = fileItem;
                    vc.delegate = self;
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }];
            }else{
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_RESHARE",NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                    
                }];
            }
            if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error && isValidity && ([rights DownloadRight] || [rights DecryptRight])) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                   
                    NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                    VC.currentFile = fileItem;
                    VC.fileOperationType = NXFileOperationTypeAddSharedWithMeFileToOther;
                    
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:VC];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:nav animated:YES completion:nil];
                }];
                
            }else{
                [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                    
                }];
            }
            if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && [rights DownloadRight] && isValidity) {
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
                                                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
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
            NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:fileItem];
            if (state == NXFileStateOfflineFailed) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    StrongObj(self);
                    [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:fileItem withCompletion:^(NXFileBase *fileItem, NSError *error) {
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
            }else if (state == NXFileStateOfflined || state == NXFileStateConvertingOffline) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    StrongObj(self);
                    [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:fileItem withCompletion:^(NXFileBase *fileItem, NSError *error) {
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
            }else if (fileItem.isOffline == NO || state == NXFileStateNormal){
                NXAlertViewItemType type = NXAlertViewItemTypeDefault;
                if (![NXCommonUtils isOfflineViewSupportFormat:fileItem]) {
                    type = NXAlertViewItemTypeClickForbidden;
                }
                
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_OFFLINE",NULL) type:type handler:^(NXAlertView *alertView) {
                    [[NXOfflineFileManager sharedInstance] markFileAsOffline:fileItem withCompletion:^(NXFileBase *fileItem, NSError *error) {
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
        
                alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
                [alertView show];
        });
    }];
    
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
                if ([fileItem isKindOfClass:[NXFile class]]) {
                    [tmpArray addObject:fileItem];
                }
            }
        }
    }
    return tmpArray;
}

@end
