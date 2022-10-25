//
//  NXLoginNavigationController.m
//  nxrmc
//
//  Created by Kevin on 15/4/30.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXLoginNavigationController.h"

#import "NXLoginViewController.h"
#import "NXGuideViewControler.h"
#import "NXCommonUtils.h"

#import "NXKeyChain.h"

@interface NXLoginNavigationController ()<UINavigationControllerDelegate>

@end

@implementation NXLoginNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    NXGuideViewControler *vc = [[NXGuideViewControler alloc]init];
    self.viewControllers = [NSArray arrayWithObjects:vc, nil];
    
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                               NSForegroundColorAttributeName : [UIColor darkGrayColor]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    DLog();
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
