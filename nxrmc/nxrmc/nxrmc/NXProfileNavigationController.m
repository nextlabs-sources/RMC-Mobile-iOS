//
//  NXProfileNavigationController.m
//  nxrmc
//
//  Created by nextlabs on 11/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXProfileNavigationController.h"

#import "NXProfileViewController.h"
#import "NXAccountViewController.h"
#import "NXAddRepositoryViewController.h"
#import "NXRepositoryViewController.h"

#import "UIImage+ColorToImage.h"
#import "NXRMCDef.h"

@interface NXProfileNavigationController ()<UINavigationControllerDelegate>

@end

@implementation NXProfileNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.translucent = YES;
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:RMC_MAIN_COLOR] forBarMetrics:UIBarMetricsDefault];

    self.navigationBar.backgroundColor = RMC_MAIN_COLOR;
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DLog();
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    UIView * tabBarView = [self.tabBarController.view viewWithTag:TABBAR_VIEW_TAG];
//    if ([viewController isKindOfClass:[NXProfileViewController class]]) {
//        [navigationController.navigationBar setHidden:YES];
//        tabBarView.hidden = NO;
//    } else {
//        [navigationController.navigationBar setHidden:NO];
//        tabBarView.hidden = YES;
//    }
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
//    if ([viewController isKindOfClass:[NXAccountViewController class]] ||
//        [viewController isKindOfClass:[NXProfileViewController class]]) {
//        [self.navigationBar setBackgroundImage:[UIImage imageWithColor:RMC_MAIN_COLOR] forBarMetrics:UIBarMetricsDefault];
//    }
//    else {
//        [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
//    }
}

#pragma mark
- (void)backButtonClicked:(id)sender {
    [self popViewControllerAnimated:YES];
}

@end
