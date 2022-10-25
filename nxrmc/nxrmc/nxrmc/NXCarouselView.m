//
//  NXCarouselView.m
//  nxrmc
//
//  Created by nextlabs on 11/3/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXCarouselView.h"

#import "Masonry.h"
#import "NXPageControl.h"

#import "NSTimer+NXBlockSupport.h"
#import "NXRMCDef.h"

#define kDefaultCount 20
#define KDefaultTimeInter 4

@interface NXCarouselView()<UIScrollViewDelegate>

@property(nonatomic, weak) UIScrollView *scrollView;
@property(nonatomic, weak) NXPageControl *pageControl;

@property(nonatomic, assign) NSInteger pageNumbers;

@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, strong) NSTimer *timer;


@end

@implementation NXCarouselView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark setter/getter 

- (NSInteger)pageNumbers {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberofPagecarouseView:)]) {
        _pageNumbers = [self.dataSource numberofPagecarouseView:self];
    } else {
        _pageNumbers = 0;
    }
    
    return _pageNumbers;
}

- (id<NXCarouseViewDataSource>)dataSource {
    NSAssert(_dataSource!= nil, @"dataSource can not be null, you must set datasource");
    return _dataSource;
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl = showPageControl;
    if (_showPageControl) {
        [self.pageControl setHidden:NO];
    } else {
        [self.pageControl setHidden:YES];
    }
}

#pragma mark 

- (void)layoutSubviews {
    if (self.showPageControl) {
        self.pageControl.hidden = NO;
    } else {
        self.pageControl.hidden = YES;
    }
}

#pragma mark - Public method 

- (void)reloadData {
    self.pageControl.numberOfPages = self.pageNumbers;
    if (self.pageNumbers <= 1) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }

    //add all views that will be scroll.
    UIView *lastView = nil;
    for (int index = 0; index < self.pageNumbers + 2; index++) {
        UIView *view;
        if (index == 0) {
            view = [self.dataSource pageAtIndex:self.pageNumbers - 1 carouseView:self];
        } else if (index == self.pageNumbers + 1) {
            view = [self.dataSource pageAtIndex:0 carouseView:self];
        } else {
            view = [self.dataSource pageAtIndex:index - 1 carouseView:self];
        }
        view.frame = CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        view.tag = index + 1;
        [self.scrollView addSubview:view];
        if (index == 0) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.scrollView);
                make.top.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(self);
            }];
        } else {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(lastView.mas_right);
                make.top.equalTo(self);
                make.width.equalTo(self);
                make.height.equalTo(self);
            }];
        }
        lastView = view;
    }
    
    //setting display area.
    [self layoutIfNeeded]; //fix bug: when first load, layout make carouseView frame changed will cause display bug.
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * (self.pageNumbers + 2), self.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    
    
    //update pageContorller;
    if ([self.dataSource respondsToSelector:@selector(defaultImageforPageControlInCarouselView:)]) {
        self.pageControl.dotImage = [self.dataSource defaultImageforPageControlInCarouselView:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(selectedImageforPageControlInCarouselView:)]) {
        self.pageControl.currentDotImage = [self.dataSource selectedImageforPageControlInCarouselView:self];
    }
    
    [self.pageControl sizeToFit];
}

- (void)addTimer {
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:KDefaultTimeInter target:self selector:@selector(nextpage) userInfo:nil repeats:YES];
    WeakObj(self);
    NSTimer *timer = [NSTimer nx_scheduledTimerWithTimeInterval:KDefaultTimeInter block:^{
        StrongObj(self);
        if (self.pageControl.currentPage == self.pageNumbers - 1) {
            //        self.pageControl.currentPage = 0;
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:YES];
        }else{
            [self.scrollView setContentOffset:CGPointMake(self.bounds.size.width * (self.pageControl.currentPage + 2), 0) animated:YES];
        }
    } repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc {
    DLog();
}

#pragma mark 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentIndex = (scrollView.contentOffset.x + self.bounds.size.width * 0.5)/self.bounds.size.width;
    if (scrollView.contentOffset.x > self.bounds.size.width * (self.pageNumbers + 0.5)) {
        self.pageControl.currentPage = 0;
    } else if (scrollView.contentOffset.x < self.bounds.size.width * 0.5) {
        self.pageControl.currentPage = self.pageNumbers - 1;
    } else {
        self.pageControl.currentPage = self.currentIndex - 1;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.currentIndex == self.pageNumbers + 1) {
        self.scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    } else if (self.currentIndex == 0) {
        self.scrollView.contentOffset = CGPointMake(self.bounds.size.width * self.pageNumbers, 0);
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

#pragma mark

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    
    NXPageControl *pageControl = [[NXPageControl alloc] initWithFrame:CGRectMake(40, 40, 100, 40)];
    [self addSubview:pageControl];
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset((-30));
        make.width.equalTo(self).multipliedBy(0.5);
        make.height.equalTo(self).multipliedBy(0.1);
    }];
    
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    self.scrollView = scrollView;
    self.pageControl = pageControl;
    
//    self.scrollView.backgroundColor = [UIColor redColor];
//    self.pageControl.backgroundColor = [UIColor whiteColor];
    
    [self addTimer];
}

@end
