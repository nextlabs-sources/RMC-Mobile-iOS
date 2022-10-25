//
//  NXBaseViewController.m
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXBaseViewController.h"

#import "Masonry.h"

@interface NXBaseViewController ()

@end

@implementation NXBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *topBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    [self.view addSubview:topBackgroundView];
    
    [topBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@(24));
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];
    _topBackgroundView = topBackgroundView;
    topBackgroundView.backgroundColor = RMC_MAIN_COLOR;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topBackgroundView.backgroundColor = self.navigationController.navigationBar.backgroundColor;
}
@end
