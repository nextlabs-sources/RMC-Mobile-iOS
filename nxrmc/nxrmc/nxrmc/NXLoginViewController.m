//
//  NXLoginViewController.m
//  nxrmc
//
//  Created by nextlabs on 3/31/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLoginViewController.h"
#import "NXRMSConfigViewController.h"
#import <WebKit/WebKit.h>

#import "NXMBManager.h"

#import "NXRMCDef.h"
#import "UIImage+Cutting.h"
#import "NXCommonUtils.h"
#import "NXRouterLoginPageURL.h"
#import "NXLProfile.h"
#import "NXRegistNewUserViewController.h"
#import "NXGetTenantPreferenceAPI.h"
#import "NXGetProjectAdminAPI.h"
#import "NXPrimaryNavigationController.h"

static NSString *kJSHandler;

@interface NXLoginViewController ()< NSURLSessionDataDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) WKWebView *wkWebView;
@property (weak, nonatomic) UIView *activityCoverView;
@property (weak, nonatomic) UIBarButtonItem *refreshBarButtonItem;

@end

@implementation NXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateScreenLogin) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)rotateScreenLogin {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.wkWebView.scrollView setZoomScale:0.5 animated:NO];
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    DLog();
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
      [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startAuthentication];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 

- (void)commonInit {
    self.navigationItem.title = NSLocalizedString(@"UI_SIGNIN", NULL);
    
    UIBarButtonItem *rightRefreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshURL:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightRefreshButton, nil];
    _refreshBarButtonItem = rightRefreshButton;
    UIBarButtonItem *leftRMSConfigButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(configRMS:)];
    self.navigationItem.leftBarButtonItem = leftRMSConfigButton;
}

#pragma mark - target-action method

- (void)refreshURL:(id)sender {
    [self startAuthentication];
}

- (void)configRMS:(id)sener
{
    if (self.wkWebView.backForwardList.backItem) {
        [self.wkWebView goToBackForwardListItem:self.wkWebView.backForwardList.backItem];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
            }
}

#pragma mark - private method.

- (void)cleanWebViewCache {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
}

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

- (void)startAuthentication {
    //every time create a new WKWebview when loading login html page, the reason is we must delete cookies. for iOS8, we can not remove cookies directly. so we just follow three steps, 1, remove WKWebView, 2, delete cookies, 3,add new WKWebView, only this can delete cookies in iOS 8.
    //step 1.
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"observe"];
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
    
    //step2.
    [self cleanWebViewCache];

    //step3.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityCharacter;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    [config.userContentController addScriptMessageHandler:self name:@"observe"];
    if (!kJSHandler) {
        kJSHandler = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ajax_handler" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
    }
    
    WKUserScript *userScript = [[WKUserScript alloc]initWithSource:kJSHandler injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController addUserScript:userScript];
//   NSString *cookieJS = [[NSString alloc] initWithFormat:@"document.cookie ='clientId=%@';document.cookie ='platformId=%@';", [NXCommonUtils deviceID], [NXCommonUtils getPlatformId].stringValue];
    NSString *cookieJS = [[NSString alloc] initWithFormat:@"document.cookie ='clientId=%@;Path=/;';document.cookie ='platformId=%@;Path=/;';", [NXCommonUtils deviceID], [NXCommonUtils getPlatformId].stringValue];
    
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:cookieJS  injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController addUserScript:cookieScript];
    
    WKWebView *wkView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    wkView.allowsBackForwardNavigationGestures = YES;
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
    NSString *loginURL;
    loginURL = [NXCommonUtils getRmServer];
    if (loginURL) {
        NSString *specificTenant = [[NSUserDefaults standardUserDefaults] objectForKey:SPECIFIC_TENANT];
        if (specificTenant.length == 0) {
            loginURL = [NSString stringWithFormat:@"%@/login",loginURL];
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.wkWebView.customUserAgent = @"skyDRM";
//            self.wkWebView.customUserAgent = @"Chrome/72.0.3626.121 Safari/537.36";
            // 注意这个方法是异步的
            [self.wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
                DLog(@"userAgent :%@", result);
                // userAgent :Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Mobile/14C89
            }];
            
            [self.wkWebView loadRequest:request];
        });
    }
}

- (void)parseLoginResult:(NSString *)result {
    if (!result) {
        [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName]  message:@"message"];
        return;
    }
    NSError *error = nil;
    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        [NXMBManager showMessage:NSLocalizedString(@"format is not json", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSDictionary *userInfo = [ret objectForKey:@"extra"];
    [[NXLoginUser sharedInstance] loginWithUserinfo:userInfo];
    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
        NXGetTenantPreferenceAPIRequest *tenantPrefenceRequest = [[NXGetTenantPreferenceAPIRequest alloc]init];
        [tenantPrefenceRequest requestWithObject:[NXLoginUser sharedInstance].profile.defaultTenantID Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            if (!error) {
                NXGetTenantPreferenceAPIResponse *tenantResponse = (NXGetTenantPreferenceAPIResponse *)response;
                if (tenantResponse.perenceDic) {
                    [[NXLoginUser sharedInstance] updateTenantPrefence:tenantResponse.perenceDic];
                }
            }
            dispatch_semaphore_signal(sema);
        }];
    }else{
        dispatch_semaphore_signal(sema);
    }
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NXGetProjectAdminAPIRequest *getProjectAdminRequest = [[NXGetProjectAdminAPIRequest alloc] init];
    [getProjectAdminRequest requestWithObject:[NXLoginUser sharedInstance].profile.defaultTenantID Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXGetProjectAdminAPIResponse *projectAdminResponse = (NXGetProjectAdminAPIResponse *)response;
            long role = NXL_USER_ROLE_NORMAL;
            if (projectAdminResponse.tenantAdminArr.count >0 && [NXLoginUser sharedInstance].profile.email) {
                if ([projectAdminResponse.tenantAdminArr containsObject: [[NXLoginUser sharedInstance].profile.email lowercaseString]]){
                    role = role | NXL_USER_ROLE_TENANT_ADMIN;
                }
            }
            
            if (projectAdminResponse.projectAdminArr.count > 0 &&[NXLoginUser sharedInstance].profile.email)  {
                if ([projectAdminResponse.projectAdminArr containsObject:[[NXLoginUser sharedInstance].profile.email lowercaseString]]){
                    role = role | NXL_USER_ROLE_PROJECT_ADMIN;
                }
            }
            [[NXLoginUser sharedInstance] updateUserRole:[NSNumber numberWithLong:role]];
        }else{
            long role = NXL_USER_ROLE_NORMAL;
            [[NXLoginUser sharedInstance] updateUserRole:[NSNumber numberWithLong:role]];
        }
    }];
    NXPrimaryNavigationController *primaryNavigationController = [[NXPrimaryNavigationController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = primaryNavigationController;
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"observe"];
    
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SKYDRM_LOGIN_SUCCESS object:nil];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.wkWebView loadHTMLString:@"" baseURL:nil];
    [self parseLoginResult:message.body];

}

#pragma mark - WKNavigationDelegate
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"Processing");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; //otherwise top of website is sometimes hidden under Navigation Bar
    
    [webView.scrollView zoomToRect:CGRectMake(0, 0, KScreenWidth, KScreenHeight) animated:YES];
    
     [self hiddenActivityView];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // [self showActivityView];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString containsString:@"mailto"]) {
        
        decisionHandler(WKNavigationActionPolicyAllow);
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        return;
    }else if([navigationAction.request.URL.absoluteString containsString:@"register?tenant="]){
        decisionHandler(WKNavigationActionPolicyCancel);
        NXRegistNewUserViewController *registNewUserVC = [[NXRegistNewUserViewController alloc] init];
        [self.navigationController pushViewController:registNewUserVC animated:YES];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    //TBD
    completionHandler(nil);
}
- ( WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
//    [[UIApplication sharedApplication] openURL:options:completionHandler::navigationAction.request.URL];
    [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
    return nil;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSURLCredential * credential = [[NSURLCredential alloc] initWithTrust:[challenge protectionSpace].serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

@end
