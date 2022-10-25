//
//  NXMyDriveFavoritesVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 11/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXMyDriveFavoritesVC.h"
#import "NXFileItemCell.h"
#import "Masonry.h"
#import "NXFileSort.h"
#import "NXSharePointFolder.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
#import "NXAlertView.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "NXFilePropertyVC.h"
#import "NXLocalShareVC.h"
#import "NXPresentNavigationController.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
@interface NXMyDriveFavoritesVC ()<DetailViewControllerDelegate>
@property (nonatomic, strong) NSArray *searchArray;
@property (nonatomic, strong) NXRepositoryModel *myDriveModel;
@end

@implementation NXMyDriveFavoritesVC
- (NSArray *)searchArray {
    if (!_searchArray) {
        _searchArray = [NSArray array];
    }
    return _searchArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   // Do any additional setup after loading the view.
        NSArray *repoArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
        for (NXRepositoryModel *repoModel in repoArray) {
            if (repoModel.service_type.integerValue == kServiceSkyDrmBox ) {
                self.myDriveModel = repoModel;
            }
        }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateData];
}
#pragma mark - overwrite
- (void)updateData {
    NSArray<NXFileBase *> *data = [[NXLoginUser sharedInstance].favFileMarker allFavFileListInMydrive];
    self.dataArray = data;
    [self reloadData:data];
}

- (void)startSyncData {
    
}

- (void)stopSyncData {
    
}

- (void)pullDownRefreshWork {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray<NXFileBase *> *data = [[NXLoginUser sharedInstance].favFileMarker allFavFileListInMydrive];
        [self reloadData:data];
    });
}

- (Class)displayCellTypeClass {
    return [NXFileItemCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showFileItem:item from:self withDelegate:self];
}
- (void)reloadData:(NSArray<NXFileBase *> *)fileList {
    self.tableData = [NXFileSort keySortObjects:[NSMutableArray arrayWithArray:fileList] option:self.sortOption];
    _searchArray = fileList;
    if (self.tableData.count) {
        [self removeEmptyView];
    } else {
        [self showEmptyView:NSLocalizedString(@"UI_NO_FAVORITE_FILES", NULL) image:nil];
    }
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
                fileItem.isFavorite = NO;
                [self.tableView reloadData];
                    [self updateData];
                }];
        }];
        }else{
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_MARK_AS_FAVORITE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:fileItem withCompleton:^(NXFileBase *file) {
                    fileItem.isFavorite = YES;
                    [self.tableView reloadData];
                    [self updateData];
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
#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    return self.searchArray;
}


#pragma -mark
- (void)fileListResultVC:(NXFileListSearchResultVC *)resultVC didSelectItem:(id)item {
    [self didSelectItem:item];
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
