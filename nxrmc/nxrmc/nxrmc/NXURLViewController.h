//
//  NXURLViewController.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/22/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WebKit/WebKit.h>

@interface NXURLViewController : UIViewController

@property(nonatomic, strong, readonly) WKWebView *wkWebView;

@property(nonatomic, strong) NSURL *url;

@end
