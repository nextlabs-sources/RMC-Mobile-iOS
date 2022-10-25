//
//  NXRepoFilesNavigationController.m
//  nxrmc
//
//  Created by nextlabs on 2/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepoFilesNavigationController.h"

#import "NXRepoFilesViewController.h"
#import "Masonry.h"
#import "NXMBManager.h"

#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#define kNoSelectedRepoViewTag 3334

@interface NXRepoFilesNavigationController ()<UINavigationControllerDelegate>

//@property(nonatomic, assign) NSInteger currentVCIndex;
@property(nonatomic, assign) NXSortOption firstOption;
@property(nonatomic, strong) NSArray *rootSortByTypes;
@property(nonatomic, strong) NSArray *subVCSortByTypes;
@end

@implementation NXRepoFilesNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
//    self.currentVCIndex = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToBoundServiceOpt) name:NOTIFICATION_REPO_UPDATED object:nil];
    [self responseToBoundServiceOpt];
    self.rootSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.subVCSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    self.allSortByTypes = self.rootSortByTypes;
    self.sortOption = NXSortOptionDateDescending;
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"prePageIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    if ([viewController isKindOfClass:[NXRepoFilesViewController class]]) {
        NXRepoFilesViewController *filesVC = (NXRepoFilesViewController *)viewController;
        self.currentFolder = filesVC.currentFolder;
    }
    [super pushViewController:viewController animated:animated];
}
- (void) back {
    [self popViewControllerAnimated:YES];

    if ([self.viewControllers.lastObject isKindOfClass:[NXRepoFilesViewController class]]) {
        NXRepoFilesViewController *filesVC = (NXRepoFilesViewController *)self.viewControllers.lastObject;
        self.currentFolder = filesVC.currentFolder;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_REPO_UPDATED object:nil];
}


#pragma mark
- (void)responseToBoundServiceOpt {
    NXRepoFilesViewController *repoFilesVC = [[NXRepoFilesViewController alloc] init];
    repoFilesVC.currentFolder = self.currentFolder;
    repoFilesVC.isOnlyNxlFile = self.isOnlyNxlFile;
    [self pushViewController:repoFilesVC animated:NO];
   
}

#pragma mark
- (void)showNoSelectRepoView {
    if ([self.view viewWithTag:kNoSelectedRepoViewTag]) {
        return;
    }
    
    UILabel *noSelRepoLab = [[UILabel alloc] init];
    noSelRepoLab.translatesAutoresizingMaskIntoConstraints = NO;
    [noSelRepoLab setText:NSLocalizedString(@"UI_NO_REPO_SELECTED", NULL)];
    [noSelRepoLab setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:15.0]];
    noSelRepoLab.numberOfLines = 0;
    noSelRepoLab.textAlignment = NSTextAlignmentCenter;
    noSelRepoLab.textColor = [UIColor colorWithRed:0.76 green:0.76 blue:0.79 alpha:1.0];
    [self.view addSubview:noSelRepoLab];
    noSelRepoLab.tag = kNoSelectedRepoViewTag;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:noSelRepoLab attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:noSelRepoLab attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
//    [self.sortView removeFromSuperview];
}

- (void)removeNoSelectedRepoView {
    // remove no repo view
    [[self.view viewWithTag:kNoSelectedRepoViewTag] removeFromSuperview];
    
 }

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull NXRepoFilesViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewControllers.count == 1) {
        self.allSortByTypes = self.rootSortByTypes;
        if (self.sortOption == NXSortOptionNameAscending && self.firstOption == NXSortOptionDriveAscending) {
            viewController.sortOption = self.firstOption;
        }else{
            viewController.sortOption = self.sortOption;
        }
    }else {
        self.allSortByTypes = self.subVCSortByTypes;
        if (self.sortOption == NXSortOptionDriveAscending ||self.sortOption == NXSortOptionDriveDescending) {
            self.firstOption = self.sortOption;
            self.sortOption = NXSortOptionNameAscending;
            viewController.sortOption = self.sortOption;
        }else {
            viewController.sortOption = self.sortOption;
        }
    }
}

@end
