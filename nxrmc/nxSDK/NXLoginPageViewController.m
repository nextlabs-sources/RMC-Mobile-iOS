//
//  NXLoginPageViewController.m
//  nxSDK
//
//  Created by helpdesk on 6/9/16.
//  Copyright © 2016年 Eren. All rights reserved.
//

#import "NXLoginPageViewController.h"
#import <WebKit/WebKit.h>
#import "NXLClient.h"
#import "NXLProfile.h"
#import "NXLTenant.h"
#import "NXLCommonUtils.h"
#import "NXLClientSessionStorage.h"
#import "NXLRMSConfigViewController.h"
#import "NXLRouterLoginPageURL.h"


#define RMSSERVERADDRESS    @"https://r.skydrm.com"
#define LoginStr            @"Sign In"
#define ALERTVIEW_TITLE     @"SkyDRM"
#define RMCNXL_MAIN_COLOR   [UIColor colorWithRed:(57.0/255.0) green:(150.0/255.0) blue:(73.0/255.0) alpha:1.0]

#define kObserveName        @"observe"

static NSString * kJSHandler;

@interface NXLoginPageViewController ()<UIWebViewDelegate, NSURLSessionDataDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (retain, nonatomic) UIBarButtonItem *refreshBarButtonItem;
@property (retain, nonatomic) UIBarButtonItem *configRMSButtonItem;
@property (retain, nonatomic) WKWebView *wkWebView;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (retain, nonatomic) UIView *activityCoverView;
@property (nonatomic) BOOL barHidden;
@end

@implementation NXLoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commitInit];
    [self initActivityView];
    [self startAuthentication];
}

- (void)initActivityView {
    self.activityCoverView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = self.activityCoverView.center;
    [self.activityCoverView  addSubview:self.activityIndicatorView];
    [self.view addSubview:self.activityCoverView];
}

- (void)commitInit {
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = LoginStr ;
    
    UIBarButtonItem *rightRefreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshURL:)];
    rightRefreshButton.tintColor = RMCNXL_MAIN_COLOR;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightRefreshButton, nil];
    _refreshBarButtonItem = rightRefreshButton;
    
    UIBarButtonItem *leftRMSConfigButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelLogin:)];
    leftRMSConfigButton.tintColor = RMCNXL_MAIN_COLOR;
    self.navigationItem.leftBarButtonItem = leftRMSConfigButton;
//    _configRMSButtonItem = leftRMSConfigButton;
}



- (void)startAuthentication {
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:kObserveName];
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
    
    //step2.
    [self cleanWebViewCache];
    
    //step3.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityCharacter;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    [config.userContentController addScriptMessageHandler:self name:kObserveName];
    if (!kJSHandler) {
        kJSHandler = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ajax_handler" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSString *source = @"var s_ajaxListener = new Object();s_ajaxListener.tempOpen = XMLHttpRequest.prototype.open;XMLHttpRequest.prototype.open = function() {this.addEventListener('readystatechange', function() {var result = eval(\"(\" + this.responseText + \")\");alert('2');if(result.statusCode == 200 && result.message == \"Authorized\") {var temp = this.responseText;window.webkit.messageHandlers.observe.postMessage(temp);}}, false);s_ajaxListener.tempOpen.apply(this, arguments);}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController removeAllUserScripts];
    [config.userContentController addUserScript:userScript];
    WKWebView *wkView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:wkView];
    
    self.wkWebView = wkView;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.view bringSubviewToFront:self.activityCoverView];
    
    [self showActivityView];
    
    NXLRouterLoginPageURL * router = [[NXLRouterLoginPageURL alloc]initWithRequest:[NXLTenant currentTenant].tenantID];
    [router requestWithObject:nil Completion:^(id response, NSError *error) {
        NSLog(@"getLoginURL response: %@", response);
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXLCommonUtils showAlertViewInViewController:self title:ALERTVIEW_TITLE message:error.localizedDescription];
                [self hiddenActivityView];
            });
            
            return;
            
        } else {
            assert(response);
            NXLRouterLoginPageURLResponse *pageURLResonse = (NXLRouterLoginPageURLResponse *)response;
            if (pageURLResonse.rmsStatuCode != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXLCommonUtils showAlertViewInViewController:self title:ALERTVIEW_TITLE message:pageURLResonse.rmsStatuMessage];
                    [self hiddenActivityView];
                });
                
                return;
            } else {
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pageURLResonse.loginPageURLstr]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.wkWebView loadRequest:request];
                    NXLTenant *tenant = [[NXLTenant alloc]init];
                    [tenant setValue:pageURLResonse.loginPageURLstr forKey:@"rmsServerAddress"];
                    
                });
                
            }
        }
    }];
  }

- (void)cleanWebViewCache {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
}

- (void)refreshURL:(id)sender {
    [self startAuthentication];
}

- (void)cancelLogin:(id)sender {
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:kObserveName];
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
    
    [self dismissViewControllerAnimated:self.navigationController completion:^{
        if (self.completion) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorCanceled userInfo:nil];
            self.completion(nil,error);
        }
    }];
}
//#pragma mark ------》显示RMS
//- (void)configRMS:(id)sener
//{
//    NXLRMSConfigViewController *vc = [[NXLRMSConfigViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)showActivityView {
    self.activityCoverView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    self.refreshBarButtonItem.enabled = NO;
    self.wkWebView.userInteractionEnabled = NO;
}

- (void)hiddenActivityView {
    self.activityCoverView.hidden = YES;
    [self.activityIndicatorView stopAnimating];
    self.refreshBarButtonItem.enabled = YES;
    self.wkWebView.userInteractionEnabled = YES;
}
#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.wkWebView loadHTMLString:@"" baseURL:nil];
       
    [self parseLoginResult:message.body];
    
}
- (void)parseLoginResult:(NSString*)result {

    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NXLClient * client = [[NXLClient alloc]init];
    
    NSDictionary *userInfo = [ret objectForKey:@"extra"];
   
    NSString *tenantId = [userInfo objectForKey:@"tenantId"];
    
    NXLProfile *profile = [[NXLProfile alloc] init];
    
    
    NSMutableArray *memberships = [[NSMutableArray alloc]init];
    [[userInfo objectForKey:@"memberships"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXLMembership *membership = [[NXLMembership alloc] init];
        membership.ID = [obj objectForKey:@"id"];
        membership.type = [obj objectForKey:@"type"];
        membership.tenantId = [obj objectForKey:@"tenantId"];
        if ([membership.tenantId isEqualToString:tenantId]) {
            profile.defaultMembership = membership;
        }
        [memberships addObject:membership];
    }];

  
    profile.memberships = memberships;
    
    NSNumber *userid = [userInfo objectForKey:@"userId"];
    profile.userId = [NSString stringWithFormat:@"%ld", userid.longValue];
    
    profile.userName = [userInfo objectForKey:@"name"];
    profile.ticket = [userInfo objectForKey:@"ticket"];
    profile.ttl = [userInfo objectForKey:@"ttl"];
    profile.email = [userInfo objectForKey:@"email"];
    profile.rmserver = [NXLTenant currentTenant].rmsServerAddress;
        [client setValue:profile forKey:@"profile"];
//    [client setProfile:profile];
    NXLTenant * currentTenant =[NXLTenant currentTenant];
    [client setValue:currentTenant forKey:@"userTenant"];
    [client setValue:profile.userId forKey:@"userID"];
    [[NXLClientSessionStorage sharedInstance] storeClient:client];
    
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:kObserveName];
    [self dismissViewControllerAnimated:self.navigationController completion:^{
        if (self.completion) {
            self.completion(client,nil);
        }
    }];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hiddenActivityView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; //otherwise top of website is sometimes hidden under Navigation Bar
    
    [webView.scrollView zoomToRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height) animated:YES];
    
    [self hiddenActivityView];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // [self showActivityView];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {    decisionHandler(WKNavigationActionPolicyAllow);
    if ([navigationAction.request.URL.absoluteString containsString:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    }
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    //    [NXCommonUtils showAlertViewInViewController:self title:NSLocalizedString(@"ALERTVIEW_TITLE", NULL) message:message];
   
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    //TBD
    completionHandler(nil);
}
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
