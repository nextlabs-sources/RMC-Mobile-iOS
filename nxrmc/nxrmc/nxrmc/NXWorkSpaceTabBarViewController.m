//
//  NXWorkSpaceTabBarViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/10/15.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceTabBarViewController.h"
#import "NXWorkSpaceVC.h"
#import "NXWorkSpaceNavigationVC.h"
#import "NXProjectHomeVC.h"
#import "NXWorkSpaceItem.h"
#import "NXLoginUser.h"
#import "NXContextMenu.h"
#import "NXPhotoSelector.h"
#import "NXWorkSpaceUploadFileVC.h"
#import "NXPresentNavigationController.h"
#import "NXFileChooseFlowViewController.h"
#import "NXNewFolderViewController.h"
#import "NXMBManager.h"
#import "AppDelegate.h"
#import "NXCommonUtils.h"
#import "NXOriginalFilesTransfer.h"
@interface NXAddViewController : UIViewController
@end

@implementation NXAddViewController
@end
@interface NXWorkSpaceTabBarViewController ()<NXFileChooseFlowViewControllerDelegate,UITabBarControllerDelegate>
@property(nonatomic, strong) NXContextMenu *contextMenu;
@property(nonatomic, strong) NXPhotoSelector *photoSelector;
@property(nonatomic, strong) NXFileBase *currentFolder;
@end

@implementation NXWorkSpaceTabBarViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NXProjectHomeVC *vc = [[NXProjectHomeVC alloc] init];
    NXWorkSpaceVC *workSpaceVC = [[NXWorkSpaceVC alloc]init];
    NXWorkSpaceNavigationVC *workSpaceNav = [[NXWorkSpaceNavigationVC alloc]initWithRootViewController:workSpaceVC];
    NXAddViewController *addVC = [[NXAddViewController alloc] init];
    
    [self setViewControllers:@[vc,workSpaceNav,addVC]];
          
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
    
    UITabBarItem *itemWorkSpace = [tabBar.items objectAtIndex:1];
    itemWorkSpace.title = NSLocalizedString(@"UI_WORKSPACE_ITEM", NULL);
    itemWorkSpace.image = [[UIImage imageNamed:@"Black-workspace-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    itemWorkSpace.selectedImage = [UIImage imageNamed:@"Green-workSpace-icon"];
    UITabBarItem *itemMore = [tabBar.items objectAtIndex:2];
    itemMore.image = [[UIImage imageNamed:@"Add Utility"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if ([NXCommonUtils isiPad]) {
        [itemMore setImageInsets:UIEdgeInsetsMake(6, -8, -3, 8)];
    }else{
        [itemMore setImageInsets:UIEdgeInsetsMake(6, -8, -6, 8)];
    }
    itemMore.accessibilityValue = @"WORKSPACE_ADD_MORE_TAB";
   
    self.tabBar.backgroundImage = [[UIImage alloc] init];
    self.tabBar.backgroundColor = [UIColor whiteColor];
   
    self.tabBar.shadowImage = [[UIImage alloc] init];
    self.tabBar.layer.shadowOffset = CGSizeMake(0, 5);
    self.tabBar.layer.shadowOpacity = 0.9;
    self.tabBar.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.tabBar.layer.shadowRadius = 10;
    
    self.delegate = self;
}
#pragma mark
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if ([[self.viewControllers objectAtIndex:selectedIndex] isKindOfClass:[NXAddViewController class]]) {
        NSLog(@"%s", __FUNCTION__);
        return;
    }
    [super setSelectedIndex:selectedIndex];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    if ([selectedViewController isKindOfClass:[NXAddViewController class]]) {
        NSLog(@"%s", __FUNCTION__);
        return;
    }
    
    if ([selectedViewController isKindOfClass:[NXProjectHomeVC class]]) {
        [self dismiss];
        return;
    }
    [super setSelectedViewController:selectedViewController];
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[NXAddViewController class]]) {
        [self addButtonClicked:nil];
        return NO;
    }
    if ([viewController isKindOfClass:[NXProjectHomeVC class]]) {
        UITabBarController *rootVC = tabBarController.navigationController.viewControllers.firstObject;
        [tabBarController.navigationController popToRootViewControllerAnimated:YES];
        [rootVC setSelectedIndex:kNXMasterTabBarControllerIndexHome];
        return NO;
    }
    return YES;
}

- (void)dismiss {
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)addButtonClicked:(id)sender {
   NXWorkSpaceFolder *folder = [[NXLoginUser sharedInstance].workSpaceManager rootFolderForWorkSpace];
    if (self.selectedIndex == 1) {
        NXWorkSpaceNavigationVC *filesNav = (NXWorkSpaceNavigationVC*)[self selectedViewController];;
        NXWorkSpaceVC *filesVC = filesNav.viewControllers.firstObject;
        folder = filesVC.fileNavVC.currentFolder;
    }

    NXContextMenuType type = NXContextMenuTypeWorkSpaceHome;
    switch (self.selectedIndex) {
        case 1:
        {
            if ([[NXLoginUser sharedInstance] isTenantAdmin]) {
                type = NXContextMenuTypeWorkSpaceAllTenantAdmin;
            }else{
                type = NXContextMenuTypeWorkSpaceAllUsual;
            }
            
        }
            break;
        default:
            break;
    }
    WeakObj(self);
    _contextMenu = [NXContextMenu showType:type withHandler:^(NXContextMenuHandler *handler) {
        StrongObj(self);
        [self operation:folder handler:handler];
    }];
    return;
}

- (void)operation:(NXWorkSpaceFolder *)currentFolder handler:(NXContextMenuHandler *)handle {
    self.currentFolder = currentFolder;
    switch (handle.action) {
        case NXContextMenuActionAddFileToWorkSpaceFromLocal:
        {
            [self addLocalFileToWorkSpace:currentFolder];
        }
            break;
        case NXContextMenuActionAddFileFromRepo:
        {
            [self addFileToWorkSpaceToWorkSpaceFromRepo:handle.data];
        }
            break;
        case NXContextMenuActionCreateFolder:
        {
            [self createNewFolderForWorSpace:currentFolder];
        }
            break;
        case NXContextMenuActionScanDocument:
        {
            [self scanDocument:currentFolder];
        }
            break;
        default:
            break;
    }
}
#pragma mark - action
- (void)addLocalFileToWorkSpace:(NXWorkSpaceFolder *)folder {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypePhotoLibrary complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                [self showLocalUpload:localPath folder:folder];
            });
        }
    }];
}

- (void)addFileToWorkSpaceToWorkSpaceFromRepo:(NXRepositoryModel *)repositoryModel{
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
//scan a document action
- (void)scanDocument:(NXWorkSpaceFolder *)folder {
    NXPhotoSelector *selecter = [[NXPhotoSelector alloc] initWithSelectedType:NXPhotoSelectorTypeSingleSelect];
    self.photoSelector = selecter;
    WeakObj(self);
    [selecter showPhotoPicker:NXPhotoSelectTypeCamera complete:^(NSArray *selectedItems, BOOL authen) {
        if (selectedItems.count != 0) {
            StrongObj(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *localPath = selectedItems.lastObject;
                NXFile *file = [[NXFile alloc] init];
                file.localPath = localPath;
                file.name = localPath.lastPathComponent;
                file.isRoot = NO;
                file.sorceType = NXFileBaseSorceTypeLocal;
                [self showLocalUpload:localPath folder:folder];
            });
        }
    }];
}
- (void)showLocalUpload:(NSString *)localPath folder:(NXWorkSpaceFolder *)folder {
    NXFile *file = [[NXFile alloc] init];
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
#pragma mark -NXFileChooseFlowViewControllerDelegate

- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles
{
    NXFile *fileItem = choosedFiles.firstObject;
    WeakObj(self);
    if (fileItem) {
        [self showWaitingView];
        [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
            StrongObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hiddenWaitingView:nil];
                NXWorkSpaceUploadFileVC *vc = [[NXWorkSpaceUploadFileVC alloc] init];
                vc.fileItem = file;
                vc.folder = (NXWorkSpaceFolder *)self.currentFolder;
                NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            });
        }];
    }
}

- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc
{
    //do nothing
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
