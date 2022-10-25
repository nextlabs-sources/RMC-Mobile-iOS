//
//  VideoViewController.m
//  xiblayout
//
//  Created by nextlabs on 10/27/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "VideoViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Masonry.h"

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentOverlayView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.contentOverlayView.frame = [UIScreen mainScreen].bounds;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.contentOverlayView.frame = [UIScreen mainScreen].bounds;
}

- (void)addOverlay:(UIView *)overlayView {
    overlayView.frame = self.view.bounds;
    [self.contentOverlayView addSubview: overlayView];
    
    [overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentOverlayView);
    }];
    
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
}

@end
