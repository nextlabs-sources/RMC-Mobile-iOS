//
//  NXSimpleRemoteViewParseResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/14/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "NXSimpleRemoteViewParseResponder.h"
#import "NXRemoteViewerRepositoryAPI.h"
#import "NXLRights.h"

@interface NXSimpleRemoteViewParseResponder()<WKNavigationDelegate>
@property(nonatomic, strong) WKWebView *contentWebView;
@property(nonatomic, copy) parseFileCompletion parseCompletion;
@property(nonatomic, strong) NXFileBase *curFile;
@property(nonatomic, strong) NSString *remoteViewCookies;
@property(nonatomic, strong) NXRemoteViewerRepositoryResquest *simpleRemoteViewRequest;
@end

@implementation NXSimpleRemoteViewParseResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentTypeRemoteView;
    NSString *fileExtension = [NXCommonUtils getFileExtensionByFileName:file];
    if((file.serviceType.integerValue == kServiceSkyDrmBox || [file isKindOfClass:[NXMyVaultFile class]]) && [NXCommonUtils isRemoteViewSupportFormat:fileExtension]){
        self.parseCompletion = completion;
        self.curFile = file;
        if([file isKindOfClass:[NXMyVaultFile class]]){
            file.repoId = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository].service_id;
            file.serviceAlias = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository].service_alias;
            file.serviceType = [NSNumber numberWithInteger:kServiceSkyDrmBox];
        }
        NXRemoteViewerRepositoryModel *reqModel = [[NXRemoteViewerRepositoryModel alloc] init];
        reqModel.file = file;
        reqModel.operations = 0;
        
        self.simpleRemoteViewRequest = [[NXRemoteViewerRepositoryResquest alloc] init];
        WeakObj(self);
        [self.simpleRemoteViewRequest requestWithObject:reqModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            StrongObj(self);
            if (self) {
                NXRemoteViewerResponse *remoteViewResponse = (NXRemoteViewerResponse *)response;
                if (remoteViewResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
//                    // Cache rights info
//                    NXLRights *rights = [[NXLRights alloc] init];
//                    [rights setPermissions:remoteViewResponse.permissions];
//                    [[NXLoginUser sharedInstance].nxlOptManager cacheRights:rights duid:remoteViewResponse.duid ownerId:remoteViewResponse.ownerId forFile:file];
                    
                    [NXCommonUtils addCustomCookies:[NSURL URLWithString:remoteViewResponse.viewerURL] withCooies:remoteViewResponse.cookies];
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:remoteViewResponse.viewerURL]];
                    
                    dispatch_main_async_safe(^{
                        self.parseCompletion(self, self.curFile, self.contentWebView, nil);
                        [self.contentWebView loadRequest:request];
                    });
                    
                }else{
                    dispatch_main_async_safe(^{
                        self.parseCompletion(self, file, nil, self.defaultError);
                    });
                }
            }
        }];
        
    }else{
     if(self.nextResponder){
              [self.nextResponder parseFile:file withCompleteBlock:completion];
          }else{
              [super parseFile:file withCompleteBlock:completion];
          }
    }
}
- (WKWebView *) contentWebView
{
    if (_contentWebView == nil) {
        _contentWebView = [[WKWebView alloc] init];
        _contentWebView.configuration.dataDetectorTypes = WKDataDetectorTypeNone;
       // _contentWebView.scalesPageToFit = YES;
        _contentWebView.navigationDelegate = self;
        _contentWebView.opaque = NO;
        _contentWebView.backgroundColor = [UIColor whiteColor];
        _contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _contentWebView;
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
   //这里是js，主要目的实现对图片url的获取
      static  NSString * const jsGetImages =
      @"function getImages(){\
      var objs = document.getElementsByTagName(\"img\");\
      var imgScr = '';\
      for(var i=0;i<objs.length;i++){\
      imgScr = imgScr + objs[i].src + '+';\
      };\
      return imgScr;\
      };";
     //注入JS方法
        [self.contentWebView evaluateJavaScript:jsGetImages completionHandler:nil];
        //调用方法，获取到了网页上所有的图片，可以根据自己需要从存放图片Url数组里面获取
            [self.contentWebView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable any, NSError * _Nullable error) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      NSString *resurlt = any;
                              if (resurlt.length > 0) {
                                     NSRange range = [resurlt rangeOfString:@"data:"];
                                     if (range.length == 0) {
                                         block(nil);
                                     }else{
                                      NSString *subStr = [resurlt substringFromIndex:range.location];
                                      NSString *imageUrlStr = [subStr substringToIndex:[subStr length] - 1];
                                      NSLog(@"%@",subStr);
                                      
                                      NSURL *url = [NSURL URLWithString:imageUrlStr];
                                      NSData *imageData = [NSData dataWithContentsOfURL:url];
                                      UIImage *webviewImage = [UIImage imageWithData:imageData];
                                      //UIImage *webviewImage = [UIImage imageWithBase64Str:imageUrlStr];
                                      NSLog(@"head image ++++%@",webviewImage);
                                         block(webviewImage);
                                     }
                                 }else{
                                     block(nil);
                                 }
                  });
               }];
}
                                             
-(void)addOverlay:(UIView *)overLay{
    //overlay will be added by url content.
  //    if (overLay) {
  //        overLay.userInteractionEnabled = NO;
  //        overLay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  //        [self.contentWebView insertSubview:overLay atIndex:0];
  //        [self.contentWebView bringSubviewToFront:overLay];
  //    }
}
                                             
- (void)closeFile{
    self.contentWebView = nil;
    self.parseCompletion = nil;
    self.curFile = nil;
    self.remoteViewCookies = nil;
    self.simpleRemoteViewRequest = nil;
}
                                        
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
   DLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    DLog(@"%s", __FUNCTION__);
     
     //post notification for detail view print button enabled
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DETAILVC_PRINT_ENABLED object:nil userInfo:nil];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    dispatch_main_async_safe(^{
          self.parseCompletion(self,self.curFile, nil,error);
      });
      DLog(@"%s", __FUNCTION__);
}
                                               
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
       NSURLCredential * credential = [[NSURLCredential alloc] initWithTrust:[challenge protectionSpace].serverTrust];
       completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}
                                             
@end
