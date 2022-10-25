//
//  NXMyDriveFilesNavigatonVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 11/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXMyDriveFilesNavigatonVC.h"
#import "NXMyDriveFilesListVC.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
@interface NXMyDriveFilesNavigatonVC ()<UINavigationControllerDelegate>
@property(nonatomic ,strong)NXRepositoryModel *myDriveModel;
@end

@implementation NXMyDriveFilesNavigatonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.sortOption = NXSortOptionDateDescending;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToBoundServiceNotification) name:NOTIFICATION_REPO_UPDATED object:nil];
    [self responseToBoundServiceNotification];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}
- (void) pushViewController:(NXMyDriveFilesListVC *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"prePageIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    self.currentFolder = viewController.currentFolder;
    [super pushViewController:viewController animated:animated];
}

- (void)responseToBoundServiceNotification
{
    NSArray *repoArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
    for (NXRepositoryModel *repoModel in repoArray) {
        if (repoModel.service_type.integerValue == kServiceSkyDrmBox ) {
            self.myDriveModel = repoModel;
        }
    }
    
    //if repository is not sync or first launch app, we should get reposiory from server.
    if (!repoArray.count) {
        WeakObj(self);
        [NXMBManager showLoading];
        [[NXLoginUser sharedInstance].myRepoSystem syncRepositoryWithCompletion:^(NSArray *repoArray, NSTimeInterval syncTime, NSError *error) {
            StrongObj(self);
            dispatch_main_async_safe(^{
                [NXMBManager hideHUD];
                if (!error) {
                    [self responseToBoundServiceNotification];
                } else {
                    [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
                }
            });
            
        }];
        return;
    }
    
    if (self.myDriveModel) {
        NXMyDriveFilesListVC *repoFilesVC = [[NXMyDriveFilesListVC alloc] init];
        NXFileBase *rootFolder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:self.myDriveModel];
        rootFolder.isRoot = YES;
        repoFilesVC.currentFolder = rootFolder;
        self.currentFolder = rootFolder;
        [self pushViewController:repoFilesVC animated:NO];
    }
}

- (void) back {
    [self popViewControllerAnimated:YES];
    
    if ([self.viewControllers.lastObject isKindOfClass:[NXMyDriveFilesListVC class]]) {
        NXMyDriveFilesListVC *filesVC = (NXMyDriveFilesListVC *)self.viewControllers.lastObject;
        self.currentFolder = filesVC.currentFolder;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_REPO_UPDATED object:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull NXMyDriveFilesListVC *)viewController animated:(BOOL)animated {
    
    viewController.sortOption = self.sortOption;
    
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
