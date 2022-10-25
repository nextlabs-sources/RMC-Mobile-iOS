//
//  NXURLViewController.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/22/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXURLViewController.h"

#import "Masonry.h"
#import "UIImage+ColorToImage.h"
#import "NXMBManager.h"
@interface NXURLViewController ()<WKNavigationDelegate, WKUIDelegate>

@property(nonatomic, strong) UIProgressView *progressView;

@end

@implementation NXURLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    [_wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_wkWebView stopLoading];
    _wkWebView.UIDelegate = nil;
    _wkWebView.navigationDelegate = nil;
}

#pragma mark
- (void)setUrl:(NSURL *)url {
    _url = url;
    [_wkWebView loadRequest:[NSURLRequest requestWithURL:_url]];
    self.progressView.hidden = NO;
}

#pragma mark
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = [change[@"new"] floatValue];
        if (self.progressView.progress == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
            });
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    self.progressView.progress = 0;
    self.progressView.hidden = NO;
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (error && error.code != NSURLErrorCancelled) {
        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {  NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        
          }
}
#pragma mark
- (void)commonInit {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    config.preferences = [[WKPreferences alloc]init];
    config.userContentController = [[WKUserContentController alloc]init];
    
    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero];
    
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    
    _wkWebView.allowsBackForwardNavigationGestures = YES;
    
    [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.view addSubview:_wkWebView];
    [_wkWebView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    [_wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    progressView.trackImage = [UIImage imageWithColor:[UIColor whiteColor]];
    progressView.progressImage = [UIImage imageWithColor:RMC_MAIN_COLOR];
    
    [self.view addSubview:progressView];
    
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@2);
    }];
    
    self.progressView = progressView;
}
@end
