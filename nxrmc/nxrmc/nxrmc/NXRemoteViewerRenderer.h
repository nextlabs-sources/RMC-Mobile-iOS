//
//  NXRemoteViewerRenderer.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/15/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileRendererBase.h"
#import <WebKit/WebKit.h>

@interface NXRemoteViewerRenderer : NXFileRendererBase
@property(nonatomic, strong) WKWebView *webView;

@end
