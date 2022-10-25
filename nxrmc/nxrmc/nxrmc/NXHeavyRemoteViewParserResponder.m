//
//  NXHeavyRemoteViewParserResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXHeavyRemoteViewParserResponder.h"
#import "NXRemoteViewerRenderer.h"
#import "NXCommonUtils.h"
#import <WebKit/WebKit.h>

@interface NXHeavyRemoteViewParserResponder()<NXFileRendererDelegate>
@property(nonatomic, strong) NXRemoteViewerRenderer *remoteViewRender;
@property(nonatomic, strong) NXFileBase *curFile;
@end


@implementation NXHeavyRemoteViewParserResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentTypeRemoteView;
    NSString *extension = [NXCommonUtils getExtension:file.localPath error:nil];
    if ([NXCommonUtils isRemoteViewSupportFormat:extension]) {
        self.curFile = file;
        self.remoteViewRender = [[NXRemoteViewerRenderer alloc] init];
        self.remoteViewRender.delegate = self;
        UIView *contentView = [self.remoteViewRender renderFile:[NSURL fileURLWithPath:file.localPath]];
        completion(self, file, contentView, nil);
    }else{
        if (self.nextResponder) {
            [self.nextResponder parseFile:file withCompleteBlock:completion];
        }else{
            [super parseFile:file withCompleteBlock:completion];
        }
    }
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
       // [webView stringByEvaluatingJavaScriptFromString:jsGetImages];
        [self.remoteViewRender.webView evaluateJavaScript:jsGetImages completionHandler:nil];
        //调用方法，获取到了网页上所有的图片，可以根据自己需要从存放图片Url数组里面获取
            [self.remoteViewRender.webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable any, NSError * _Nullable error) {
                          NSString  *resurlt = any;
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
                }];
}

- (void)addOverlay:(UIView *)overLay
{
    [self.remoteViewRender addOverlayer:overLay];
}
- (void)closeFile
{
    self.remoteViewRender = nil;
}

#pragma mark - NXFileRendererDelegate
- (void)fileRenderer:(NXFileRendererBase *)fileRenderer didLoadFile:(NSURL *)filePath error:(NSError *)error
{
    //post notification for detail view print button enabled
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DETAILVC_PRINT_ENABLED object:nil userInfo:nil];
}

@end
