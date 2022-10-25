//
//  NXNormalRenderer.m
//  nxrmc
//
//  Created by nextlabs on 10/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXNormalRenderer.h"
#import "NXCommonUtils.h"

#import "Masonry.h"
#import <WebKit/WebKit.h>


#define OfficeMIMETYPE  @"application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.openxmlformats-officedocument.presentationml.presentation, application/vnd.ms-powerpoint"



@interface NXNormalRenderer()<WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *fileContentWebView;
@property(nonatomic, strong, readwrite) NSURL *filePath;
@end

@implementation NXNormalRenderer
#pragma mark - Init
-(instancetype) init
{
    self = [super init];
    if (self) {
           }
    return self;
}

#pragma mark - Overwrite super method
- (UIView *)renderFile:(NSURL *)filePath
{
    self.contentView = [super renderFile:filePath];
    if (self.contentView) {
        [self loadFileContentInView:self.contentView withFilePath:filePath];
        _filePath = filePath;
    }
    return self.contentView;
}
- (void)addOverlayer:(UIView *)overlay
{
    if (overlay) {

        overlay.userInteractionEnabled = NO;
        overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView insertSubview:overlay atIndex:0];
        [self.contentView bringSubviewToFront:overlay];
        [overlay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
}

- (void)snapShot:(getSnapshotCompletionBlock)block
{
    NSString* mimetype = [NXCommonUtils getMiMeType:self.filePath.path];
      if ([[mimetype lowercaseString] hasPrefix:@"image/"]) {
          UIImage *newImage = [UIImage imageWithContentsOfFile:self.filePath.path];
          block(newImage);
      }else{
          block([self.fileContentWebView viewPrintFormatter]);
      }
}

#pragma mark - Render method
- (void) loadFileContentInView:(UIView *)contentView withFilePath:(NSURL *)filePath;
{
    if (contentView && filePath) {
        _filePath = filePath;
        self.contentView = contentView;
//            NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
////             NSString *jScript  = @"";
//             WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
//             WKUserContentController *wkUController = [[WKUserContentController alloc] init];
//             [wkUController addUserScript:wkUScript];
//
//             WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
//             wkWebConfig.userContentController = wkUController;
             
        _fileContentWebView = [[WKWebView alloc] init];
//             _fileContentWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:wkWebConfig];
        _fileContentWebView.configuration.dataDetectorTypes =  WKDataDetectorTypeNone;
        _fileContentWebView.contentMode = UIViewContentModeCenter;
        _fileContentWebView.navigationDelegate = self;
        _fileContentWebView.opaque = NO;
        _fileContentWebView.backgroundColor = [UIColor whiteColor];
        _fileContentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [contentView addSubview:_fileContentWebView];
             
        self.fileContentWebView.scrollView.maximumZoomScale = 20;
        self.fileContentWebView.scrollView.minimumZoomScale = 0.1;
        
        NSString* mimetype = [NXCommonUtils getMiMeType:_filePath.path];
       if ([mimetype isEqualToString:@"image/heic"]) {
           UIImage *image = [UIImage imageWithContentsOfFile:_filePath.path];
           NSData *data = UIImageJPEGRepresentation(image,0.8);
           [self.fileContentWebView loadData:data MIMEType:@"image/jpg" characterEncodingName:@"UTF-8" baseURL:_filePath];
           return;
       }
        NSString *extension = [[NXCommonUtils getExtension:_filePath.path error:nil] lowercaseString];
        if (@available(iOS 15.0, *) && [extension isEqualToString:@"log"]) {
            //after iOS 15.0 use loadData this type return  "Error Domain=WebKitErrorDomain Code=102 "Frame load interrupted"
            NSData *plain = [NSData dataWithContentsOfURL:_filePath];
            [self.fileContentWebView loadData:plain MIMEType:mimetype characterEncodingName:@"GBK" baseURL:_filePath];
            return;
        }
            
        NSURL *accessUrl = [_filePath URLByDeletingLastPathComponent];
        [self.fileContentWebView loadFileURL:_filePath allowingReadAccessToURL:accessUrl];
//        NSData *plain = [NSData dataWithContentsOfURL:_filePath];
//        NSRange foundOjb = [OfficeMIMETYPE rangeOfString:mimetype options:NSCaseInsensitiveSearch];
//        [self.fileContentWebView loadData:plain MIMEType:mimetype characterEncodingName:@"UTF-8" baseURL:_filePath];
   
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    //TODO
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    [webView  evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
    
      self.fileContentWebView.scrollView.maximumZoomScale = 20;
      self.fileContentWebView.scrollView.minimumZoomScale = 0.1;

      if ([self.delegate respondsToSelector:@selector(fileRenderer:didLoadFile:error:)]) {
          __weak typeof(self) weakSelf = self;
          dispatch_async(dispatch_get_main_queue(), ^{
              __strong typeof(weakSelf) strongSelf = weakSelf;
              [strongSelf.delegate fileRenderer:strongSelf didLoadFile:strongSelf.filePath error:nil];
          });
      }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(fileRenderer:didLoadFile:error:)]) {
          __weak typeof(self) weakSelf = self;
          dispatch_async(dispatch_get_main_queue(), ^{
              __strong typeof(weakSelf) strongSelf = weakSelf;
              [strongSelf.delegate fileRenderer:strongSelf didLoadFile:strongSelf.filePath error:error];
          });
      }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
          if ([navigationAction.request.URL isFileURL]) {
             decisionHandler(WKNavigationActionPolicyAllow);
          } else {
              //link clicked such www.google.com
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
          }
      }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
