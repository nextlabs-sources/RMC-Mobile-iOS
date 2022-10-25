//
//  NXOpenSourceLicensesViewController.m
//  nxrmc
//
//  Created by Sznag on 2020/12/14.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOpenSourceLicensesViewController.h"
#import <WebKit/WebKit.h>
#import "Masonry.h"
@interface NXOpenSourceLicensesViewController ()

@end

@implementation NXOpenSourceLicensesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.title = @"Licenses of Open Source Used";
   WKWebView *fileContentWebView = [[WKWebView alloc] init];
    fileContentWebView.configuration.dataDetectorTypes =  UIDataDetectorTypeNone;
    fileContentWebView.contentMode = UIViewContentModeCenter;
    fileContentWebView.opaque = NO;
    fileContentWebView.backgroundColor = [UIColor whiteColor];
    fileContentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:fileContentWebView];
         
    fileContentWebView.scrollView.maximumZoomScale = 20;
    fileContentWebView.scrollView.minimumZoomScale = 0.1;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"open source licenses" ofType:@"txt"];
    NSURL *accessUrl = [NSURL fileURLWithPath:filePath];
    [fileContentWebView loadFileURL:accessUrl allowingReadAccessToURL:[accessUrl URLByDeletingLastPathComponent]];
    [fileContentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.bottom.equalTo(self.view);
            // Fallback on earlier versions
        }
        make.left.right.equalTo(self.view);
    }];
    

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
