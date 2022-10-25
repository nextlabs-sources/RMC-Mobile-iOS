//
//  NXFilesNavigationVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 8/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXFilesNavigationVC.h"
#import  "UIImage+ColorToImage.h"
@interface NXFilesNavigationVC ()

@end

@implementation NXFilesNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
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
