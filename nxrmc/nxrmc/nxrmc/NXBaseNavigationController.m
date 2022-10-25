//
//  NXBaseNavigationController.m
//  nxrmc
//
//  Created by nextlabs on 2/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXBaseNavigationController.h"
#import "UIImage+ColorToImage.h"

@interface NXBaseNavigationController ()

@end

@implementation NXBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
    self.modalPresentationStyle = UIModalPresentationFullScreen;
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
