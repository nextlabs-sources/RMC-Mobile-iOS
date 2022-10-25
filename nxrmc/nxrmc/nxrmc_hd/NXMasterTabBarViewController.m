//
//  NXMasterTableBarViewController.m
//  nxrmc
//
//  Created by EShi on 7/27/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "NXMasterTabBarViewController.h"

#import "NXHomeNavigationVC.h"
#import "NXMySpaceHomeVC.h"
#import "NXFilesNavigationVC.h"
#import "NXFilesViewController.h"
#import "NXMyDriveViewController.h"
#import "NXMyVaultNavigationController.h"
#import "NXMyVaultViewController.h"

#import "NXNewFolderViewController.h"
#import "NXFileChooseFlowViewController.h"
#import "NXRepoSpaceUploadVC.h"
#import "NXLocalProtectVC.h"
#import "NXLocalShareVC.h"
#import "NXAddRepositoryViewController.h"
#import "NXRepositoryViewController.h"
#import "NXPresentNavigationController.h"
#import "NXNewProjectVC.h"

#import "NXPhotoSelector.h"
#import "NXMBManager.h"
#import "UIImage+ColorToImage.h"
#import "NXContextMenu.h"
#import "Masonry.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "AppDelegate.h"
#import "NXNewMySpaceNavigationVC.h"
#import "NXAllProjectsViewController.h"
#import "NXAddToPojectFromTabBarPageVC.h"
#import "NXOriginalFilesTransfer.h"
#import "NXProtectAndSaveFileFromFilesVC.h"
#import "NXMySpaceHomePageViewController.h"
#import "NXProtectRepoFileSelectLocationVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXAddToProjectVC.h"
#import "NXWorkSpaceVC.h"
#import "NXWorkSpaceNavigationVC.h"
#import "NXRepositoriesVC.h"
#import "NXWorkSpaceUploadFileVC.h"
#import "NXHomeRepoVC.h"
#import "NXAddToProjectLastVC.h"
#import "NXProjectFilesVC.h"
#import "NXProjectInviteMemberView.h"
#import "NXCommentInputView.h"
#import "NXLocalContactsVC.h"
#import "NXContactInfoTool.h"
#import "NXUpdateProjectInfoVC.h"
#import "NXPeopleViewController.h"
#import "NXProjectsNavigationController.h"
#define kWaitingViewTag 2142423
@interface AddSpaceViewController : UIViewController
@end

@implementation AddSpaceViewController
@end

@interface NXMasterTabBarViewController ()<UITabBarControllerDelegate, NXFileChooseFlowViewControllerDelegate,NXLocalContactsVCDelegate,DetailViewControllerDelegate>

@property(nonatomic, strong) NXPhotoSelector *photoSelector;

//for NXFileChooseFlowVC, i have to remember why choose file/folder. so use this flag
@property(nonatomic, strong) NSDictionary *chooseType; //1:NXRepositoryModel means protect form repo, 2:NXRepositoryModel means share from repo. 3:NXRepositoryModel createNewFolder.
@property(nonatomic, strong) NXFileBase *currentFolder;
@property(nonatomic, strong) NXContextMenu *connectMenu;
@property(nonatomic, strong) UIButton *globalAddButton;
@property(nonatomic, assign) NXContextMenuType currentMenuType;
@property(nonatomic, strong)  UITabBarItem *itemWorkSpace;
@property(nonatomic, strong) NXProjectModel *currentProject;
@property(nonatomic, strong) NXProjectInviteMemberView *memberView;
@end

@implementation NXMasterTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NXMySpaceHomeVC *homeVC =[[NXMySpaceHomeVC alloc]init];
    NXHomeNavigationVC *homeNav = [[NXHomeNavigationVC alloc] initWithRootViewController:homeVC];
    NXWorkSpaceVC *workSpaceVC = [[NXWorkSpaceVC alloc]init];
    NXWorkSpaceNavigationVC *workSpaceNav = [[NXWorkSpaceNavigationVC alloc]initWithRootViewController:workSpaceVC];
    
//    NXFilesViewController *filesVC = [[NXFilesViewController alloc] init];
//    NXFilesNavigationVC *filesNav = [[NXFilesNavigationVC alloc]initWithRootViewController:filesVC];
    
    NXRepositoriesVC *homeRepoVC = [[NXRepositoriesVC alloc] init];
    NXFilesNavigationVC *homeRepoNav = [[NXFilesNavigationVC alloc] initWithRootViewController:homeRepoVC];
    
    NXMySpaceHomePageViewController *mySpaceVC = [[NXMySpaceHomePageViewController alloc] init];
    NXNewMySpaceNavigationVC *mySpaceNav = [[NXNewMySpaceNavigationVC alloc]initWithRootViewController:mySpaceVC];

    NXAllProjectsViewController *allProejctVC = [[NXAllProjectsViewController alloc]init];
    NXHomeNavigationVC *projectNav = [[NXHomeNavigationVC alloc] initWithRootViewController:allProejctVC];
    
   // AddSpaceViewController *vc = [[AddSpaceViewController alloc] init];
    NSArray *vcArray = [NSArray arrayWithObjects:homeNav,workSpaceNav,mySpaceNav,homeRepoNav,projectNav,nil];
    [self setViewControllers:vcArray];
    
    // Init tabbar items
    UITabBar *tabBar = self.tabBar;
    NSDictionary *selDic = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                             NSForegroundColorAttributeName:RMC_MAIN_COLOR};
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                          NSForegroundColorAttributeName:[UIColor blackColor]};
    
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:selDic forState:UIControlStateSelected];
    [item setTitleTextAttributes:dic forState:UIControlStateNormal];

    UITabBarItem *itemHome = [tabBar.items objectAtIndex:0];
    itemHome.title = NSLocalizedString(@"UI_HOME", NULL);
    itemHome.image = [[UIImage imageNamed:@"Home-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    itemHome.selectedImage = [UIImage imageNamed:@"Home Selected"];
    itemHome.accessibilityValue = @"HOME_TAB_ITEM";
    
    UITabBarItem *itemWorkSpace = [tabBar.items objectAtIndex:1];
    itemWorkSpace.title = NSLocalizedString(@"UI_WORKSPACE_ITEM", NULL);
    itemWorkSpace.image = [[UIImage imageNamed:@"WorkSpace - Gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    itemWorkSpace.selectedImage = [UIImage imageNamed:@"Green-workSpace-icon"];
    self.itemWorkSpace = itemWorkSpace;
    if ([NXCommonUtils isSupportWorkspace]) {
        itemWorkSpace.enabled = YES;
    }else{
        itemWorkSpace.enabled = NO;
    }
   
    UITabBarItem *itemMySpace = [tabBar.items objectAtIndex:2];
    itemMySpace.title = NSLocalizedString(@"UI_MY_SPACE",NULL);
    itemMySpace.image = [[UIImage imageNamed:@"MySpace-nav-bar-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    itemMySpace.selectedImage = [UIImage imageNamed:@"MySpace selected"];
    itemMySpace.accessibilityValue = @"MY_SPACE_TAB_ITEM";
    
    UITabBarItem *itemRepo = [tabBar.items objectAtIndex:3];
     itemRepo.title =  @"Repositories";
    itemRepo.image = [[UIImage imageNamed:@"repositories"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     itemRepo.selectedImage = [UIImage imageNamed:@"Repositories-Green"];
     itemRepo.accessibilityValue = @"MY_SPACE_TAB_ITEM";
    
    UITabBarItem *itemProjects = [tabBar.items objectAtIndex:4];
   
    itemProjects.title = @"Projects" ;
    
    
    itemProjects.image = [[UIImage imageNamed:@"Projects-nav-bar-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    itemProjects.selectedImage = [UIImage imageNamed:@"Projects-nav-bar-icon-selected"];
    itemProjects.accessibilityValue = @"MY_PROJECT_TAB_ITEM";
    
//    UITabBarItem *itemMore = [tabBar.items objectAtIndex:4];
//    itemMore.image = [[UIImage imageNamed:@"Add Utility"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    if ([NXCommonUtils isiPad]) {
//        [itemMore setImageInsets:UIEdgeInsetsMake(6, -8, -3, 8)];
//    }else{
//        [itemMore setImageInsets:UIEdgeInsetsMake(6, -8, -6, 8)];
//    }
//
//    itemMore.accessibilityValue = @"ADD_TAB_ITEM";
    
    self.tabBar.backgroundColor = [UIColor whiteColor];
    self.tabBar.backgroundImage = [[UIImage alloc] init];
    
    self.tabBar.shadowImage = [[UIImage alloc] init];
    self.tabBar.layer.shadowOffset = CGSizeMake(0, 5);
    self.tabBar.layer.shadowOpacity = 0.9;
    self.tabBar.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.tabBar.layer.shadowRadius = 10;
    
    self.delegate = self;
    [self commmonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenGlobalAddButton:) name:NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_HIDDEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGlobalAddButton:) name:NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSupportWorkspaceState:) name:NOTIFICATION_WORKSPACE_STATE_UPDATE object:nil];
}
- (void)updateSupportWorkspaceState:(id)sender{
    if ([NXCommonUtils isSupportWorkspace]) {
        self.itemWorkSpace.enabled = YES;
    }else{
        self.itemWorkSpace.enabled = NO;
    }
}
- (void)commmonInit{
    [self.view addSubview:self.globalAddButton];
     //获取tabBar的高度
    CGFloat tabBarHeight = self.tabBar.frame.size.height;
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        //获取安全区域底部高度
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        bottomPadding = window.safeAreaInsets.bottom;
    }
        [self.globalAddButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@52);
        make.bottom.equalTo(self.view).offset(-(tabBarHeight+20+bottomPadding));
        make.right.equalTo(self.view).offset(-20);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.globalAddButton setHidden:NO];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.globalAddButton setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIButton *)globalAddButton
{
    if (!_globalAddButton) {
        _globalAddButton = [[UIButton alloc] init];
        [_globalAddButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_globalAddButton setImage:[UIImage imageNamed:@"Add Utility"] forState:UIControlStateNormal];
        [_globalAddButton setImage:[UIImage imageNamed:@"Add Utility"] forState:UIControlStateHighlighted];
    }
    return _globalAddButton;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter setter
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if ([[self.viewControllers objectAtIndex:selectedIndex] isKindOfClass:[AddSpaceViewController class]]) {
        NSLog(@"%s", __FUNCTION__);
//    } else if ([[self.viewControllers objectAtIndex:selectedIndex] isKindOfClass:[NXHomeNavigationVC class]]){
//        [super setSelectedIndex:selectedIndex];
//        NXHomeNavigationVC *homeVC = (NXHomeNavigationVC*)[self.viewControllers objectAtIndex:selectedIndex];
//            [homeVC popToRootViewControllerAnimated:NO];
//    }
    }else{
         [super setSelectedIndex:selectedIndex];
    }
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    if ([selectedViewController isKindOfClass:[AddSpaceViewController class]]) {
        NSLog(@"%s", __FUNCTION__);
    } else {
        [super setSelectedViewController:selectedViewController];
    }
}

- (void)test:(NXFileBase *)currentFolder handler:(NXContextMenuHandler *)handle {
    switch (handle.action) {
        case NXContextMenuActionShare:
        {
            if ([handle.data isKindOfClass:[NXRepositoryModel class]]) {
                [self shareFromRepo:handle.data];
            }else if ([handle.data isEqualToString:@"Files"]){
                [self shareFromFiles];
            }
            else {
                [self shareLocal];
            }
        }
            break;
        case NXContextMenuActionActionMyDriveForSharing:
        {
            [self shareFromRepo:[[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository]];
        }
            break;
        case NXContextMenuActionProtect:
        {
            if ([handle.data isKindOfClass:[NXRepositoryModel class]]) {
                [self protectFromRepo:handle.data];
            } else if([handle.data isEqualToString:@"Files"]) {
                [self protectFromFiles];
            }else{
                [self protectLocal];
            }
        }
            break;
        case NXContextMenuActionSelectFileFromMyDriveForProtecting:
        {
            [self protectFromRepo:[[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository]];
        }
            break;
        case NXContextMenuActionConnect:
        {
            [self connect];
        }
            break;
        case NXContextMenuActionNewProject:
        {
            [self newProject];
        }
            break;
        case NXContextMenuActionAddFile:
        {
            if ([handle.data isEqualToString:@"Files"]) {
                [self addFileFromFilesApp];
            }else{
                [self addFile];
            }
           
        }
            break;
        case NXContextMenuActionAddFileFromRepo:
        {
            [self addFileFromRepo:handle.data];
        }
            break;
        case NXContextMenuActionCreateFolder:
        {
            [self createNewFolder:nil];
        }
            break;
        case NXContextMenuActionCreateProjectFolder:
            [self createProjectFolder:currentFolder];
            break;
        case NXContextMenuActionCreateFolderFromWorkspace:
        {
            [self createNewFolderForWorSpace:currentFolder];
        }
            break;
        case NXContextMenuActionAddFileToWorkSpaceFromLocal:
        {
            [self addLocalFileToWorkSpace:currentFolder];
        }
            break;
        case NXContextMenuActionAddFileToWorkSpaceFromRepo:
        {
            [self addFileToWorkSpaceToWorkSpaceFromRepo:handle.data];
        }
            break;
        case NXContextMenuActionScanDocument:
        {
            [self scanDocument];
        }
            break;
        case NXContextMenuActionActionScanDocumentForProtecting:
            
        {
            [self scanDocumentForProtecting];
        }
            break;
        case NXContextMenuActionActionScanDocumentForSharing:
        {
            [self scanDocumentForSharing];
        }
            break;
        case NXContextMenuActionAddFileToProjectFromRepo:
        {
            [self addFileToProjectFromRepo:handle.data];
        }
            break;
        case NXContextMenuActionAddFileToProjectFromLocal:
        {
            [self addFileToProjectFromLocal];
        }
            break;
        case NXContextMenuActionScanDocumentToProject:
            [self scanDocumentToProject];
            break;
        case NXContextMenuActionAddNXLFileToProjectOrWorkSpaceFromFiles:
            [self importNXlFileFromFiles];
            break;
        case NXContextMenuActionAddNXLFileToOtherSpaceFromRepo:
        {
            [self addNXlFileFromRepo:handle.data];
        }
            break;
        case NXContextMenuActionScanDocumentToWorkspace:
        {
            [self scanDocumentToWorkSpace:currentFolder];
        }
            break;
        case NXContextMenuActionAddNXLFileFromWorkSpace:
        {
            [self selectNXlFileFromWorkspace];
        }
            break;
        case NXContextMenuActionAddNXLFileFromProject:
        {
            [self selectNXLFileFromProject:handle.data];
        }
            break;
        case NXContextMenuActionAddNXLFileFromRepo:
        {
            [self selectNXLFileFromRepo:handle.data];
        }
            break;
        case NXContextMenuActionAddNXLFileFromMySpace:
        {
            [self selectNXLFileFromMyVault];
        }
            break;
        case NXContextMenuActionInviteMember:
        {
            [self inviteProjectMembers];
        }
            break;
        case NXContextMenuActionViewMembers:
        {
            [self viewProjectMembers];
        }
            break;
        case NXContextMenuActionProjectConfiguration:
        {
            [self setProjectConfiguration];
        }
            break;
        case NXContextMenuActionViewLocalFile:
        {
            [self viewLocalFile];
        }
            break;
        default:
            break;
    }
}

#pragma mark - private method

-(void)hiddenGlobalAddButton:(id)sender{
    [self.globalAddButton setHidden:YES];
}

-(void)showGlobalAddButton:(id)sender{
    [self.globalAddButton setHidden:NO];
}

- (void)addButtonClicked:(id)sender {
    for (NXRepositoryModel *model in [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories]) {
        if (model.service_type.integerValue == kServiceSkyDrmBox) {
            _currentFolder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:model];
        }
    }
    self.currentProject = nil;
    NXContextMenuType type = NXContextMenuTypeMySkyDRMHome;
    switch (self.selectedIndex) {
        case 0:
        {
            type = NXContextMenuTypeMySkyDRMHome;
            NXHomeNavigationVC *nav = [self.viewControllers objectAtIndex:self.selectedIndex];
            if (nav.viewControllers.count > 1 && [nav.viewControllers.lastObject isKindOfClass:[NXProjectFilesVC class]]) {
                NXProjectFilesVC * projectVC = nav.viewControllers.lastObject;
                self.currentProject = projectVC.projectModel;
                if (self.currentProject.isOwnedByMe) {
                    type = NXContextMenuTypeProjectByMeFiles;
                }else{
                    type = NXContextMenuTypeProjectByOthersFiles;
                }
                _currentFolder = projectVC.projectFileListNav.currentFolder;
            }
        }
            break;
        case 1:
        {
            _currentFolder = [[NXLoginUser sharedInstance].workSpaceManager rootFolderForWorkSpace];
             if (self.selectedIndex == 1) {
                 NXWorkSpaceNavigationVC *filesNav = (NXWorkSpaceNavigationVC*)[self selectedViewController];;
                 NXWorkSpaceVC *filesVC = filesNav.viewControllers.firstObject;
                 _currentFolder = filesVC.fileNavVC.currentFolder;
             }
            if ([[NXLoginUser sharedInstance] isTenantAdmin]) {
                type = NXContextMenuTypeWorkSpaceAllTenantAdmin;
            }else{
                type = NXContextMenuTypeWorkSpaceAllUsual;
            }
           
        }
            break;
        case 2:
        {
            type = NXContextMenuTypeMySpaceRootPage;
            NXNewMySpaceNavigationVC *nav = [self.viewControllers objectAtIndex:self.selectedIndex];
            NXMySpaceHomePageViewController *mySpaceHomePageVC = [nav.viewControllers.firstObject isKindOfClass:[NXMySpaceHomePageViewController class]]?nav.viewControllers.firstObject :nil;
            if (nav.viewControllers.count > 1) {
                if (mySpaceHomePageVC.currentmydriveVC) {
                     type = NXContextMenuTypeMySpaceMyDriveAll;
                    if (mySpaceHomePageVC.currentmydriveVC.currentPageIndex == 0) {
                        _currentFolder = mySpaceHomePageVC.currentmydriveVC.fileListNav.currentFolder;
                    }
                }else{
                      type = NXContextMenuTypeMySpaceMyVault;
                }
            }
        }
            break;
        case 3:
        {
            type = NXContextMenuTypeRepositories;
            NXFilesNavigationVC *nav = [self.viewControllers objectAtIndex:self.selectedIndex];
            if (nav.viewControllers.count > 1) {
                type = NXContextMenuTypeRepositoryDetailFiles;
                if ([nav.viewControllers.lastObject isKindOfClass:[NXHomeRepoVC class]]) {
                    NXHomeRepoVC *currentRepoVC = nav.viewControllers.lastObject;
                    if (currentRepoVC.currentPageIndex == 1) {
                        _currentFolder = currentRepoVC.onlyprotectedfileListNav.currentFolder;
                    }else{
                        _currentFolder = currentRepoVC.fileListNav.currentFolder;
                    }
                   
                }
                
            }
            
        }
            break;
        case  4:
        {
            type = NXContextMenuTypeAllProjects;
            NXHomeNavigationVC *nav = [self.viewControllers objectAtIndex:self.selectedIndex];
            if (nav.viewControllers.count > 1) {
                NXProjectFilesVC * projectVC = nav.viewControllers.lastObject;
                self.currentProject = projectVC.projectModel;
                if (self.currentProject.isOwnedByMe) {
                    type = NXContextMenuTypeProjectByMeFiles;
                }else{
                    type = NXContextMenuTypeProjectByOthersFiles;
                }
                _currentFolder = projectVC.projectFileListNav.currentFolder;
               
                
            }
        }
            break;;
        default:
            break;
    }
    self.currentMenuType = type;
    WeakObj(self);
    _connectMenu = [NXContextMenu showType:type andCurrentModel:self.currentProject withHandler:^(NXContextMenuHandler *handler) {
        StrongObj(self);
        [self test:_currentFolder handler:handler];
    }];
    
    return;
}

#pragma mark - action
//Add File action
- (void)scanDocumentToWorkSpace:(NXFileBase *)folder {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                NXFile *file = [[NXFile alloc] init];
                file.size = fileData.length;
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                [self showLocalUpload:localPath folder:(NXWorkSpaceFolder *) folder];
            });
        }
    }];
}
- (void)addLocalFileToWorkSpace:(NXFileBase *)folder {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                [self showLocalUpload:localPath folder:(NXWorkSpaceFolder *)folder];
            });
        }
    }];
}
- (void)showLocalUpload:(NSString *)localPath folder:(NXWorkSpaceFolder *)folder {
    NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
    NXFile *file = [[NXFile alloc] init];
    file.size = fileData.length;
    file.localPath = localPath;
    file.name = localPath.lastPathComponent;
    file.isRoot = NO;
    file.sorceType = NXFileBaseSorceTypeLocal;
    
    NXWorkSpaceUploadFileVC *vc = [[NXWorkSpaceUploadFileVC alloc] init];
    vc.fileItem = file;
    vc.folder = folder;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
- (void)selectNXlFileFromWorkspace{
    self.chooseType = @{@(NXContextMenuActionAddNXLFileFromWorkSpace):@"Workspace"};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeNxlFile];
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
- (void)selectNXLFileFromRepo:(NXRepositoryModel *)currentModel {
    self.chooseType = @{@(NXContextMenuActionAddNXLFileFromRepo):currentModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:currentModel type:NXFileChooseFlowViewControllerTypeNxlFile isSupportMultipleSelect:NO];
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
- (void)addFileToWorkSpaceToWorkSpaceFromRepo:(NXRepositoryModel *)repositoryModel{
    self.chooseType = @{@(NXContextMenuActionAddFileToWorkSpaceFromRepo):repositoryModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:repositoryModel type:NXFileChooseFlowViewControllerTypeNormalFile isSupportMultipleSelect:YES];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
}
- (void)createNewFolderForWorSpace:(NXFileBase *)folder {
    NXNewFolderViewController *newFolderVC = [[NXNewFolderViewController alloc] init];
    folder.sorceType = NXFileBaseSorceTypeWorkSpace;
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
- (void)createProjectFolder:(NXFileBase *)folder {
    if (!folder) {
        return;
    }
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

- (void)addFileToProjectFromLocal{
   NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
   self.photoSelector = selecter;
   WeakObj(self);
   [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
       if (selectedItems.count != 0) {
           StrongObj(self);
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               NSString *localPath = selectedItems.lastObject;
               NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
               NXFile *file = [[NXFile alloc] init];
               file.size = fileData.length;
               file.localPath = localPath;
               file.name = localPath.lastPathComponent;
               file.isRoot = NO;
               file.sorceType = NXFileBaseSorceTypeLocal;
               [self showPreviewToprojectPage:file];
           });
       }
   }];
}

- (void)addFileToProjectFromRepo:(NXRepositoryModel *)repositoryModel{
    self.chooseType = @{@(NXContextMenuActionAddFileToProjectFromRepo):repositoryModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:repositoryModel type:NXFileChooseFlowViewControllerTypeChooseFile isSupportMultipleSelect:YES];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showWaitingView];
    });
}
- (void)scanDocumentToProject{
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                NXFile *file = [[NXFile alloc] init];
                file.size = fileData.length;
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                [self showPreviewToprojectPage:file];
            });
        }
    }];
}

- (void)addFile {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                NXFile *file = [[NXFile alloc] init];
                file.size = fileData.length;
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                [self showPreviewPage:file];
            });
        }
    }];
}
- (void)addFileFromFilesApp {
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    [transfer importShareOriginalFilesDocumentFromVC:self.navigationController];
    transfer.improtFileCompletion = ^(UIViewController *currentVC,NXFile *fileItem, NSData *fileData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }else{
                [self showPreviewPage:fileItem];
            }
            
        });
       
    };

}
// Add File From Repo
- (void)addFileFromRepo:(NXRepositoryModel *)repositoryModel
{
    // now only project achieve this
}

//scan a document action
- (void)scanDocument {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                NXFile *file = [[NXFile alloc] init];
                file.size = fileData.length;
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                [self showPreviewPage:file];
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
                NSString *localPath = selectedItems.lastObject;
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                NXFile *file = [[NXFile alloc] init];
                file.size = fileData.length;
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                [self showProtectSelectLocationWithFilesFromLocal:@[file] withCurrentFolder:self.currentFolder];
            });
        }
    }];
}
- (void)scanDocumentForSharing{
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                NXFile *file = [[NXFile alloc] init];
                file.size = fileData.length;
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                [self showLocalShare:file];
            });
        }
    }];
    
}

- (void)importNXlFileFromFiles{
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    [transfer importProtectNXLFilesDocumentFromVC:self.navigationController];
    transfer.improtFileCompletion = ^(UIViewController *currentVC,NXFile *fileItem, NSData *fileData, NSError *error) {
        if (error) {
            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
        }else{
            if (self.currentMenuType == NXContextMenuTypeWorkSpaceAllTenantAdmin || self.currentMenuType == NXContextMenuTypeWorkSpaceAllUsual) {
                NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
                VC.isFromDefaultPath = YES;
                VC.isLocalFile = YES;
                VC.fileOperationType = NXFileOperationTypeAddNXLFileToWorkSpace;
                VC.currentFile = fileItem;
                VC.folder = self.currentFolder;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }else if(self.currentMenuType == NXContextMenuTypeProjectByOthersFiles || self.currentMenuType == NXContextMenuTypeProjectByMeFiles){
                NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
                VC.isFromDefaultPath = YES;
                VC.isLocalFile = YES;
                VC.fileOperationType = NXFileOperationTypeAddNXLFileToProject;
                VC.currentFile = fileItem;
                VC.folder = self.currentFolder;
                VC.toProject = self.currentProject;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }else{
                NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                VC.isLocalFile = YES;
                VC.currentFile = fileItem;
                VC.fileOperationType = NXFileOperationTypeAddLocalProtectedFileToOther;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
           
    };
}
- (void)addNXlFileFromRepo:(NXRepositoryModel *)repositoryModel{
    self.chooseType = @{@(NXContextMenuActionAddNXLFileToOtherSpaceFromRepo):repositoryModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:repositoryModel type:NXFileChooseFlowViewControllerTypeNxlFile isSupportMultipleSelect:NO];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showWaitingView];
    });
    
}
//Protect -> Upload from Library action
- (void)protectLocal {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeMultiSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSMutableArray *filesArray = [NSMutableArray array];
                for (NSString *localPath in selectedItems) {
                    NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                    NXFile *file = [[NXFile alloc] init];
                    file.size = fileData.length;
                    file.localPath = localPath;
                    file.name = localPath.lastPathComponent;
                    file.isRoot = NO;
                    file.sorceType = NXFileBaseSorceTypeLocal;
                    [filesArray addObject:file];
                    
                }
//                NSString *localPath = selectedItems.lastObject;
//                NXFile *file = [[NXFile alloc] init];
//                file.localPath = localPath;
//                file.name = localPath.lastPathComponent;
//                file.isRoot = NO;
//                file.sorceType = NXFileBaseSorceTypeLocal;
//                [self showLocalProtect:file];
                [self showProtectSelectLocationWithFilesFromLocal:filesArray withCurrentFolder:self.currentFolder];
            });
        }
    }];
}
- (void)protectFromFiles {
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    [transfer importOriginalFilesDocumentFromVC:self.navigationController];
    transfer.improtMultipleFileCompletion = ^(UIViewController *currentVC, NSArray *fileArray, NSError *error) {
        [self showProtectSelectLocationWithFilesFromFiles:fileArray withCurrentFolder:self.currentFolder];
        
    };
    
}
//Protect -> Choose from repository action.
- (void)protectFromRepo:(NXRepositoryModel *)repositoryModel {
    self.chooseType = @{@(1):repositoryModel};
//    self.currentFolder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:repositoryModel];
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:repositoryModel type:NXFileChooseFlowViewControllerTypeNormalFile isSupportMultipleSelect:YES];
    chooseVC.fileChooseVCDelegate = self;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showWaitingView];
    });
}

//Share -> Upload from repository action
- (void)shareLocal {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self showPreviewPage:selectedItems.lastObject];
                NSString *localPath = selectedItems.lastObject;
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                NXFile *file = [[NXFile alloc] init];
                file.size = fileData.length;
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                
                [self showLocalShare:file];
            });
        }
    }];
}
- (void)shareFromFiles {
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    [transfer importShareOriginalFilesDocumentFromVC:self.navigationController];
    transfer.improtFileCompletion = ^(UIViewController *currentVC,NXFile *fileItem, NSData *fileData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }else{
                [self showLocalShare:fileItem];
            }
            
        });
       
    };
    
}
//Share -> Choose from repository action
- (void)shareFromRepo:(NXRepositoryModel *)repositoryModel {
    self.chooseType = @{@(2):repositoryModel};
    NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:repositoryModel type:NXFileChooseFlowViewControllerTypeNormalFile isSupportMultipleSelect:NO];
    chooseVC.supportMultipleSelect = NO;
    chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    chooseVC.fileChooseVCDelegate = self;
    [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showWaitingView];
    });
}

//Connect action
- (void)connect {
    NXAddRepositoryViewController *vc = [[NXAddRepositoryViewController alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.primaryNavigationController pushViewController:vc animated:YES];
//    NSMutableArray *connectArray = [NSMutableArray array];
//    NSArray *array = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
//    for (NXRepositoryModel *repoModel in array) {
//        if (!(repoModel.service_type.integerValue == kServiceSkyDrmBox)) {
//            [connectArray addObject:repoModel];
//        }
//    }
//
//    if (connectArray.count == 0) {
//        NXAddRepositoryViewController *vc = [[NXAddRepositoryViewController alloc] init];
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.primaryNavigationController pushViewController:vc animated:YES];
//    }else {
//        NXRepositoryViewController *repoVC = [[NXRepositoryViewController alloc]init];
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.primaryNavigationController pushViewController:repoVC animated:YES];
//    }
}

- (void)newProject {
    NXNewProjectVC *projectVC = [[NXNewProjectVC alloc] init];
    projectVC.hidesBottomBarWhenPushed = YES;
    
    if (self.selectedIndex == 0) {
        [((UINavigationController *)self.selectedViewController) pushViewController:projectVC animated:YES];
    }
}

//Create New Folder action
- (void)createNewFolder:(NXRepositoryModel *)repositoryModel {
    NXNewFolderViewController *newFolderVC = [[NXNewFolderViewController alloc] init];
    if (_currentFolder.serviceType.integerValue == kServiceSkyDrmBox) {
        newFolderVC.parentFolder = _currentFolder;
    } else {
        newFolderVC.parentFolder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:[[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository]];
    }
    newFolderVC.createFolderFinishedBlock = ^(NXFileBase *newFolder, NSError *error) {
        if (error) {
            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
        } else {
            NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"MSG_COM_CREATE_FOLDER_SUCCESS", NULL), newFolder.name];
            [NXMBManager showMessage:message hideAnimated:YES afterDelay:kDelay];
        }
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:newFolderVC];
        [self presentViewController:nav animated:YES completion:nil];
    });

}

//show Add Files Page to response Add File action
- (void)showPreviewToprojectPage:(NXFileBase *)fileItem{
    NXAddToPojectFromTabBarPageVC *addVC = [[NXAddToPojectFromTabBarPageVC alloc]init];
    addVC.fileItem = fileItem;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:addVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (void)showPreviewPage:(NXFileBase *)fileItem {
    NXRepoSpaceUploadVC *uploadVC = [[NXRepoSpaceUploadVC alloc] init];
    uploadVC.fileItem = fileItem;
    if (_currentFolder.serviceType.integerValue == kServiceSkyDrmBox) {
        uploadVC.folder = _currentFolder;
    } else {
        uploadVC.folder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:[[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository]];
    }
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:uploadVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showLocalProtect:(NXFileBase *)fileItem {
    NXLocalProtectVC *vc = [[NXLocalProtectVC alloc] init];
    vc.fileItem = fileItem;
    vc.currentType = NXSelectRightsTypeDigital;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showLocalShare:(NXFileBase *)fileItem {
    NXLocalShareVC *vc = [[NXLocalShareVC alloc] init];
    vc.currentType = NXShareSelectRightsTypeDigital;
    vc.fileItem = fileItem;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (UIImage *)repoTypeImage:(NXRepositoryModel *)repoModel {
    UIImage *image = [UIImage imageNamed:@""];
    switch (repoModel.service_type.integerValue) {
        case kServiceSkyDrmBox:
            image = [UIImage imageNamed:@"MyDrive"];
            break;
        case kServiceDropbox:
            image = [UIImage imageNamed:@"dropbox - black"];
            break;
        case kServiceGoogleDrive:
            image = [UIImage imageNamed:@"google-drive-color"];
            break;
        case kServiceOneDrive:
            image = [UIImage imageNamed:@"onedrive - black"];
            break;
        case kServiceSharepointOnline:
            image = [UIImage imageNamed:@"sharepoint - black"];
            break;
        case kServiceBOX:
            image = [UIImage imageNamed:@"box - black"];
            break;
        case kServiceOneDriveApplication:
            image = [UIImage imageNamed:@"onedrive - black"];
            break;
        default:
            break;
    }
    return image;
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
    hud.tag = kWaitingViewTag;
    
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
- (void)showProtectSelectLocationWithFilesFromLocal:(NSArray *)fileItems  withCurrentFolder:(NXFileBase *)currentFolder{
    if (self.currentMenuType == NXContextMenuTypeMySpaceMyDriveAll || self.currentMenuType == NXContextMenuTypeMySpaceMyVault) {
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeMyVault;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }else if(self.currentMenuType == NXContextMenuTypeMySkyDRMHome || self.currentMenuType == NXContextMenuTypeAllProjects || self.currentMenuType == NXContextMenuTypeRepositories || self.currentMenuType == NXContextMenuTypeMySpaceRootPage){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeMyVault;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }
    else if(self.currentMenuType == NXContextMenuTypeWorkSpaceAllTenantAdmin || self.currentMenuType == NXContextMenuTypeWorkSpaceAllUsual){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.saveFolder = currentFolder;
        VC.locationType = NXProtectSaveLoactionTypeWorkSpace;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }else if(self.currentMenuType == NXContextMenuTypeRepositoryDetailFiles){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeFileRepo;
        if (currentFolder) {
            VC.saveFolder = currentFolder;
        }
       
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }else if(self.currentMenuType == NXContextMenuTypeProjectByMeFiles || self.currentMenuType == NXContextMenuTypeProjectByOthersFiles){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeProject;
        VC.targetProject = self.currentProject;
        VC.saveFolder = currentFolder;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
//    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
//    VC.fileItem = fileItem;
//    VC.locationType = NXProtectSaveLoactionTypeLocalFiles;
//    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];

}
- (void)showProtectSelectLocationWithFilesFromFiles:(NSArray *)fileItems  withCurrentFolder:(NXFileBase *)currentFolder{
    if (self.currentMenuType == NXContextMenuTypeMySpaceMyDriveAll || self.currentMenuType == NXContextMenuTypeMySpaceMyVault ||  self.currentMenuType == NXContextMenuTypeMySpaceRootPage) {
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeMyVault;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }else if(self.currentMenuType == NXContextMenuTypeMySkyDRMHome || self.currentMenuType == NXContextMenuTypeAllProjects || self.currentMenuType == NXContextMenuTypeRepositories){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeLocalFiles;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }else if(self.currentMenuType == NXContextMenuTypeWorkSpaceAllTenantAdmin || self.currentMenuType == NXContextMenuTypeWorkSpaceAllUsual){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.saveFolder = currentFolder;
        VC.locationType = NXProtectSaveLoactionTypeWorkSpace;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }else if(self.currentMenuType == NXContextMenuTypeRepositoryDetailFiles){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeFileRepo;
        if (currentFolder) {
            VC.saveFolder = currentFolder;
        }
       
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }else if(self.currentMenuType == NXContextMenuTypeProjectByMeFiles || self.currentMenuType == NXContextMenuTypeProjectByOthersFiles){
        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
        VC.filesArray = fileItems;
        VC.locationType = NXProtectSaveLoactionTypeProject;
        VC.targetProject = self.currentProject;
        VC.saveFolder = currentFolder;
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}
- (void)inviteProjectMembers {
    WeakObj(self);
    if (!self.currentProject) {
        return;
    }
    NXProjectInviteMemberView *memberView = [[NXProjectInviteMemberView alloc] initWithTitle:self.currentProject.invitationMsg inviteHander:^(NXProjectInviteMemberView *alertView) {
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
        [[NXLoginUser sharedInstance].myProject  inviteMember:emailsArray invitationMsg:invitationMsg inProject:self.currentProject withCompletion:^(NXProjectModel *project, NSDictionary *resultDic, NSError *error) {
            
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
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_INVITE_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
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
- (void)viewProjectMembers {
    if (!self.currentProject) {
        return;
    }
    NXPeopleViewController *peopleVC = [[NXPeopleViewController alloc] initWithStyle:UITableViewStyleGrouped];
    peopleVC.projectModel = self.currentProject;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:peopleVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
- (void)setProjectConfiguration{
    if (!self.currentProject) {
        return;
    }
    NXUpdateProjectInfoVC *VC = [[NXUpdateProjectInfoVC alloc]init];
    VC.needUpdateProjectModel = self.currentProject;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
    
}
- (void)viewLocalFile {
    WeakObj(self);
    NXOriginalFilesTransfer *transfer = [NXOriginalFilesTransfer sharedIInstance];
    [transfer importOneLocalfileFromVC:self.navigationController];
    [NXMBManager showLoading];
    transfer.improtFileCompletion = ^(UIViewController *currentVC,NXFile *fileItem, NSData *fileData, NSError *error) {
        StrongObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }else{
                AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [app showFileItem:fileItem from:self withDelegate:self];
            }
            
        });
       
    };
    transfer.cancelCompletion = ^(UIViewController *currentVC) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
        });
        
    };
}

- (void)showProtectSelectLocationFilesFromRepo:(NSArray *)fileItems withCurrentFolder:(NXFileBase *)currentFolder {
////    if (self.currentMenuType == NXContextMenuTypeMySkyDRMHome || self.currentMenuType == NXContextMenuTypeMySpaceMyDriveAll || self.currentMenuType == NXContextMenuTypeMySpaceMyVault) {
////        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
////        VC.filesArray = fileItems;
////        VC.locationType = NXProtectSaveLoactionTypeMyVault;
////        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
////        [self.navigationController presentViewController:nav animated:YES completion:nil];
////
////    }else
//    if(self.currentMenuType == NXContextMenuTypeWorkSpaceAllTenantAdmin || self.currentMenuType == NXContextMenuTypeWorkSpaceAllUsual){
//        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
//        VC.filesArray = fileItems;
//        VC.saveFolder = currentFolder;
//        VC.locationType = NXProtectSaveLoactionTypeWorkSpace;
//        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
//        [self.navigationController presentViewController:nav animated:YES completion:nil];
//
//    }else if(self.currentMenuType == NXContextMenuTypeRepositoryDetailFiles){
//        NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
//        VC.filesArray = fileItems;
//        VC.locationType = NXProtectSaveLoactionTypeFileRepo;
//        if (currentFolder) {
//            VC.saveFolder = currentFolder;
//    }
    if (self.currentMenuType == NXContextMenuTypeMySpaceMyVault || self.currentMenuType == NXContextMenuTypeMySpaceMyDriveAll || self.currentMenuType == NXContextMenuTypeMySpaceRootPage) {
          NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
          VC.filesArray = fileItems;
          VC.locationType = NXProtectSaveLoactionTypeMyVault;
          NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
          [self.navigationController presentViewController:nav animated:YES completion:nil];
  
      }else if(self.currentMenuType == NXContextMenuTypeWorkSpaceAllTenantAdmin || self.currentMenuType == NXContextMenuTypeWorkSpaceAllUsual){
            NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
            VC.filesArray = fileItems;
            VC.saveFolder = currentFolder;
            VC.locationType = NXProtectSaveLoactionTypeWorkSpace;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            
        }else if(self.currentMenuType == NXContextMenuTypeRepositoryDetailFiles){
            NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
            VC.filesArray = fileItems;
            VC.locationType = NXProtectSaveLoactionTypeFileRepo;
            if (currentFolder) {
                VC.saveFolder = currentFolder;
            }
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }else if(self.currentMenuType == NXContextMenuTypeProjectByMeFiles || self.currentMenuType == NXContextMenuTypeProjectByOthersFiles){
            NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
            VC.filesArray = fileItems;
            VC.locationType = NXProtectSaveLoactionTypeProject;
            VC.targetProject = self.currentProject;
            VC.saveFolder = currentFolder;
            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }else {
            NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
            VC.filesArray = fileItems;
            NXFileBase *fileItem = fileItems.firstObject;
            if (fileItem.serviceType == [NSNumber numberWithInteger:kServiceSkyDrmBox]) {
                VC.locationType = NXProtectSaveLoactionTypeMyVault;
            }else if(fileItem.serviceType == [NSNumber numberWithInteger:KServiceSharepointOnlineApplication] || fileItem.serviceType == [NSNumber numberWithInteger:kServiceOneDriveApplication]){
                VC.locationType = NXProjectSaveLocationTypeSharedWorkSpace;
                VC.saveFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:fileItem];
                
            }else{
                VC.locationType = NXProtectSaveLoactionTypeFileRepo;
                VC.saveFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:fileItem];
                
            }
        NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }
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
#pragma mark - NXFileChooseFlowViewControllerDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (!self.chooseType.count || !choosedFiles.count) {
        [self hiddenWaitingView:nil];
        return;
    }
    
    //for now only support choose one File/Folder
    NXFileBase *item = (NXFileBase *)choosedFiles.lastObject;
    
    NSInteger type = ((NSNumber *)(self.chooseType.allKeys.lastObject)).integerValue;
    //protect from repo
    if (type == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self showLocalProtect:item];
            [self showProtectSelectLocationFilesFromRepo:choosedFiles withCurrentFolder:_currentFolder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hiddenWaitingView:nil];
            });
        });
        return;
    }
    
    //share from repo
    if (type == 2) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showLocalShare:item];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hiddenWaitingView:nil];
            });
        });
        return;
    }
    if (type == NXContextMenuActionAddFileToProjectFromRepo) {
        NXFile *fileItem = choosedFiles.firstObject;
           WeakObj(self);
           if (fileItem) {
               [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                   StrongObj(self);
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [self hiddenWaitingView:nil];
                       if (!error) {
                           [self showPreviewToprojectPage:file];
                       }else{
                          [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                       }
                    });
               }];
           }
    }else if(type == NXContextMenuActionAddFileToWorkSpaceFromRepo){
        NXFile *fileItem = choosedFiles.firstObject;
        WeakObj(self);
        if (fileItem) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                StrongObj(self);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hiddenWaitingView:nil];
                    if (!error) {
                        [self showLocalUpload:file.localPath folder:(NXWorkSpaceFolder *)self.currentFolder];
                    }else{
                      [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                    }
                });
            }];
    
       }
    }else if(type == NXContextMenuActionAddNXLFileToOtherSpaceFromRepo){
        NXFile *fileItem = choosedFiles.firstObject;
        WeakObj(self);
        if (fileItem) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                StrongObj(self);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hiddenWaitingView:nil];
                    if (!error) {
                        if (self.currentMenuType == NXContextMenuTypeWorkSpaceAllTenantAdmin || self.currentMenuType == NXContextMenuTypeWorkSpaceAllUsual) {
                            NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
                            VC.isFromDefaultPath = YES;
                            VC.fileOperationType = NXFileOperationTypeAddNXLFileToWorkSpace;
                            VC.currentFile = fileItem;
                            VC.folder = self.currentFolder;
                            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self presentViewController:nav animated:YES completion:nil];
                        }else{
                            NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                            VC.currentFile = fileItem;
                            VC.fileOperationType = NXFileOperationTypeAddRepoProtectedFileToOther;
                            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self.navigationController presentViewController:nav animated:YES completion:nil];
                        }
                    }else{
                      [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                    }
                });
            }];
        
        
        }
    }else if (type == NXContextMenuActionAddNXLFileFromWorkSpace || type == NXContextMenuActionAddNXLFileFromRepo || type == NXContextMenuActionAddNXLFileFromProject || type == NXContextMenuActionAddNXLFileFromMySpace){
        NXFile *fileItem = choosedFiles.firstObject;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hiddenWaitingView:nil];
            if (self.currentMenuType == NXContextMenuTypeWorkSpaceAllTenantAdmin || self.currentMenuType == NXContextMenuTypeWorkSpaceAllUsual) {
                NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
                VC.isFromDefaultPath = YES;
                VC.fileOperationType = NXFileOperationTypeAddNXLFileToWorkSpace;
                VC.currentFile = fileItem;
                VC.folder = self.currentFolder;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }else if(self.currentMenuType == NXContextMenuTypeProjectByOthersFiles || self.currentMenuType == NXContextMenuTypeProjectByMeFiles){
                NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
                VC.isFromDefaultPath = YES;
                VC.fileOperationType = NXFileOperationTypeAddNXLFileToProject;
                VC.currentFile = fileItem;
                VC.folder = self.currentFolder;
                VC.toProject = self.currentProject;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:VC];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }else{
                NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                VC.currentFile = fileItem;
                if (type == NXContextMenuActionAddNXLFileFromProject) {
                    NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForFile:(NXProjectFile *)fileItem];
                    VC.fromProjectModel = projectModel;
                }else if (type == NXContextMenuActionAddNXLFileFromWorkSpace) {
                    VC.fileOperationType = NXFileOperationTypeAddWorkSPaceFileToOther;
                }else if(type == NXContextMenuActionAddNXLFileFromMySpace){
                    VC.fileOperationType = NXFileOperationTypeAddMyVaultFileToOther;
                }else if (type == NXContextMenuActionAddNXLFileFromRepo){
                    VC.fileOperationType = NXFileOperationTypeAddRepoProtectedFileToOther;
                }else if (type == NXContextMenuActionAddNXLFileFromRepo){
                    VC.fileOperationType = NXFileOperationTypeAddRepoProtectedFileToOther;
                }else{
                    VC.isLocalFile = YES;
                    VC.fileOperationType = NXFileOperationTypeAddLocalProtectedFileToOther;
                }
               
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }
            
        });
       
    }
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    [self hiddenWaitingView:nil];
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
     if ([viewController isKindOfClass:[AddSpaceViewController class]]) {
        [self addButtonClicked:nil];
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
#pragma mark ----> lcoalContactVC delegate
- (void)selectedEmail:(NSString *)emailStr {
    [self.memberView tempShow];
    [self.memberView.emailView addAEmail:emailStr];
}
- (void)cancelSelctedEmail {
    [self.memberView tempShow];
}
@end
