
//
//  NXRepoFilesViewController.m
//  nxrmc
//
//  Created by nextlabs on 2/15/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepoFilesViewController.h"
#import "NXRepoFilesNavigationController.h"

#import "NXPresentNavigationController.h"

#import "NXFileItemCell.h"
#import "NXMBManager.h"
#import "NXAlertView.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"

#import "NXSharePointFolder.h"
#import "AppDelegate.h"
#import "NXShareViewController.h"
#import "NXFilePropertyVC.h"
#import "NXProtectViewController.h"
#import "NXVaultManageViewController.h"
#import "NXFileActivityLogViewController.h"
#import "MyVaultSeachResultViewController.h"
#import "NXProtectRepoFileSelectLocationVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXAddToProjectVC.h"
#import "NXSharedWorkspaceFile.h"
#import "NXOriginalFilesTransfer.h"
#import "NXNetworkHelper.h"
@interface NXRepoFilesViewController ()<NXRepoSystemFileInfoDelegate, NXOperationVCDelegate>

@property(nonatomic, strong) UIBarButtonItem *currentBarBtnItem;
@property(nonatomic, strong) UILabel *navTitleLabel;
@end

@implementation NXRepoFilesViewController
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
    [self pullDownRefreshWork];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopSyncData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (void)updateData {
    [[NXLoginUser sharedInstance].myRepoSystem fileListForParentFolder:self.currentFolder readCache:YES delegate:self];
}

- (void)startSyncData {
    [[NXLoginUser sharedInstance].myRepoSystem syncFilesInContentFolder:self.currentFolder delegate:self];
}

- (void)stopSyncData {
    [[NXLoginUser sharedInstance].myRepoSystem stopSyncFilesInContentFolder:self.currentFolder];
}

- (void)pullDownRefreshWork {
    [[NXLoginUser sharedInstance].myRepoSystem fileListForParentFolder:self.currentFolder readCache:NO delegate:self];
}

- (Class)displayCellTypeClass {
    return [NXFileItemCell class];
}

- (void)didSelectItem:(NXFileBase *)item {
    if ([self.navigationController isKindOfClass:[NXRepoFilesNavigationController class]]) {
        NXRepoFilesNavigationController *currentNavVC = (NXRepoFilesNavigationController*)self.navigationController;
        if ([item isKindOfClass:[NXFolder class]] ||
            [item isKindOfClass:[NXSharePointFolder class]] || [item isKindOfClass:[NXSharedWorkspaceFolder class]]) {
            NXRepoFilesViewController *vc = [[NXRepoFilesViewController alloc] init];
            vc.isOnlyNxlFile = currentNavVC.isOnlyNxlFile;
            vc.currentFolder = item;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app showFileItem:item from:self withDelegate:self];
        }
        
    }
   
}



//- (void)rightBarBtnClicked:(id)sender {
//    NXProjectInviteMemberView *memberView = [[NXProjectInviteMemberView alloc] initWithTitle:@"Invite Members" inviteHander:^(NXProjectInviteMemberView *alertView) {
//        NSLog(@"dsahdajskjdkajs");
//    }];
//    [memberView show];
//}

#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    return self.dataArray;
}

#pragma -mark
- (void)fileListResultVC:(NXFileListSearchResultVC *)resultVC didSelectItem:(id)item {
    [self didSelectItem:item];
}

#pragma mark - NXRepoSystemFileInfoDelegate
//auto update callback
- (void)updateFileListFromParentFolder:(NXFileBase *)parentFolder resultFileList:(NSArray *)resultFileList error:(NSError *) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.currentFolder isEqual:parentFolder]) { // for we do not have cancel get file interface, the async result maybe from other folder
            return;
        }
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        if(error.code == NXRMC_ERROR_CODE_NOSUCHFILE)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.isOnlyNxlFile) {
            NSMutableArray *nxlFiles = [NSMutableArray array];
            for (NXFileBase *fileItem in resultFileList) {
                if ([fileItem isKindOfClass:[NXFolder class]] || [fileItem isKindOfClass:[NXSharedWorkspaceFolder class]] || [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:fileItem]) {
                    [nxlFiles addObject:fileItem];
                }
            }
            self.dataArray = nxlFiles;
            [self reloadData];
        }else{
            if (resultFileList && resultFileList.count) {
                self.dataArray = resultFileList;
                [self reloadData];
            }
            
        }
       
    });
}

// manual update callback.
- (void)didGetFileListUnderParentFolder:(NXFileBase *)parentFolder fileList:(NSArray *)fileList error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        
        if (![self.currentFolder isEqual:parentFolder]) { // for we do not have cancel get file interface, the async result maybe from other folder
            return;
        }
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        
        if (error.code == NXRMC_ERROR_CODE_NOSUCHFILE) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (error.code == NXRMC_ERROR_CODE_CANCEL) {
            return;
        }
        
        if (error.code == NXRMC_ERROR_SERVICE_ACCESS_UNAUTHORIZED) {
            if (!parentFolder.isRoot) {
                NSString *errorMessage = NSLocalizedString(@"MSG_ACCESS_REPO_UNAUTHORIZED", nil);
                [NXMBManager showMessage:errorMessage hideAnimated:YES afterDelay:2 *kDelay ];
            }
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
        
        if (fileList) {
             [NXMBManager hideHUDForView:self.view];
            if (self.isOnlyNxlFile) {
                NSMutableArray *nxlFiles = [NSMutableArray array];
                for (NXFileBase *fileItem in fileList) {
                    if ([fileItem isKindOfClass:[NXFolder class]] || [fileItem isKindOfClass:[NXSharedWorkspaceFolder class]] || [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:fileItem]) {
                        [nxlFiles addObject:fileItem];
                    }
                }
                self.dataArray = nxlFiles;
                [self reloadData];
            }else{
                self.dataArray = fileList;
                [self reloadData];
            }
           
        }
    });
}

- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItemInfo:(NXMyVaultFile *)item
{
    NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
    logActivityVC.fileItem = item;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem {
    [NXMBManager showLoading];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:fileItem withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        
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
                        if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error && isValidity){
                            [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                                NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                                VC.currentFile = fileItem;
                                VC.fileOperationType = NXFileOperationTypeAddRepoProtectedFileToOther;
                                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:VC];
                                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                                [self presentViewController:nav animated:YES completion:nil];
                            }];
                            
                        }else{
                            [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                                
                            }];
                            
                        }
                       
                        if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error && isValidity) {
                            [alertView addItemWithTitle:@"Save as" type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                                [NXMBManager showLoading];
                                
                                [[NXLoginUser sharedInstance].nxlOptManager saveAsNXlFileToLocal:fileItem  withCompletion:^(NXFileBase *file, NSError *error) {
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
                    }
                    if (!isNXL) {
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_PROTECT", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                            StrongObj(self);
                            if (fileItem.serviceType.integerValue == kServiceGoogleDrive && extension.length == 0) {
                                NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_RENDER_FILE_NOT_SUPPORT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_FILE_TYPE_DO_NOT_SUPPORT_PROTECT_AND_SHARE", nil)}];
                                [NXMBManager showMessage:error.localizedDescription image:nil hideAnimated:YES afterDelay:3*kDelay ];
                                return;
                            }
                            
                            NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
                            VC.filesArray = @[fileItem];
                            VC.locationType = NXProtectSaveLoactionTypeFileRepo;
                            if (fileItem.serviceType.integerValue == kServiceOneDriveApplication) {
                                VC.locationType = NXProjectSaveLocationTypeSharedWorkSpace;
                            }
                            VC.saveFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:fileItem];
                            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
                            [self.navigationController presentViewController:nav animated:YES completion:nil];
                        
                        }];
                    }
            }

   
            alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
            [alertView show];
        });
    }];
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
- (BOOL)checkIsHaveSaveAsPermissionForFile:(NXFileBase *)file {
    if ([[NXLoginUser sharedInstance] isTenantAdmin]) {
        return YES;
    }else{
        __block BOOL isHave = NO;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:file withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
            if (rights && [rights DownloadRight]) {
                isHave = YES;
            }
            dispatch_semaphore_signal(sema);
            
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return isHave;
    }
}
@end
