//
//  NXRegistNewUserViewController.m
//  nxrmc
//
//  Created by EShi on 3/21/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRegistNewUserViewController.h"
#import "NXRouterLoginPageURL.h"
#import "NXMBManager.h"
#import <WebKit/WebKit.h>
@interface NXRegistNewUserViewController ()<WKNavigationDelegate, WKUIDelegate>
@property (retain, nonatomic) WKWebView *wkWebView;
@end

@implementation NXRegistNewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    WKWebView *wkView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    wkView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:wkView];
    self.wkWebView = wkView;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    
    [self commonInit];
}

- (void)commonInit
{
    self.navigationItem.title = NSLocalizedString(@"UI_SIGNUP", NULL);
    UIBarButtonItem *leftRMSConfigButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelRegist:)];
    self.navigationItem.leftBarButtonItem = leftRMSConfigButton;
}

- (void)cancelRegist:(UIBarButtonItem *)buttonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NXMBManager showLoadingToView:self.view];
    NSString *loginURL;
    loginURL = [NXCommonUtils getRmServer];
    if (loginURL) {
//        NSString *registStr = [NSString stringWithFormat:@"%@/%@%@", [NXCommonUtils currentRMSAddress], @"Register.jsp?tenant=", [NXCommonUtils currentTenant]];
        NSString *registStr = [NSString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"register"];
        NSString *aUrlStr = [registStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aUrlStr]];
            [self.wkWebView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
    if ([navigationAction.request.URL.absoluteString localizedCaseInsensitiveContainsString:@"Intro?"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }if ([navigationAction.request.URL.absoluteString localizedCaseInsensitiveContainsString:@"Intro.jsp?"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([navigationAction.request.URL.absoluteString containsString:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
    }else if([navigationAction.request.URL.absoluteString localizedCaseInsensitiveContainsString:@"login?"]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; //otherwise top of website is sometimes hidden under Navigation Bar
    [webView.scrollView zoomToRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height) animated:YES];
    [NXMBManager hideHUDForView:self.view];
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSURLCredential * credential = [[NSURLCredential alloc] initWithTrust:[challenge protectionSpace].serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}
#pragma mark - WKUIDelegate
- ( WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
    return nil;
}

@end
