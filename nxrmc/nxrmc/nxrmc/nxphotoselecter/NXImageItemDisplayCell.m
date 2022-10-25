//
//  NXImageItemDisplayCell.m
//  xiblayout
//
//  Created by nextlabs on 10/19/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXImageItemDisplayCell.h"

@interface NXImageItemDisplayCell ()<UIScrollViewDelegate>

@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UIScrollView *scrollView;

@end

@implementation NXImageItemDisplayCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark 

- (void)singleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.singleTapCallBack) {
        self.singleTapCallBack();
    }
}

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
}

#pragma mark 

- (void)updateMinZoomScaleForSize {
    CGSize size = CGSizeZero;
    
    UIImage *image = self.imageView.image;
    
    CGFloat imageScale = image.size.height/image.size.width;
    CGFloat screenScale = self.contentView.bounds.size.height/self.contentView.bounds.size.width;
    
    if (imageScale > screenScale) {
        size.width = CGRectGetHeight(self.contentView.frame)/imageScale;
        size.height = CGRectGetHeight(self.contentView.frame);
    } else {
        size.width = CGRectGetWidth(self.contentView.frame);
        size.height = CGRectGetWidth(self.contentView.frame) * imageScale;
    }
    
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = size;
    
    [self.scrollView scrollRectToVisible:self.contentView.bounds animated:NO];
    
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.center = self.scrollView.center;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (CGRectGetWidth(scrollView.frame) > scrollView.contentSize.width) ? (CGRectGetWidth(scrollView.frame) - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height) ? (CGRectGetHeight(scrollView.frame) - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)setModel:(NXAssetItem *)model {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGSize size = CGSizeMake(width * scale, width * scale * model.asset.pixelHeight/model.asset.pixelWidth);
    
    [[NXPhotoTool sharedInstance] requestImageFromPhoto:model size:size resizeMode:PHImageRequestOptionsResizeModeExact synchronous:NO completion:^(UIImage *image, NSDictionary *info) {
        self.imageView.image = image;
        [self updateMinZoomScaleForSize];
    }];
}

#pragma mark

- (void)commonInit {
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    
    scrollView.multipleTouchEnabled = YES;
    
    scrollView.delegate = self;
    
    scrollView.maximumZoomScale = 3;
    scrollView.minimumZoomScale = 1.0;
    
    scrollView.scrollsToTop = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    scrollView.delaysContentTouches = NO;
    
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = imageView;
    
    [scrollView addSubview:imageView];
}

@end
