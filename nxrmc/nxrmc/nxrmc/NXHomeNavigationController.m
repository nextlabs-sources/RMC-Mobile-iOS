//
//  NXHomeNavigationController.m
//  nxrmc
//
//  Created by nextlabs on 12/5/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXHomeNavigationController.h"

#import "UIImage+ColorToImage.h"

@interface NXHomeNavigationController ()

@end

@implementation NXHomeNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:RMC_MAIN_COLOR] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    
    self.navigationBar.backgroundColor = RMC_MAIN_COLOR;
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
