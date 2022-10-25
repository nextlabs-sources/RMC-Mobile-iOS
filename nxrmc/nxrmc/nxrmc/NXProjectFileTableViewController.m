//
//  NXProjectFileTableViewController.m
//  nxrmc
//
//  Created by EShi on 1/24/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectFileTableViewController.h"

#import "NXProjectNewFolderVC.h"
#import "NXProjectsNavigationController.h"
#import "NXFilePropertyVC.h"
#import "NXProjectUploadVC.h"
#import "NXPresentNavigationController.h"
#import "NXFileActivityLogViewController.h"

#import "NXMBManager.h"
#import "NXProjectFileItemCell.h"
#import "NXMyVaultHeaderView.h"
#import "Masonry.h"
#import "NXAlertView.h"

#import "NXLoginUser.h"
#import "AppDelegate.h"
#import "NXFileBase.h"
#import "NXPhotoSelector.h"
#import "NXCommonUtils.h"
#import "NXSharePointFile.h"
#import "NXEmptyView.h"
#import "NXOfflineFileStorage.h"
#import "NXLProfile.h"
#import "NXAddToProjectVC.h"
#import "NXShareViewController.h"
#import "NXAddToProjectFileInfoVC.h"
#import "NXNXLFileSharingSelectVC.h"
#import "NXProjectFileManageShareVC.h"
#import "NXOriginalFilesTransfer.h"
#import "NXNetworkHelper.h"
#define kSectionHeaderHeight 25

@interface NXProjectFileTableViewController ()<NXOperationVCDelegate, UITableViewDelegate, UITableViewDataSource, DetailViewControllerDelegate>

@property(nonatomic, strong) NXProjectModel *project;
@property(nonatomic, strong) NXPhotoSelector *photoSelector;
@property(nonatomic, strong) NSMutableArray *originArray;
@property(nonatomic, strong) UILabel *navTitleLabel;
@property(nonatomic, strong) NSArray<NSDictionary<NSString *, NSArray*> *> *tableData;
@property(nonatomic, readonly, weak)UITableView *tableView;
@property(nonatomic, readonly, weak)UIRefreshControl *refreshControl;
@property(nonatomic, strong)NXEmptyView *emptyView;
@end

@implementation NXProjectFileTableViewController
- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel currentFolder:(NXProjectFolder *)projectFolder
{
    self = [super init];
    if (self) {
        _currentFolder = projectFolder;
        _project = projectModel;
        [self commonInit];
        [NXMBManager showLoadingToView:self.view];
    }
    return self;
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
- (NSMutableArray *)originArray {
    if (!_originArray) {
        _originArray = [NSMutableArray array];
    }
    return _originArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableview:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.currentFolder.isRoot) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navTitleLabel.text = self.currentFolder.name;
        
        self.navigationItem.titleView = self.navTitleLabel;
    }
    
    [self getNewDataAndreloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshTableview:(NSNotification *)notify
{
    [self getNewDataAndreloadData];
}

- (void)dealloc {
    DLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
- (UILabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _navTitleLabel.textColor = self.navigationController.navigationBar.tintColor;
        _navTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _navTitleLabel;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableData.count?:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableData.count>0) {
        NSDictionary *sec = self.tableData[section];
        NSArray<NXProjectFile *> *array = [sec objectForKey:[sec allKeys].firstObject];
        return array.count;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NXMyVaultHeaderView *headerView = [[NXMyVaultHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kSectionHeaderHeight)];
//    headerView.model = [self tableView:tableView titleForHeaderInSection:section];
//    return headerView;
    UIView *bgView = [[UIView alloc]init];
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSDictionary *sec = self.tableData[section];
//    return [sec allKeys].firstObject;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXProjectFileItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *fileModel = array[indexPath.row];
    cell.model = fileModel;
    cell.projectModel = self.project;
    
    WeakObj(self);
    cell.swipeButtonBlock = ^(SwipeButtonType type){
        StrongObj(self);
//        if (type == SwipeButtonTypeDelete) {
//            [self fileListResultVC:nil didSelectItem:fileModel];
//        } else
        if (type == SwipeButtonTypeActiveLog) {
            [self fileListResultVC:nil infoForItem:fileModel];
        }
    };
    
    cell.accessBlock = ^(id sender) {
        StrongObj(self);
//        [self fileListResultVC:nil propertyForItem:fileModel];
        [self fileListResultVC:nil accessForItem:fileModel];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sec = self.tableData[indexPath.section];
    NSArray<NXFileBase *> *array = [sec objectForKey:[sec allKeys].firstObject];
    NXFileBase *selectedFileItem = array[indexPath.row];
    
    if ([selectedFileItem isKindOfClass:[NXProjectFolder class]]) {
        NXProjectFileTableViewController *vc = [[NXProjectFileTableViewController alloc] initWithProjectModel:self.project currentFolder:(NXProjectFolder *)selectedFileItem];
        [self.navigationController pushViewController:vc animated:YES];
    
    }else if([selectedFileItem isKindOfClass:[NXProjectFile class]]){
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:selectedFileItem from:self withDelegate:self];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark

#pragma -mark NXSearchDataSourceProtocol

- (NSArray *)getSearchDataSource {
    return self.originArray;
}

#pragma -mark NXProjectFileListSearchResultDelegate

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC accessForItem:(NXFileBase *)item {
    if ([item isKindOfClass:[NXProjectFile class]]) {
        [NXMBManager showLoading];
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:item withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
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
                NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:self.project.displayName];
                WeakObj(self);
                    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:item];
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        StrongObj(self);
                        [self fileListResultVC:nil didSelectItem:item];
                    }];
                    
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                        [self fileListResultVC:nil propertyForItem:item];
                    }];
                    if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error && isValidity && (([rights DecryptRight] || [rights DownloadRight]) || ([[NXLoginUser sharedInstance] isProjectAdmin] && [rights ViewRight]))) {
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {

                            NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                            VC.currentFile = item;
                            VC.fromProjectModel = self.project;
                            VC.fileOperationType = NXFileOperationTypeAddProjectFileToProject;

                            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self presentViewController:nav animated:YES completion:nil];
                        }];
                    }else{
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                            
                        }];
                        
                    }
                    if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && isValidity && ([rights DownloadRight] || ([[NXLoginUser sharedInstance] isProjectAdmin] && [rights ViewRight]))) {
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
                    if (self.project.isOwnedByMe) {
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL)   type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                            StrongObj(self);
                            [self fileListResultVC:nil infoForItem:item];
                        }];
                    }
                    if (state == NXFileStateOfflineFailed) {
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                            StrongObj(self);
                            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                                dispatch_main_async_safe(^{
                                    if (!error) {
                                        item.isOffline = NO;
                                        [self.tableView reloadData];
                                        
                                    }else{
                                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                                        [self.tableView reloadData];
                                    }
                                });
                            }];
                        }];
                    } else if (state == NXFileStateOfflined || state == NXFileStateConvertingOffline) {
                        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_OFFLINE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                            StrongObj(self);
                            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                                dispatch_main_async_safe(^{
                                    if (!error) {
                                        item.isOffline = NO;
                                        [self.tableView reloadData];
                                    }else{
                                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                                        [self.tableView reloadData];
                                    }
                                });
                            }];
                        }];
                    }else if (state == NXFileStateNormal || item.isOffline == NO){
                        
                        NXAlertViewItemType type = NXAlertViewItemTypeDefault;
                        if (![NXCommonUtils isOfflineViewSupportFormat:item] || ![rights ViewRight]) {
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
                                        [self.tableView reloadData];
                                    }
                                    [self getNewDataAndreloadData];
                                });
                            }];
                        }];
                    }
                    
            //        if (!proejctFile.revoked) {
            //            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            //                NXProjectFileManageShareVC *vc = [[NXProjectFileManageShareVC alloc] init];
            //                vc.fileItem = item;
            //                vc.fromProjectModel = self.project;
            //                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
            //                [self.navigationController presentViewController:nav animated:YES completion:nil];
            //            }];
            //        }
                     //  only project admin can modify rights
                     if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
                         [alertView addItemWithTitle:NSLocalizedString(@"UI_RECLASSIFY",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                             NXAddToProjectFileInfoVC *vc = [[NXAddToProjectFileInfoVC alloc] init];
                             NXProjectFile *projectFileItem = (NXProjectFile *)item;
                             projectFileItem.projectId = self.project.projectId;
                             vc.currentFile = projectFileItem;
                             vc.toProject = self.project;
                             vc.fileOperationType = NXFileOperationTypeProjectFileReclassify;
                             NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                             [self.navigationController presentViewController:nav animated:YES completion:nil];
                         }];
                     }
                    
                
                if (self.project.isOwnedByMe) {
                    [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
                        StrongObj(self);
                        [self fileListResultVC:nil deleteItem:item];
                    }];
                }

                alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
                [alertView show];
                
                
            });
                
        }];
        
    }else{
        NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:nil];
        if (self.project.isOwnedByMe || [[NXLoginUser sharedInstance] isTenantAdmin]) {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
                [self fileListResultVC:nil deleteItem:item];
            }];
        }
        alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
        [alertView show];
    }
    
   
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC didSelectItem:(NXFileBase *)item {
    [resultVC.view removeFromSuperview];
    
    NXFileBase *selectedFileItem = item;
    if ([selectedFileItem isKindOfClass:[NXProjectFolder class]]) {
        NXProjectFileTableViewController *vc = [[NXProjectFileTableViewController alloc] initWithProjectModel:self.project currentFolder:(NXProjectFolder *)selectedFileItem];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([selectedFileItem isKindOfClass:[NXProjectFile class]]){
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:selectedFileItem from:self withDelegate:self];
    }
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC deleteItem:(NXFileBase *)item
{
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), item.name];
    WeakObj(self);
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) { // user deside to delete this file
            StrongObj(self);
            [NXMBManager showLoadingToView:self.view];
            [[NXLoginUser sharedInstance].myProject removeFileItem:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DELETE_FILE_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                    }else{
                        [self getNewDataAndreloadData];
                    }
                });
            }];
        }
    }];
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC infoForItem:(NXFileBase *)item
{
    NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
    logActivityVC.fileItem = item;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC propertyForItem:(NXFileBase *)item
{
    NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
    property.fileItem = item;
//    property.isFromProjectFile = YES;
    NSString *currentUserId = [NXLoginUser sharedInstance].profile.userId;
    NXProjectFile *file = (NXProjectFile *)item;
    NSNumber *currentFileUserId = file.projectFileOwner.userId;
    if ([[currentFileUserId stringValue] isEqualToString:currentUserId]) {
        property.isSteward = YES;
    }else {
        property.isSteward = NO;
    }
    property.delegate = self;
    
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark right add button
- (void)createFolderOrUploadFileWith:(id)sender {
    NXProjectFolder *curFolder = nil;
    if ([self.navigationController.viewControllers.lastObject isKindOfClass:[NXProjectFileTableViewController class]]) {
        NXProjectFileTableViewController *curVC = (NXProjectFileTableViewController *)self.navigationController.viewControllers.lastObject;
        curFolder = curVC.currentFolder;
    } else{
        [NXMBManager showMessage:NSLocalizedString(@"MSG_UPLOAD_NO_REPO", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    WeakObj(self);
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_SELECT_TYPE", NULL) style:UIAlertControllerStyleActionSheet cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_COM_PHOTOS", NULL), NSLocalizedString(@"Camera", NULL), NSLocalizedString(@"UI_COM_CREATE_NEW_FOLDER", NULL)] inViewController:self position:sender tapBlock:^(UIAlertAction *action, NSInteger index) {
        StrongObj(self);
        switch (index) {
            case 0: //cancel
            {
                DLog();
            }
                break;
            case 1: //Photos
            {
                NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
                self.photoSelector = selecter;
                WeakObj(self);
                [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
                    if (selectedItems.count != 0) {
                        DLog(@"Photo selected");
                        StrongObj(self);
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [self uploadLocalFile:selectedItems parentFolder:curFolder];
                        });
                    }
                }];
            }
                break;
            case 2: //Camera
            {
                NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
                self.photoSelector = selecter;
                
                [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
                    if (selectedItems.count != 0) {
                        StrongObj(self);
                        DLog(@"camera selected");
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [self uploadLocalFile:selectedItems parentFolder:curFolder];
                        });
                    }
                }];
            }
                break;

            case 3: //new folder
            {
                NXProjectNewFolderVC *newFolderVC =[[NXProjectNewFolderVC alloc]init];
                newFolderVC.parentFolder=curFolder;
                NXProjectsNavigationController *projectNav = [[NXProjectsNavigationController alloc]initWithRootViewController:newFolderVC];
                projectNav.projectModel = self.project;
                [self presentViewController:projectNav animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }];
  
}
#pragma mark - uploadLocalFile
- (void)uploadLocalFile:(NSArray *)localFiles parentFolder:(NXFileBase *)parentFolder {
    //TODO
    if (!localFiles.count) {
        return;
    }
    NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localFiles.lastObject]];
    NXFile *file = [[NXFile alloc] init];
    file.size = fileData.length;
    file.localPath = localFiles.lastObject;
    file.name = file.localPath.lastPathComponent;
    file.sorceType = NXFileBaseSorceTypeLocal;
    
    NXProjectUploadVC *vc = [[NXProjectUploadVC alloc] init];
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    
    vc.delegate = self;
    vc.fileItem = file;
    vc.folder = (NXProjectFolder *)parentFolder;
    vc.project = self.project;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)pullDownRefreshWork {
    WeakObj(self);
    self.navigationItem.title = self.currentFolder.name;
    [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolder:self.currentFolder withCompletion:^(NXProjectModel *project,NXProjectFolder *parentFolder, NSArray *fileList, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            if (!error) {
                StrongObj(self);
                [self.originArray removeAllObjects];
                self.originArray = [NSMutableArray arrayWithArray:fileList];
                [self reloadData];
            }
        });
    }];
}

#pragma mark - get new data and reloadData
- (void)getNewDataAndreloadData {
    WeakObj(self);
    self.project = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.project.projectId];
    if (self.project == nil) {
        return;
    }
    [NXLoginUser sharedInstance].myProject.upDateFiledelegate = self;
    [[NXLoginUser sharedInstance].myProject getFileListFromServerUnderParentFolder:self.currentFolder withCompletion:^(NXProjectModel *project,NXProjectFolder *parentFolder, NSArray *fileList, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.view];
            if (!error) {
                StrongObj(self);
                [self.originArray removeAllObjects];
                self.originArray = [NSMutableArray arrayWithArray:fileList];
                if (self.originArray.count == 0) {
                    self.emptyView.hidden = NO;
                    self.tableView.hidden = YES;
                }else {
                    self.emptyView.hidden = YES;
                    self.tableView.hidden = NO;
                    [self reloadData];
                }
            }else {
                if (self.refreshControl.isRefreshing) {
                    [self.refreshControl endRefreshing];
                }
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }
        });
    }];
}
- (void)setSortOption:(NXSortOption)sortOption {
    _sortOption = sortOption;
    [self reloadData];
}

- (void)reloadData {
    self.tableData = [NXFileSort keySortObjects:self.originArray option:_sortOption];
    [self.tableView reloadData];
}

#pragma mark - NXOperationVCDelegate
-(void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile{
//    [self getNewDataAndreloadData];
}

#pragma mark
- (void)commonInit {
   
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc]init];
    _tableView = tableView;
    [self.view addSubview:self.tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.sectionHeaderHeight = kSectionHeaderHeight;
    self.tableView.estimatedRowHeight = 70;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[NXProjectFileItemCell class] forCellReuseIdentifier:@"cell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullDownRefreshWork) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor lightGrayColor];
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _refreshControl = refreshControl;
    [self.tableView addSubview:refreshControl];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kMargin * 4, 0);

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.left.and.right.equalTo(self.view);
    }];
}
//- (void)setSortOption:(NXSortOption)sortOption {
//    self.tableData = [NXFileSort keySortObjects:self.originArray option:sortOption];
//    
//    [self.tableView reloadData];
//}

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
//#pragma mark ------> NXMyProjectManager update file delegate
//- (void)nxMyProjectManager:(NXMyProjectManager *)manager didGetProjectFiles:(NSArray *)files underFolder:(NXProjectFolder *)folder withSpaceDict:(NSDictionary *)dict withError:(NSError *)error{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([folder.localPath isEqualToString:self.currentFolder.fullServicePath]) {
//            [NXMBManager hideHUDForView:self.view];
//            if (!error) {
//                self.originArray = [NSMutableArray arrayWithArray:files];
//                if (self.originArray.count == 0) {
//                    self.emptyView.hidden = NO;
//                    self.tableView.hidden = YES;
//                }else {
//                    self.emptyView.hidden = YES;
//                    self.tableView.hidden = NO;
//                    [self reloadData];
//                }
//            }else {
//                if (self.refreshControl.isRefreshing) {
//                    [self.refreshControl endRefreshing];
//                }
//                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
//            }
//        }
//    });
//}
@end

