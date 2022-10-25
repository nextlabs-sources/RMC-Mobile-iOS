//
//  NXFavoriteViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 22/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "NXFavoriteFileCell.h"
#import "NXMBManager.h"
#import "Masonry.h"
#import "NXAlertView.h"
#import "NXFilePropertyVC.h"
#import "NXPresentNavigationController.h"
#import "NXVaultManageViewController.h"
#import "NXFileActivityLogViewController.h"
#import "NXMyVaultFile.h"
#import "NXCommonUtils.h"
#import "NXFavoriteRepoFilesModel.h"
#import "NXFavoriteGetAllFavoriteFilesInReposAPI.h"
#import "NXFavoriteSpecificFileItemModel.h"
#import "NXProtectViewController.h"
#import "NXShareViewController.h"
#import "NXRMCDef.h"

@interface NXFavoriteViewController () <DetailViewControllerDelegate>
@property(nonatomic, assign) NXFavoriteFileFilter fileFilterType;
@end

@implementation NXFavoriteViewController
- (instancetype)initWithOfflineFilesFilter:(NXFavoriteFileFilter) fileFilterType {
    if (self = [super init]) {
        _fileFilterType = fileFilterType;
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
     //Do any additional setup after loading the view.
    [NXMBManager showLoadingToView:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteFileListDidChange:) name:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
    
    self.allSortByTypes = @[@(NXSortOptionDateDescending), @(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
}

- (void)favoriteFileListDidChange:(NSNotification *)notification
{
     [self pullDownRefreshWork];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.fileFilterType == NXFavoriteFileFilterMyDrive) {
        [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileListInMydrive] error:nil];
        
    }else if(self.fileFilterType == NXFavoriteFileFilterMyVault){
        [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileItemsInMyVault] error:nil];
    }else{
        [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileList] error:nil];
    }
   
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - override function

- (void)updateData{
   
    if (self.fileFilterType == NXFavoriteFileFilterMyDrive) {
        [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileListInMydrive] error:nil];
        
    }else if(self.fileFilterType == NXFavoriteFileFilterMyVault){
        [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileItemsInMyVault] error:nil];
    }else{
        [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileList] error:nil];
    }
}

- (void)startSyncData{
    //TODO
}

- (void)stopSyncData{
    //TODO
}

- (void)pullDownRefreshWork {
   WeakObj(self);
  [[NXLoginUser sharedInstance].favFileMarker getAllFavFileListFromNetWorkWithCompletion:^(NSArray *fileListArray, NSError *error) {
      dispatch_main_async_safe(^{
          StrongObj(self);
          [self.refreshControl endRefreshing];
          [NXMBManager hideHUDForView:self.view];
//          [self didFinshedGetFiles:fileListArray error:error];
          if (self.fileFilterType == NXFavoriteFileFilterMyDrive) {
              [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileListInMydrive] error:error];
              
          }else if(self.fileFilterType == NXFavoriteFileFilterMyVault){
              [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileItemsInMyVault] error:error];
          }else{
              [self didFinshedGetFiles:[[NXLoginUser sharedInstance].favFileMarker allFavFileList] error:error];
          }
      });
  }];
}

- (Class)displayCellTypeClass {
    return [NXFavoriteFileCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    
    if ([item isKindOfClass:[NXMyVaultFile class]]) {
           NXMyVaultFile *fileItem = (NXMyVaultFile *)item;
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
    }
    
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:item from:self withDelegate:self];
}

- (void)moreButtonLClicked:(NXFileBase *)item {
    
    NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:@""];
    WeakObj(self);
    
    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        [self didSelectItem:item];
    }];
    
    if (item.sorceType == NXFileBaseSorceTypeMyVaultFile) {
        
        NXMyVaultFile *myVauleFile = (NXMyVaultFile *)item;
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            NXFilePropertyVC *vc = [[NXFilePropertyVC alloc] init];
            vc.fileItem = item;
            vc.shouldOpen = YES;
            vc.isSteward = YES;
            vc.isFromFavPage = YES;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }];
        
        if (myVauleFile.isShared) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_MANAGE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                //            NSLog(@"++++%s+++++","Manage");
                StrongObj(self);
                
                NXVaultManageViewController *vc = [[NXVaultManageViewController alloc] init];
                vc.fileItem = myVauleFile;
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
                vc.fileItem = myVauleFile;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }];
        }
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
            logActivityVC.fileItem = item;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }];
    }
    else if (item.sorceType == NXFileBaseSorceTypeRepoFile)
    {
        WeakObj(self);
            NSString *extension = [item.name pathExtension];
            NSString *markExtension = [NSString stringWithFormat:@".%@", extension];
            BOOL isNXL = [markExtension compare:NXLFILEEXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame;
        
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
                property.fileItem = item;
                property.delegate = self;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }];
        
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                NXShareViewController *vc = [[NXShareViewController alloc] init];
                vc.fileItem = item;
                vc.delegate = self;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }];
            
            if (!isNXL) {
                [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_PROTECT", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                    StrongObj(self);
                    NXProtectViewController *vc = [[NXProtectViewController alloc] init];
                    vc.fileItem = item;
                    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }];
            }
    }
    
     // mark as favorite or unfavorite
    if (item.isFavorite == YES) {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:item withCompletion:^(NXFileBase *file) {
                //TODO
                StrongObj(self);
                [self updateData];
            }];
        }];
    }
    else
    {
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:item withCompleton:^(NXFileBase *file) {
                //TODO
                StrongObj(self);
                [self updateData];
            }];
        }];
    }
    
    // favorite delete
    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
        StrongObj(self);
        [self deleteFileItem:item];
    }];
    
    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
}

#pragma mark ---->delegate
- (void)deleteFileItem:(NXFileBase *)file {
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), file.name];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index==1){
            [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_DELETING", NULL) toView:self.view];
            [[NXLoginUser sharedInstance].favFileMarker removeFileFromFavList:file withCompletion:^(NXFileBase *file, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                    } else {
                       
//                        [[NXLoginUser sharedInstance].sharedFileManager updateCacheListArrayWhenDeleteItem:file];
                        [self pullDownRefreshWork];
                    }
                });
                //TODO
            }];
        }
    }];
}

#pragma mark
- (void)didFinshedGetFiles:(NSArray *)fileList error:(NSError *)error {
    if (error) {
        [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    self.dataArray = fileList;
    [self reloadData];
}

#pragma mark ---->delegate
- (void)deleteMyVaultFile:(NXMyVaultFile *)file {
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), file.name];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1){
            [NXMBManager showLoading:NSLocalizedString(@"Deleting", NULL) toView:self.view];
            [[NXLoginUser sharedInstance].myVault deleteFile:file withCompletion:^(NXMyVaultFile *file, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                    } else {
                       
//                        [[NXLoginUser sharedInstance].sharedFileManager updateCacheListArrayWhenDeleteItem:file];
                        [self pullDownRefreshWork];
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
                if ([fileItem isKindOfClass:[NXFile class]]) {
                    [tmpArray addObject:fileItem];
                }
            }
        }
    }
    return tmpArray;
}

@end
