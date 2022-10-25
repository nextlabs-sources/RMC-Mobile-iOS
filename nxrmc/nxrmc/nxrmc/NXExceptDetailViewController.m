//
//  NXExceptDetailViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 17/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXExceptDetailViewController.h"
#import <WebKit/WebKit.h>

@interface NXExceptDetailViewController ()

@end

@implementation NXExceptDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *exceptPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Exception"];
    NSString *filePath = [exceptPath stringByAppendingPathComponent:self.fileName];
    WKWebView *exceptView = [[WKWebView alloc] init];
    exceptView.frame = self.view.frame;
    [self.view addSubview:exceptView];
    [self.view bringSubviewToFront:exceptView];
    [exceptView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
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
