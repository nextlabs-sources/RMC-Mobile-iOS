//
//  NXHomeNavigationVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXHomeNavigationVC.h"
#import "UIImage+ColorToImage.h"

#import "NXMySpaceHomeVC.h"
#import "NXAllProjectsViewController.h"
#import "NXProjectFilesVC.h"
@interface NXHomeNavigationVC ()<UINavigationControllerDelegate>

@end

@implementation NXHomeNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showDefaultNavigationBar];
    
    self.delegate = self;
}
- (void)showNormalNavigationBar{
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//    self.navigationBar.translucent = YES;
    
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
    self.delegate = self;
}
- (void)showDefaultNavigationBar {
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:RMC_MAIN_COLOR] forBarMetrics:UIBarMetricsDefault];
//    self.navigationBar.translucent = YES;
    
    self.navigationBar.backgroundColor = RMC_MAIN_COLOR;
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
    
    self.delegate = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark
//- (void)back:(id)sender {
//    [self popViewControllerAnimated:YES];
//}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[NXProjectFilesVC class]]) {
        [self showNormalNavigationBar];
    } else {
        [self showDefaultNavigationBar];
    }
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
