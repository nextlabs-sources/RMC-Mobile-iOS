//
//  NXPDFParserResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//
#import "Masonry.h"
#import "NXPDFParserResponder.h"
#import "NXCommonUtils.h"
#import "NX3DFileConverter.h"
#import "NXFileRendererProvider.h"
#import "NXMBManager.h"
#import "NXOverlayView.h"
#import <WebKit/WebKit.h>

@interface NXPDFParserResponder()<WKNavigationDelegate>
@property(nonatomic, assign) BOOL is3DPdf;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIView *pdf2DContentView;
@property(nonatomic, strong) WKWebView *pdf2DView;
@property(nonatomic, strong) UIView *pdf3DView;
@property(nonatomic, strong) UIView *pdf2D3DSwitchView;
@property(nonatomic, strong) UIButton *switchButton;
@property(nonatomic, strong) NX3DFileConverter *fileConverter;
@property(nonatomic, copy) parseFileCompletion parseCompleteBlock;
@property(nonatomic, strong) NXFileBase *currentFile;
@property(nonatomic, strong) NXFileRendererBase *pdf3DRender;
@property(nonatomic, assign) BOOL isShow3D;
@property(nonatomic, strong) NSString *convertFileOptID;
@property(nonatomic, strong) NXOverlayView *pdfOverLayView;
@property(nonatomic, strong) NXOverlayView *threeDPdfOverLayView;
@end

@implementation NXPDFParserResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentTypePDF;
    NSString *fileExtension = [NXCommonUtils getExtension:file.localPath error:nil];
    if ([fileExtension compare:FILEEXTENSION_PDF options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.currentFile = file;
        self.parseCompleteBlock = completion;
        self.fileConverter = [[NX3DFileConverter alloc] init];
        self.is3DPdf = [NXCommonUtils ispdfFileContain3DModelFormat:file.localPath];
        if (self.is3DPdf) {
            [self config2D3DView];
            self.parseCompleteBlock(self, self.currentFile, self.contentView, nil);
            [self loadNormalPDFView:file];
        }else{
            [self config2DView];
            self.parseCompleteBlock(self, self.currentFile, self.pdf2DContentView, nil);
            [self loadNormalPDFView:file];
        }
        
    }else{
        if (self.nextResponder) {
            [self.nextResponder parseFile:file withCompleteBlock:completion];
        }else{
            [super parseFile:file withCompleteBlock:completion];
        }
    }
}

- (void)loadNormalPDFView:(NXFileBase *)file
{
    NSString* mimetype = [NXCommonUtils getMiMeType:self.currentFile.localPath];
    NSData *plain = [NSData dataWithContentsOfFile:self.currentFile.localPath];
    [self.pdf2DView loadData:plain MIMEType:mimetype characterEncodingName:@"UTF-8" baseURL:[NSURL fileURLWithPath:self.currentFile.localPath]];
}

- (UIView *)threeDPdfView:(NXFileBase *)file{
    return nil;
}
#pragma mark - for 3D PDF
- (BOOL)saveFile:(NSData*)binary fileName:(NSString*)fileName fullPath:(NSString**)fullPath
{
    // detect the directory if is exist,if not create a new directory named "ConvertFile" in tmp
    NSString *path = [NXCommonUtils getConvertFileTempPath];
    
    // save the file to local disk,like /tmp/nxrmcTmp/xxxx.hsf
    path = [path stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        //if this name's file exist,now just delete this file,in the future maybe need change
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    if(![binary writeToFile:path atomically:YES])
    {
        NSLog(@"convert file receive data  but write file fail");
        return NO;
    }
    
    *fullPath = path;
    return YES;
}

- (void) config2D3DView
{
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
   
    self.pdf2D3DSwitchView = [[UIView alloc] init];
    
    [self.contentView addSubview:self.pdf2D3DSwitchView];
    
    [self.pdf2D3DSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(self.contentView);
    }];
    
    [self config2DView];
    
    [self.pdf2D3DSwitchView addSubview:self.pdf2DContentView];
    [self.pdf2DContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(self.pdf2D3DSwitchView);
    }];
    
    
    self.switchButton = [[UIButton alloc] init];
    self.switchButton.backgroundColor = [UIColor redColor];
    [self.switchButton setTitle:@"3D" forState:UIControlStateNormal];
    [self.switchButton addTarget:self action:@selector(switch2D3DPDFView:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.switchButton];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-20);
        make.left.equalTo(self.contentView).offset(20);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
}

- (void)config2DView
{
    self.pdf2DContentView = [[UIView alloc] init];
    self.pdf2DContentView.backgroundColor = [UIColor whiteColor];
    
    self.pdf2DView = [[WKWebView alloc] init];
    self.pdf2DView.configuration.dataDetectorTypes = UIDataDetectorTypeNone;
    //self.pdf2DView.scalesPageToFit = YES;
    self.pdf2DView.navigationDelegate = self;
    self.pdf2DView.opaque = NO;
    self.pdf2DView.backgroundColor = [UIColor whiteColor];
    self.pdf2DView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.pdf2DView.scrollView.maximumZoomScale = 20;
    self.pdf2DView.scrollView.minimumZoomScale = 0.1;
    
    [self.pdf2DContentView addSubview:self.pdf2DView];
    [self.pdf2DView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.pdf2DContentView);
    }];
}



#pragma mark - UI response
- (void)switch2D3DPDFView:(UIButton *)button
{
    if ([self.switchButton.titleLabel.text isEqualToString:@"2D"]) {
        [self.switchButton setTitle:@"3D" forState:UIControlStateNormal];
        [self.pdf2D3DSwitchView bringSubviewToFront:self.pdf2DContentView];
        self.isShow3D = NO;
    }else{
        [self.switchButton setTitle:@"2D" forState:UIControlStateNormal];
        if (_pdf3DView == nil) {
            _pdf3DView = [[UIView alloc] init];
            [self.pdf2D3DSwitchView addSubview:_pdf3DView];
            [self.pdf3DView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.pdf2D3DSwitchView);
            }];
            button.userInteractionEnabled = NO;
            [NXMBManager showLoadingToView:self.pdf2D3DSwitchView];
            WeakObj(self);
           self.convertFileOptID = [self.fileConverter convertFile:self.currentFile data:[NSData dataWithContentsOfFile:self.currentFile.localPath] progress:nil completion:^(NXFileBase *fileItem, NSData *data, NSError *error) {
                StrongObj(self);
                button.userInteractionEnabled = YES;
                [NXMBManager hideHUDForView:self.pdf2D3DSwitchView];
                if (data) {
                    NSString *path = nil;
                    [self saveFile:data fileName:@"tempConvert.hsf" fullPath:&path];
                    self.pdf3DRender = [NXFileRendererProvider fileRendererForType:NXFileRendererTypeHoops];
                    UIView* converted3DView = [self.pdf3DRender renderFile:[NSURL fileURLWithPath:path]];
                    [self.pdf3DView addSubview:converted3DView];
                    [converted3DView mas_makeConstraints:^(MASConstraintMaker *make) {
//                        make.top.left.width.height.equalTo(self.pdf3DView);
                        make.edges.equalTo(self.pdf3DView);
                    }];
                    if (self.threeDPdfOverLayView) {
                        [self.pdf3DRender addOverlayer:self.threeDPdfOverLayView];
                    }
                    
                }
            }];
        } // first init 3d view
        [self.pdf2D3DSwitchView bringSubviewToFront:self.pdf3DView];
        self.isShow3D = YES;
    }
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
  if (self.isShow3D) {
        [self.pdf3DRender snapShot:^(id image) {
            block(image);
        }];
     }else{
         block([self.pdf2DView viewPrintFormatter]);
     }
}

- (void)addOverlay:(UIView *)overLay
{
    if (overLay) {
        NSAssert([overLay isKindOfClass:[NXOverlayView class]], @"overLay is tread as NXOverlayView");
        NXOverlayTextInfo *overlayInfo = ((NXOverlayView *)overLay).overLayInfo;
        self.pdfOverLayView = [[NXOverlayView alloc] initWithFrame:CGRectZero Obligation:overlayInfo];
        self.pdfOverLayView.userInteractionEnabled = NO;
        self.pdfOverLayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.pdfOverLayView.frame = CGRectMake(0, 0, CGRectGetWidth(self.pdf2DContentView.frame), CGRectGetHeight(self.pdf2DContentView.frame));
        self.threeDPdfOverLayView = [[NXOverlayView alloc] initWithFrame:CGRectZero Obligation:overlayInfo];
        [self.pdf2DContentView insertSubview:self.pdfOverLayView atIndex:0];
        [self.pdf2DContentView bringSubviewToFront:self.pdfOverLayView];
        [self.pdf3DRender addOverlayer:self.threeDPdfOverLayView];
    }
}




- (void)closeFile
{
    [self.fileConverter cancelOperation:self.convertFileOptID];
    [self.pdf3DRender removeOverlayer];
    self.is3DPdf = NO;
    self.contentView = nil;
    self.pdf3DRender = nil;
    self.pdf2DView = nil;
    self.pdf3DView = nil;
    self.pdf2D3DSwitchView = nil;
    self.switchButton = nil;
    self.fileConverter = nil;
    self.parseCompleteBlock = nil;
    self.currentFile = nil;
    self.isShow3D = NO;
    self.pdf2DContentView = nil;
    self.pdfOverLayView = nil;
    self.threeDPdfOverLayView = nil;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.pdf2DView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
      [self.pdf2DView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
      self.pdf2DView.scrollView.maximumZoomScale = 20;
      self.pdf2DView.scrollView.minimumZoomScale = 0.1;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
 
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
