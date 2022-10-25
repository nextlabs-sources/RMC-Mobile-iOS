//
//  NXWorkSpaceFileNavVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceFileNavVC.h"
#import "NXWorkSpaceTableViewController.h"
#import "NXSortView.h"
#import "NXWorkSpaceItem.h"
#import "UIImage+ColorToImage.h"
@interface NXWorkSpaceFileNavVC ()<NXSortViewDelegate, UINavigationControllerDelegate>

@end

@implementation NXWorkSpaceFileNavVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
    self.delegate = self;
    // Do any additional setup after loading the view.
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    
    if ([self.viewControllers.lastObject isKindOfClass:[NXWorkSpaceTableViewController class]]) {
        NXWorkSpaceTableViewController *vc = self.viewControllers.lastObject;
        self.currentFolder = vc.currentFolder;
    };
    return viewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[NXWorkSpaceTableViewController class]]) {
        NXWorkSpaceTableViewController *filesVC = (NXWorkSpaceTableViewController *)viewController;
        self.currentFolder = filesVC.currentFolder;
    }
    [super pushViewController:viewController animated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull NXWorkSpaceTableViewController *)viewController animated:(BOOL)animated {
    viewController.sortOption = self.sortOption;
   
}
@end
