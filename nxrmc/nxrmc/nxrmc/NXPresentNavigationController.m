//
//  NXPresentNavigationController.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPresentNavigationController.h"

@interface NXPresentNavigationController ()

@end

@implementation NXPresentNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.tintColor = [UIColor blackColor]; //Set TintColor be Default color.
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:14]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark override

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        return [super popViewControllerAnimated:animated];
    }
    return nil;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
}

@end
