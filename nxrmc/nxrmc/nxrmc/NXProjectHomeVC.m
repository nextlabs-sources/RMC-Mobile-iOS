//
//  NXProjectHomeVC.m
//  Demo
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 Bill (Guobin) Zhang. All rights reserved.
//

#import "NXProjectHomeVC.h"

@interface NXProjectHomeVC ()

@end

@implementation NXProjectHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 300, 70, 70)];
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark
- (void)click:(id)sender {
    [self.tabBarController setSelectedIndex:4];
}

- (void)tabbarAdditemClicked {
    
}


@end
