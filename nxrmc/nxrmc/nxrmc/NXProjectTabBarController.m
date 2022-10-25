//
//  NXProjectTabBarController.m
//  Demo
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 Bill (Guobin) Zhang. All rights reserved.
//

#import "NXProjectTabBarController.h"

#import "NXProjectsNavigationController.h"
#import "NXProjectHomeVC.h"
#import "NXProjectSummaryVC.h"
#import "NXProjectFilesVC.h"
#import "NXPeopleViewController.h"

#import "NXPresentNavigationController.h"
#import "NXNewFolderViewController.h"
#import "NXProjectUploadVC.h"
#import "Masonry.h"

#import "NXContextMenu.h"
#import "NXProjectInviteMemberView.h"
#import "UIImage+ColorToImage.h"
#import "NXPhotoSelector.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
#import "NXLoginUser.h"
#import "NXCommentInputView.h"
#import "NXFileChooseFlowViewController.h"
#import "NXWebFileManager.h"
#import "AppDelegate.h"
#import "NXAllProjectsViewController.h"
#import "NXMasterTabBarViewController.h"
#import "NXWorkSpaceTabBarViewController.h"
#import "NXContactInfoTool.h"
#import "NXLocalContactsVC.h"
#import "NXOriginalFilesTransfer.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXAddToProjectLastVC.h"
@interface AddViewController : UIViewController
@end

@implementation AddViewController
@end

@interface NXProjectTabBarController ()<UITabBarControllerDelegate,NXFileChooseFlowViewControllerDelegate,NXLocalContactsVCDelegate>

@property(nonatomic, strong) NXPhotoSelector *photoSelector;

//for NXFileChooseFlowVC, i have to remember why choose file/folder. so use this flag
@property(nonatomic, strong) NSDictionary *chooseType; //1:NXRepositoryModel means protect form repo, 2:NXRepositoryModel means share from repo. 3:NXRepositoryModel createNewFolder.

@property(nonatomic, strong) NXContextMenu *contextMenu;
@property (nonatomic, strong)NXProjectSummaryVC *summaryVC;
@property (nonatomic, strong) NXProjectFolder *currentFolder;
@property (nonatomic, weak) NXProjectInviteMemberView *memberView;
@property (nonatomic, strong) UIButton *projectGlobalButton;
@end

@implementation NXProjectTabBarController

- (instancetype)initWithProject:(NXProjectModel *)projectModel {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectKicked:) name:NOTIFICATION_PROJECT_YOU_ARE_KICKED_OUTSIDE object:nil];
        _projectModel = projectModel;
        NXProjectHomeVC *vc = [[NXProjectHomeVC alloc] init];
        
        NXProjectFilesVC *filesVC = [[NXProjectFilesVC alloc] init];
        filesVC.projectModel = self.projectModel;
        NXProjectsNavigationController *filesNav = [[NXProjectsNavigationController alloc] initWithRootViewController:filesVC];
        filesNav.projectModel = projectModel;
        
        NXProjectSummaryVC *summaryVC = [[NXProjectSummaryVC alloc] init];
        summaryVC.projectModel = self.projectModel;
        summaryVC.configurationModel = self.projectModel;
        self.summaryVC = summaryVC;
        NXProjectsNavigationController *summaryNav = [[NXProjectsNavigationController alloc] initWithRootViewController:summaryVC];
        summaryNav.projectModel = projectModel;
        
        NXPeopleViewController *peopleVC = [[NXPeopleViewController alloc] initWithStyle:UITableViewStyleGrouped];
        peopleVC.projectModel = self.projectModel;
        NXProjectsNavigationController *peopleNav = [[NXProjectsNavigationController alloc] initWithRootViewController:peopleVC];
        peopleNav.projectModel = projectModel;
        
//        AddViewController *addVC = [[AddViewController alloc] init];
        
        
        [self setViewControllers:@[vc, summaryNav, filesNav, peopleNav]];
        
        UITabBar *tabBar = self.tabBar;
        NSDictionary *selDic = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName:RMC_MAIN_COLOR};
        NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                              NSForegroundColorAttributeName:[UIColor blackColor]};
        UITabBarItem *item = [UITabBarItem appearance];
        [item setTitleTextAttributes:selDic forState:UIControlStateSelected];
        [item setTitleTextAttributes:dic forState:UIControlStateNormal];
        
        UITabBarItem *itemHome = [tabBar.items objectAtIndex:0];
        itemHome.title = NSLocalizedString(@"UI_PROJTEC_TAB_BAR_HOME_TITLE", NULL);
        itemHome.image = [[UIImage imageNamed:@"Home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        itemHome.selectedImage = [UIImage imageNamed:@"Home Selected"];
        
        UITabBarItem *itemSummary = [tabBar.items objectAtIndex:1];
        itemSummary.title = NSLocalizedString(@"UI_PROJTEC_TAB_BAR_Summary_TITLE", NULL);
        itemSummary.image = [[UIImage imageNamed:@"Summary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        itemSummary.selectedImage = [UIImage imageNamed:@"Summary Selected"];
        
        UITabBarItem *itemFiles = [tabBar.items objectAtIndex:2];
        itemFiles.title = NSLocalizedString(@"UI_PROJTEC_TAB_BAR_Files_TITLE", NULL);
        itemFiles.image = [[UIImage imageNamed:@"Files"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        itemFiles.selectedImage = [UIImage imageNamed:@"Files Selected"];
        
        UITabBarItem *itemPeople = [tabBar.items objectAtIndex:3];
        itemPeople.title = NSLocalizedString(@"UI_PROJTEC_TAB_BAR_People_TITLE", NULL);
        itemPeople.image = [[UIImage imageNamed:@"Members"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        itemPeople.selectedImage = [UIImage imageNamed:@"Members selected"];
        
//        UITabBarItem *itemMore = [tabBar.items objectAtIndex:4];
//        itemMore.image = [[UIImage imageNamed:@"Add Utility"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        if ([NXCommonUtils isiPad]) {
//            [itemMore setImageInsets:UIEdgeInsetsMake(6, -8, -3, 8)];
//        }else{
//            [itemMore setImageInsets:UIEdgeInsetsMake(6, -8, -6, 8)];
//        }
//        itemMore.accessibilityValue = @"PROJECT_ADD_MORE_TAB";
        
        self.tabBar.backgroundImage = [[UIImage alloc] init];
        self.tabBar.backgroundColor = [UIColor whiteColor];
        
        self.tabBar.shadowImage = [[UIImage alloc] init];
        self.tabBar.layer.shadowOffset = CGSizeMake(0, 5);
        self.tabBar.layer.shadowOpacity = 0.9;
        self.tabBar.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.tabBar.layer.shadowRadius = 10;
    }
    return self;
}

- (void)projectKicked:(NSNotification *)notification{
    NSArray *projectIds = notification.userInfo[@"projectId"];
    for (NSNumber *pjtID in projectIds) {
        if (pjtID.integerValue == self.projectModel.projectId.integerValue) {
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_PROJECT_KICKED_OUT", nil) style:UIAlertControllerStyleAlert OKActionTitle:@"OK" cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                [self.preTabBarController setSelectedIndex:kNXMasterTabBarControllerIndexHome];
                [self dismiss];
            } cancelActionHandle:nil inViewController:[UIApplication sharedApplication].keyWindow.rootViewController position:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.delegate = self;
    [self commmonInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenGlobalAddButton:) name:NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGlobalAddButton:) name:NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
     NSTimeInterval lastActionTime = [[NSDate date] timeIntervalSince1970];
    self.projectModel.lastActionTime = lastActionTime;

    if (!self.projectModel.membershipId) {
        [[NXLoginUser sharedInstance].myProject getMemberShipID:self.projectModel withCompletion:^(NXProjectModel *projectModel, NSError *error) {
            if (!error) {
                self.projectModel.membershipId = projectModel.membershipId;
            }
        }];
    }
    
    [[NXLoginUser sharedInstance].myProject activeProject:self.projectModel atLocalTime:lastActionTime * 1000];
    [[NXLoginUser sharedInstance].myProject project:self.projectModel MetadataWithCompletion:^(NXProjectModel *projectModel, NSError *error) {
        if (!error) {
            self.projectModel.invitationMsg = projectModel.invitationMsg;
            self.summaryVC.configurationModel = self.projectModel;
        }
    }];

//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NXLoginUser sharedInstance].myProject inactiveProject:self.projectModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"%s", __FUNCTION__);
}

#pragma mark - private method

-(void)hiddenGlobalAddButton:(id)sender{
    [self.projectGlobalButton setHidden:YES];
}

-(void)showGlobalAddButton:(id)sender{
    [self.projectGlobalButton setHidden:NO];
}


#pragma mark
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if ([[self.viewControllers objectAtIndex:selectedIndex] isKindOfClass:[AddViewController class]]) {
        NSLog(@"%s", __FUNCTION__);
        return;
    }
    [super setSelectedIndex:selectedIndex];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    if ([selectedViewController isKindOfClass:[AddViewController class]]) {
        NSLog(@"%s", __FUNCTION__);
        return;
    }
    
    if ([selectedViewController isKindOfClass:[NXProjectHomeVC class]]) {
        [self dismiss];
        return;
    }
    [super setSelectedViewController:selectedViewController];
}

- (void)setProjectModel:(NXProjectModel *)projectModel {
    if (projectModel == _projectModel) {
        return;
    }
    _projectModel = projectModel;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_CURRENTPROJECT_UPDATED object:projectModel];
}

#pragma mark
- (void)dismiss {
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark
- (void)addButtonClicked:(id)sender {
    NXProjectFolder *folder = [NXMyProjectManager rootFolderForProject:self.projectModel];
    if (self.selectedIndex == 2) {
        NXProjectsNavigationController *filesNav = (NXProjectsNavigationController*)[self selectedViewController];;
        NXProjectFilesVC *filesVC = filesNav.viewControllers.firstObject;
        folder = filesVC.projectFileListNav.currentFolder;
    }
    
    NXContextMenuType type = NXContextMenuTypeProjectHome;
    switch (self.selectedIndex) {
        case 1:
        {
            type = NXContextMenuTypeProjectHome;
        }
            break;
        case 2:
        {
            type = NXContextMenuTypeProjectSummary;
        }
            break;
        case 3:
        {
            type = NXContextMenuTypeProjectPeople;
        }
            break;
        default:
            break;
    }
    self.currentFolder = folder;
    WeakObj(self);
    _contextMenu = [NXContextMenu showType:type andCurrentModel:self.projectModel withHandler:^(NXContextMenuHandler *handler) {
        StrongObj(self);
        [self test:folder handler:handler];
    }];
    return;
}

- (void)test:(NXProjectFolder *)currentFolder handler:(NXContextMenuHandler *)handle {
    switch (handle.action) {
        case NXContextMenuActionAddFileToProjectFromLocal:
        {
            [self addFile:currentFolder];
        }
            break;
        case NXContextMenuActionAddFileToProjectFromFilesApp:
        {
            self.currentFolder = currentFolder;
            [self addFileFromFilesApp];
        }
            break;
        case NXContextMenuActionSelectFileFromMyDriveForProtecting:
        {
            [self protectFromRepo:[[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository]];
        }
            break;
        case NXContextMenuActionAddFileFromRepo:
        {
            self.currentFolder = currentFolder;
            [self addFileFromRepo:handle.data];
        }
            break;
        case NXContextMenuActionInviteMember:
        {
            [self inviteMembers];
        }
            break;
        case NXContextMenuActionCreateFolder:
        {
            [self createNewFolder:currentFolder];
        }
            break;
        case NXContextMenuActionScanDocumentToProject:
        {
            [self scanDocument:currentFolder];
        }
            break;
        case NXContextMenuActionProtect:
        {
            self.currentFolder = currentFolder;
            if ([handle.data isKindOfClass:[NXRepositoryModel class]]) {
                [self protectFromRepo:handle.data];
            } else if([handle.data isEqualToString:@"Files"]) {
                [self protectFromFiles];
            }else{
                [self protectLocal];
            }
        }
            break;
        case NXContextMenuActionActionScanDocumentForProtecting:
            
        {
            self.currentFolder = currentFolder;
            [self scanDocumentForProtecting];
        }
            break;
        case NXContextMenuActionGoToAllProject:
            [self goToAllProject];
            break;
        case NXContextMenuActionAddNXLFileFromRepo:
            [self selectNXLFileFromRepo:handle.data];
            break;
        case NXContextMenuActionAddNXLFileFromWorkSpace:
        {
            [self selectNXlFileFromWorkspace];
        }
            break;
        case NXContextMenuActionAddNXLFileFromMySpace:
        {
            [self selectNXLFileFromMyVault];
        }
            break;
        case NXContextMenuActionAddNXLFileFromProject:
        {
            [self selectNXLFileFromProject:handle.data];
        }
            break;
        case NXContextMenuActionAddNXLFileToProjectOrWorkSpaceFromFiles:
            [self importNXlFileFromFiles];
            break;
        default:
            break;
    }
}

-(UIButton *)projectGlobalButton
{
    if (!_projectGlobalButton) {
        _projectGlobalButton = [[UIButton alloc] init];
        [_projectGlobalButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_projectGlobalButton setImage:[UIImage imageNamed:@"Add Utility"] forState:UIControlStateNormal];
        [_projectGlobalButton setImage:[UIImage imageNamed:@"Add Utility"] forState:UIControlStateHighlighted];
    }
    return _projectGlobalButton;
}

- (void)commmonInit{
    [self.view addSubview:self.projectGlobalButton];
    CGFloat tabBarHeight = self.tabBar.frame.size.height;
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        //获取安全区域底部高度
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        bottomPadding = window.safeAreaInsets.bottom;
    }
        [self.projectGlobalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@52);
        make.bottom.equalTo(self.view).offset(-(tabBarHeight+20+bottomPadding));
        make.right.equalTo(self.view).offset(-20);
    }];
}


#pragma mark - private method
- (void)protectFromRepo:(NXRepositoryModel *)repositoryModel {
    self.chooseType = @{@(1):repositoryModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:repositoryModel type:NXFileChooseFlowViewControllerTypeNormalFile isSupportMultipleSelect:YES];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showWaitingView];
    });
}
- (void)selectNXlFileFromWorkspace{
    self.chooseType = @{@(NXContextMenuActionAddNXLFileFromWorkSpace):@"Workspace"};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeNxlFile];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    
}
- (void)selectNXLFileFromMyVault {
    self.chooseType = @{@(NXContextMenuActionAddNXLFileFromMySpace):@""};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithMyVaultType:NXFileChooseFlowViewControllerTypeNxlFile];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    
}
- (void)selectNXLFileFromRepo:(NXRepositoryModel *)currentModel {
    self.chooseType = @{@(NXContextMenuActionAddNXLFileFromRepo):currentModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:currentModel type:NXFileChooseFlowViewControllerTypeNxlFile isSupportMultipleSelect:NO];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    
}
- (void)selectNXLFileFromProject:(NXProjectModel *)currentModel {
    self.chooseType = @{@(NXContextMenuActionAddNXLFileFromProject):currentModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithProject:currentModel type:NXFileChooseFlowViewControllerTypeNxlFile];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    
}
- (void)importNXlFileFromFiles{
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    [transfer importProtectNXLFilesDocumentFromVC:self.navigationController];
    transfer.improtFileCompletion = ^(UIViewController *currentVC,NXFile *fileItem, NSData *fileData, NSError *error) {
        [self showAddNXLFileToDefaultPathWithFile:fileItem];
           
    };
}
- (void)protectFromFiles {
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    [transfer importOriginalFilesDocumentFromVC:self.navigationController];
    transfer.improtMultipleFileCompletion = ^(UIViewController *currentVC, NSArray *fileArray, NSError *error) {

        [self showProtectSelectLocationWithFileFromLocal:fileArray];
    };
   
}
- (void)protectLocal {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeMultiSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSMutableArray *fileItems = [NSMutableArray array];
                for (NSString *localPath in selectedItems) {
                    NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                    NXFile *file = [[NXFile alloc] init];
                    file.size = fileData.length;
                    file.localPath = localPath;
                    file.name = localPath.lastPathComponent;
                    file.isRoot = NO;
                    file.sorceType = NXFileBaseSorceTypeLocal;
                    [fileItems addObject:file];
                }
                [self showProtectSelectLocationWithFileFromLocal:fileItems];
            });
        }
    }];
}
- (void)scanDocumentForProtecting {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSMutableArray *fileArray = [NSMutableArray array];
                for (NSString *localPath in selectedItems) {
                    NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                    NXFile *file = [[NXFile alloc] init];
                    file.size = fileData.length;
                    file.localPath = localPath;
                    file.name = localPath.lastPathComponent;
                    file.isRoot = NO;
                    file.sorceType = NXFileBaseSorceTypeLocal;
                    [fileArray addObject:file];
                    
                }
                
                [self showProtectSelectLocationWithFileFromLocal:fileArray];
            });
        }
    }];
}

- (void)showAddNXLFileToDefaultPathWithFile:(NXFileBase *)fileItem{
    NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
    VC.isFromDefaultPath = YES;
    VC.fileOperationType = NXFileOperationTypeAddNXLFileToProject;
    VC.currentFile = fileItem;
    VC.folder = self.currentFolder;
    VC.toProject = self.projectModel;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}
- (void)showProtectSelectLocationWithFileFromLocal:(NSArray *)fileItemArray {
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.filesArray = fileItemArray;
    VC.locationType = NXProtectSaveLoactionTypeProject;
    VC.targetProject = self.projectModel;
    VC.saveFolder = self.currentFolder;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
//    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
//    VC.fileItem = fileItem;
//    VC.locationType = NXProtectSaveLoactionTypeLocalFiles;
//    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];

}
- (void)addFile:(NXProjectFolder *)folder {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongObj(self);
                NSString *localPath = selectedItems.lastObject;
                [self showLocalUpload:localPath folder:folder];
            });
        }
    }];
}
- (void)addFileFromFilesApp{
    
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    
    [transfer importOriginalFilesDocumentFromVC:self.navigationController];
    transfer.improtMultipleFileCompletion = ^(UIViewController *currentVC, NSArray *fileArray, NSError *error) {
        [self showPrtectSelectLocationFilesFromRepo:fileArray withCurrentFolder:self.currentFolder];
       
    };
//    [transfer importOriginalFilesDocumentFromVC:self.navigationController];
//    transfer.improtFileCompletion = ^(UIViewController *currentVC,NXFile *fileItem, NSData *fileData, NSError *error) {
//        NXProjectUploadVC *vc = [[NXProjectUploadVC alloc] init];
//        vc.fileItem = fileItem;
//        vc.folder = self.currentFolder;
//        vc.project = self.projectModel;
//        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
//    };
}
// Add File From Repo
- (void)addFileFromRepo:(NXRepositoryModel *)repositoryModel
{
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:repositoryModel type:NXFileChooseFlowViewControllerTypeNormalFile isSupportMultipleSelect:NO];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
}

- (void)inviteMembers {
    WeakObj(self);
    NXProjectInviteMemberView *memberView = [[NXProjectInviteMemberView alloc] initWithTitle:self.projectModel.invitationMsg inviteHander:^(NXProjectInviteMemberView *alertView) {
        StrongObj(self);
        if (alertView.emailView.vaildEmails.count == 0) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_NO_VAILD_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
            return;
        }
        
        if ([alertView.emailView isExistInvalidEmail]) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_HAVE_INVALID_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
            return;
        }
        
        [NXMBManager showLoadingToView:self.view];
        
        NSString *invitationMsg = [alertView.invitationView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (invitationMsg.length == 0) {
            invitationMsg = nil;
        }
        
        NSArray *emailsArray = [[NSArray alloc] initWithArray:alertView.emailView.vaildEmails];
        [[NXLoginUser sharedInstance].myProject  inviteMember:emailsArray invitationMsg:invitationMsg inProject:self.projectModel withCompletion:^(NXProjectModel *project, NSDictionary *resultDic, NSError *error) {
            
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
              NSString *resultMessage = [self invitedMessageWith:resultDic];
                    if (resultMessage == nil) {
                       [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_INVITE_SUCCEED", NULL) hideAnimated:YES afterDelay:kDelay];
                    }else {
                         [NXCommonUtils showAlertViewInViewController:self title:NSLocalizedString(@"MSG_COM_INVITE_SUCCEED", nil) message:resultMessage];
                        
                    }
                });
                
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_INVITE_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                });
            }
        }];
        
        [alertView dismiss];
    }];
    self.memberView = memberView;
    memberView.emailView.rightBtnClicked = ^{
        NXLocalContactsVC *contactVC = [[NXLocalContactsVC alloc]init];
        contactVC.delegate = self;
        switch ([NXContactInfoTool checkAuthorizationStatus]) {
            case NXContactAuthStatusAlreadyDenied:{
                [self performSelector:@selector(tempDismiss) withObject:self afterDelay:0.5];
                NSString *appName = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_SETTING_ACCESS_ADDRESS_BOOK", NULL),appName];
                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                        }
                    });
                    
                } cancelActionHandle:nil inViewController:self position:self.view];
            }
                break;
            case NXContactAuthStatusAlreadyAuthorized:{
                [self.memberView tempDismiss];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:contactVC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }
                break;
            case NXContactAuthStatusNotDetermined:
                [NXContactInfoTool requestAccessEntityWithCompletion:^(BOOL granted, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            [self performSelector:@selector(tempDismiss) withObject:self afterDelay:0.5];
                            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:contactVC];
                             nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self.navigationController presentViewController:nav animated:YES completion:nil];
                        }else{
                            
                        }
                    });
                }];
                break;
        }
    };
    [memberView show];
}
- (void)tempDismiss{
    [self.memberView tempDismiss];
}
- (void)createNewFolder:(NXProjectFolder *)folder {
    NXNewFolderViewController *newFolderVC = [[NXNewFolderViewController alloc] init];
    newFolderVC.parentFolder = folder;
    newFolderVC.createFolderFinishedBlock = ^(NXFileBase *newFolder, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
            } else {
                NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"MSG_COM_CREATE_FOLDER_SUCCESS", NULL), newFolder.name];
                [NXMBManager showMessage:message hideAnimated:YES afterDelay:kDelay];
            }
        });
        
        //TODO update new UI.
    };
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:newFolderVC];
    [self presentViewController:nav animated:YES completion:nil];
}

//scan a document action
- (void)scanDocument:(NXProjectFolder *)folder {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongObj(self);
                NSString *localPath = selectedItems.lastObject;
                [self showLocalUpload:localPath folder:folder];
            });
        }
    }];
}

- (void)showLocalUpload:(NSString *)localPath folder:(NXProjectFolder *)folder {
    NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
    NXFile *file = [[NXFile alloc] init];
    file.size = fileData.length;
    file.localPath = localPath;
    file.name = localPath.lastPathComponent;
    file.isRoot = NO;
    file.sorceType = NXFileBaseSorceTypeLocal;
    
    NXProjectUploadVC *vc = [[NXProjectUploadVC alloc] init];
    vc.fileItem = file;
    vc.folder = folder;
    vc.project = self.projectModel;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
- (void)goToAllProject {
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:[NXMasterTabBarViewController class]]) {
        NXMasterTabBarViewController *tabVC = self.navigationController.viewControllers.firstObject;
        [tabVC setSelectedIndex:kNXMasterTabBarControllerIndexAllProjects];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        NXMasterTabBarViewController *tabVC = [[NXMasterTabBarViewController alloc] init];
        [tabVC setSelectedIndex:kNXMasterTabBarControllerIndexAllProjects];
        [self.navigationController pushViewController:tabVC animated:YES];
    }
}
- (void)showPrtectSelectLocationFilesFromRepo:(NSArray *)fileItemArray withCurrentFolder:(NXProjectFolder *)currentFolder{
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.filesArray = fileItemArray;
    VC.locationType = NXProtectSaveLoactionTypeProject;
    VC.targetProject = self.projectModel;
    VC.saveFolder = currentFolder;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
//     NXRepositoryModel *repoModel =  [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:fileItem.repoId];
//    if (repoModel.service_type.integerValue == kServiceSkyDrmBox) {
//        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
//        VC.fileItem = fileItem;
//        VC.locationType = NXProtectSaveLoactionTypeMyVault;
//        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
//    }else{
//        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
//        VC.fileItem = fileItem;
//        VC.locationType = NXProtectSaveLoactionTypeFileRepo;
//        if (repoModel.service_type.intValue == kServiceOneDriveApplication) {
//            VC.locationType = NXProjectSaveLocationTypeSharedWorkSpace;
//        }
//        VC.saveFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:fileItem];
//        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
//
//    }
}
#pragma mark
- (MBProgressHUD *)showWaitingView {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.primaryNavigationController.view animated:YES];
    hud.contentColor = RMC_MAIN_COLOR;
    hud.bezelView.backgroundColor = [UIColor lightGrayColor];
    hud.animationType = MBProgressHUDAnimationFade;
    hud.userInteractionEnabled = YES;
    hud.graceTime = 0.2;
    hud.margin = 20;
    hud.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.8];
    hud.tag = 66666;
    
//    hud.label.text = NSLocalizedString(@"    Exporting...   ", NULL);
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud removeFromSuperViewOnHide];
    return hud;
}

- (void)hiddenWaitingView:(MBProgressHUD *)hud {
    [hud hideAnimated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [MBProgressHUD hideHUDForView:appDelegate.primaryNavigationController.view animated:YES];
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    if ([viewController isKindOfClass:[AddViewController class]]) {
//        [self addButtonClicked:nil];
//        return NO;
//    }
    if ([viewController isKindOfClass:[NXProjectHomeVC class]]) {
        UITabBarController *rootVC = tabBarController.navigationController.viewControllers.firstObject;
        [tabBarController.navigationController popToRootViewControllerAnimated:YES];
        [rootVC setSelectedIndex:kNXMasterTabBarControllerIndexHome];
        return NO;
    }
    
    return YES;
}
#pragma mark  ------> return invited result message
- (NSString *)invitedMessageWith:(NSDictionary *)dic {
    NSArray *alreadyInviteds = dic[@"alreadyInvited"];
    NSArray *alreadyMembers = dic[@"alreadyMembers"];
    if (alreadyMembers.count == 0 && alreadyInviteds.count == 0) {
        return nil;
    }else {
        NSString *alreadyInvitedStr = @"";
        if (alreadyInviteds.count>0) {
            NSString *invitedNameStr = [alreadyInviteds componentsJoinedByString:@","];
            NSString *invitedTitle = NSLocalizedString(@"MSG_COM_ALREADY_INVITED", NULL);
            alreadyInvitedStr = [NSString stringWithFormat:@"%@%@",invitedTitle,invitedNameStr];
        }
        NSString *alreadyMembersStr = @"";
        if (alreadyMembers.count>0) {
            NSString *membersNameStr = [alreadyMembers componentsJoinedByString:@","];
            NSString *memberTitle = NSLocalizedString(@"MSG_COM_ALREADY_MEMEBERS", NUll);
            alreadyMembersStr = [NSString stringWithFormat:@"%@%@",memberTitle,membersNameStr];
        }
        NSString *message = [NSString stringWithFormat:@"%@ %@",alreadyMembersStr,alreadyInvitedStr];
        return message;
    }
}

#pragma mark -NXFileChooseFlowViewControllerDelegate

- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles
{
    if (!self.chooseType.count || !choosedFiles.count) {
        [self hiddenWaitingView:nil];
        return;
    }
    WeakObj(self);
    if (choosedFiles) {
        NSInteger type = ((NSNumber *)(self.chooseType.allKeys.lastObject)).integerValue;
        //protect from repo
        if (type == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongObj(self);
                [self showPrtectSelectLocationFilesFromRepo:choosedFiles withCurrentFolder:self.currentFolder];
               
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hiddenWaitingView:nil];
                });
            });
            return;
        }else if(type == NXContextMenuActionAddNXLFileFromRepo || type == NXContextMenuActionAddNXLFileFromWorkSpace || type == NXContextMenuActionAddNXLFileFromMySpace || type == NXContextMenuActionAddNXLFileFromProject){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongObj(self);
                [self showAddNXLFileToDefaultPathWithFile:choosedFiles.firstObject];
               
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hiddenWaitingView:nil];
                });
            });
            return;
           
        }
       

    }
}

- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc
{
    [self hiddenWaitingView:nil];
}
#pragma mark ----> lcoalContactVC delegate
- (void)selectedEmail:(NSString *)emailStr {
    [self.memberView tempShow];
    [self.memberView.emailView addAEmail:emailStr];
}
- (void)cancelSelctedEmail {
    [self.memberView tempShow];
}
@end
