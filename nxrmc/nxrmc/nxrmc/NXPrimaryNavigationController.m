//
//  NXPrimaryNavigationController.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPrimaryNavigationController.h"
#import "NXMasterTabBarViewController.h"
#import "AppDelegate.h"
@interface NXPrimaryNavigationController ()

@end

@implementation NXPrimaryNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    NXMasterTabBarViewController *vc = [[NXMasterTabBarViewController alloc]init];
    self.viewControllers = [NSArray arrayWithObjects:vc, nil];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).primaryNavigationController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    }
    self.interactivePopGestureRecognizer.delegate = nil;
    [super pushViewController:viewController animated:animated];
}

#pragma mark
- (void)back:(id)sender {
    [self popViewControllerAnimated:YES];
}

@end
