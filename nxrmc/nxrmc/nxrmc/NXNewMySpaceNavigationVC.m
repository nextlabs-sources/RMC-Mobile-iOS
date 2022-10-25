//
//  NXNewMySpaceNavigationVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/5.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXNewMySpaceNavigationVC.h"
#import  "UIImage+ColorToImage.h"

@interface NXNewMySpaceNavigationVC ()

@end

@implementation NXNewMySpaceNavigationVC

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
