//
//  NXMyDriveFilesListVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 11/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXMyDriveFilesListVC.h"

#import "NXFileItemCell.h"

#import "NXFileSort.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
#import "NXLocalShareVC.h"
#import "NXSharePointFolder.h"
#import "AppDelegate.h"
#import "NXAlertView.h"
#import "NXRepositoryModel.h"
#import "NXFilePropertyVC.h"
#import "NXShareViewController.h"
#import "NXPresentNavigationController.h"
#import "NXProtectViewController.h"
#import "NXProtectRepoFileSelectLocationVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
@interface NXMyDriveFilesListVC ()<NXSearchDataSourceProtocol, NXFileListSearchResultDelegate,NXRepoSystemFileInfoDelegate>
@property(nonatomic, strong) UIBarButtonItem *currentBarBtnItem;
@property(nonatomic, strong) UILabel *navTitleLabel;
@property(nonatomic, strong) NXRepositoryModel *myDriveModel;
@end

@implementation NXMyDriveFilesListVC
@dynamic currentFolder;
- (UILabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _navTitleLabel.textColor = self.navigationController.navigationBar.tintColor;
        _navTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _navTitleLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [NXMBManager showLoadingToView:self.view];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.currentFolder.isRoot) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navTitleLabel.text = self.currentFolder.name;
        self.navigationItem.titleView = self.navTitleLabel;
    }
    [self updateData];
}
#pragma mark - overwrite
- (void)updateData {
    self.myDriveModel = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
    if (self.currentFolder.isRoot) {
        [[NXLoginUser sharedInstance].myRepoSystem fileListForRepository:self.myDriveModel readCache:YES delegate:self];
    }else {
        [[NXLoginUser sharedInstance].myRepoSystem fileListForParentFolder:self.currentFolder readCache:YES delegate:self];
    }
}

- (void)startSyncData {
    [[NXLoginUser sharedInstance].myRepoSystem syncFilesInContentFolder:self.currentFolder delegate:self];
}

- (void)stopSyncData {
    [[NXLoginUser sharedInstance].myRepoSystem stopSyncFilesInContentFolder:self.currentFolder];
}

- (void)pullDownRefreshWork {
    if (self.currentFolder.isRoot) {
        [[NXLoginUser sharedInstance].myRepoSystem fileListForRepository:self.myDriveModel readCache:NO delegate:self];
    }else {
        [[NXLoginUser sharedInstance].myRepoSystem fileListForParentFolder:self.currentFolder readCache:NO delegate:self];
    }
}

- (Class)displayCellTypeClass {
    return [NXFileItemCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    if ([item isKindOfClass:[NXFolder class]]) {
        NXMyDriveFilesListVC *vc = [[NXMyDriveFilesListVC alloc] init];
        vc.currentFolder = item;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:item from:self withDelegate:self];
        
    }
}
#pragma mark - NXOperationVCDelegate
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
    [self updateData];
}

- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didCancelOperationFile:(NXFileBase *)file {
    [self updateData];
}
#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    return self.dataArray;
}

#pragma -mark
- (void)fileListResultVC:(NXFileListSearchResultVC *)resultVC didSelectItem:(id)item {
    [self didSelectItem:item];
}

- (void)reloadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<NSDictionary *> * result =  [NXFileSort keySortObjects:[NSMutableArray arrayWithArray:self.dataArray] option:self.sortOption];
        dispatch_main_async_safe(^{
            self.tableData = result;
            [NXMBManager hideHUDForView:self.view]; //  for the reload data like async, so we need remove loading view here
        });
    });
    
}
- (void)didGetFileListUnderParentFolder:(NXFileBase *)parentFolder fileList:(NSArray *)fileList error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.currentFolder isEqual:parentFolder]) { // for we do not have cancel get file interface, the async result maybe from other folder
            return;
        }
        [NXMBManager hideHUDForView:self.view];
        [self.refreshControl endRefreshing];
        
        if (error.code == NXRMC_ERROR_CODE_NOSUCHFILE) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (error.code == NXRMC_ERROR_CODE_CANCEL) {
            return;
        }
        
        [[NXLoginUser sharedInstance].myRepoSystem syncFilesInContentFolder:parentFolder delegate:self];
        
        // display error content
        if (error.code == NXRMC_ERROR_NO_NETWORK) {
            [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_NETWORK_UNREACH", nil)];
            return;
        }
        if (error && error.localizedDescription) {
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }

            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
        }
        if (!error) {
            [NXMBManager hideHUDForView:self.view];
            if (fileList.count) {
                self.dataArray = fileList;
                [self reloadData];
                [self removeEmptyView];
            } else {
                 self.dataArray = fileList;
                 [self reloadData];
                [self showEmptyView:nil image:nil];
            }
        }
    });
}
- (void)updateFileListFromParentFolder:(NXFileBase *)parentFolder resultFileList:(NSArray *)resultFileList error:(NSError *) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.currentFolder isEqual:parentFolder]) { // for we do not have cancel get file interface, the async result maybe from other folder
            return;
        }
        
        if(error.code == NXRMC_ERROR_CODE_NOSUCHFILE)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if (!error) {
            if (resultFileList.count > 0) {
                self.dataArray = resultFileList;
                [self reloadData];
                [self removeEmptyView];
            } else {
                [self showEmptyView:nil image:nil];
            }
        }
    });
}
- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem {
    NXAlertView *alertView = [NXAlertView alertViewWithTitle:fileItem.name andMessage:@""];
    
    WeakObj(self);
    if ([fileItem isKindOfClass:[NXFolder class]] || [fileItem isKindOfClass:[NXSharePointFolder class]]) {

    } else {
        NSString *extension = [fileItem.name pathExtension];
        NSString *markExtension = [NSString stringWithFormat:@".%@", extension];
        BOOL isNXL = [markExtension compare:NXLFILEEXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame;
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [self didSelectItem:fileItem];
        }];
        
        if (isNXL) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
                property.fileItem = fileItem;
                property.delegate = self;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }];
        }
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            NXLocalShareVC *vc = [[NXLocalShareVC alloc] init];
            vc.fileItem = fileItem;
            vc.delegate = self;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }];
        
        if (!isNXL) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_PROTECT", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                StrongObj(self);
                NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
//                VC.fileItem = fileItem;
                VC.filesArray = @[fileItem];
                VC.locationType = NXProtectSaveLoactionTypeMyVault;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
    
            }];
        }
    }
    
    if ((![fileItem isKindOfClass:[NXFolder class]])) {
            // mark as favorite or unfavorite
        if (fileItem.isFavorite == YES) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:fileItem withCompletion:^(NXFileBase *file) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fileItem.isFavorite = NO;
                        [self updateData];
                        [self.tableView reloadData];
                    });
               
                }];
        }];
        }else{
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:fileItem withCompleton:^(NXFileBase *file) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fileItem.isFavorite = YES;
                        [self updateData];
                        [self.tableView reloadData];
                    });
                   
                }];
            }];
        }
    }
        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [self deleteFileItem:fileItem];
        }];
    
    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
