//
//  NXPageControl.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/4/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXPageControl.h"

#import "NXDotView.h"
#import "Masonry.h"


#define kDotWidth 16

@interface NXPageControl ()

@property(nonatomic) NSInteger spaceBetweenDots;
@property(nonatomic) CGSize dotSize;

@property(nonatomic) Class dotViewClass;

@property(nonatomic, strong) NSMutableArray *dots;

@end

@implementation NXPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.dotViewClass = [NXDotView class];
    self.numberOfPages = 0;
    self.currentPage = 0;
    self.hidesForSinglePage = YES;
    self.dotSize = CGSizeMake(kDotWidth, kDotWidth);
    self.spaceBetweenDots = 8;
}

#pragma mark - setter/getter

- (NSMutableArray *)dots {
    if (!_dots) {
        _dots = [NSMutableArray array];
    }
    return _dots;
}

- (CGSize)dotSize {
    // Dot size logic depending on the source of the dot view
    if (self.dotImage && CGSizeEqualToSize(_dotSize, CGSizeZero)) {
        _dotSize = self.dotImage.size;
        if (_dotSize.width < kDotWidth || _dotSize.height < kDotWidth) {
            _dotSize = CGSizeMake(kDotWidth, kDotWidth);
        }
    } else if (self.dotViewClass && CGSizeEqualToSize(_dotSize, CGSizeZero)) {
        _dotSize = CGSizeMake(kDotWidth, kDotWidth);
    }
    return _dotSize;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self resetDotViews];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (self.numberOfPages == 0 || currentPage == _currentPage) {
        return;
    }
    
    [self changeActivity:NO atIndex:_currentPage];
    
    if (currentPage >= self.numberOfPages) {
        _currentPage = 0;
    } else {
        _currentPage = currentPage;
    }
    [self changeActivity:YES atIndex:_currentPage];
}

- (void)setDotImage:(UIImage *)dotImage {
    _dotImage = dotImage;
    self.dotViewClass = nil;
    [self resetDotViews];
}

- (void)setCurrentDotImage:(UIImage *)currentDotImage {
    _currentDotImage = currentDotImage;
    self.dotViewClass = nil;
    [self resetDotViews];
}

- (void)setDotViewClass:(Class)dotViewClass {
    _dotViewClass = dotViewClass;
    self.dotSize = CGSizeZero;
    
    [self resetDotViews];
}
#pragma mark -

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
    return CGSizeMake((self.dotSize.width + self.spaceBetweenDots) * pageCount - self.spaceBetweenDots, self.dotSize.height);
}

#pragma mark 

- (void)resetDotViews {
    for (UIView *dotView in self.dots) {
        [dotView removeFromSuperview];
    }
    [self.dots removeAllObjects];
    [self updateDots];
}

- (void)updateDots {
    if (self.numberOfPages == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < self.numberOfPages; ++i) {
        UIView *dot;
        if (i < self.dots.count) {
            dot = [self.dots objectAtIndex:i];
        } else {
            dot = [self generateDotView];
        }
        
        [self updateDotFrame:dot atIndex:i];
    }
    
    [self changeActivity:YES atIndex:self.currentPage];
    
    //hidden when only have one dot.
    if (self.dots.count == 1 && self.hidesForSinglePage) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
}

- (void)updateFrame:(BOOL)overrideExistingFrame
{
    [self resetDotViews];
}

- (void)updateDotFrame:(UIView *)dot atIndex:(NSInteger)index
{
    if (index == 0) {
        CGFloat width = [self sizeForNumberOfPages:self.numberOfPages].width;
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX).offset(-width/2 + self.dotSize.width/2);
            make.centerY.equalTo(self);
            make.height.equalTo(@(self.dotSize.width));
            make.width.equalTo(@(self.dotSize.height));
        }];
    } else {
        UIView *leftView = [self.dots objectAtIndex:index-1];
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(leftView.mas_right).offset(self.spaceBetweenDots);
            make.width.equalTo(@(self.dotSize.width));
            make.height.equalTo(@(self.dotSize.height));
        }];
    }
}

- (UIView *)generateDotView
{
    UIView *dotView;
    
    if (self.dotViewClass) {
        dotView = [[self.dotViewClass alloc] initWithFrame:CGRectMake(0, 0, self.dotSize.width, self.dotSize.height)];
        if ([dotView isKindOfClass:[NXDotView class]] && self.pageIndicatorTintColor) {
            NXDotView *temp = (NXDotView *)dotView;
            temp.deactiveColor = self.pageIndicatorTintColor;
            temp.activeColor = self.currentPageIndicatorTintColor;
        }
    } else {
        dotView = [[UIImageView alloc] initWithImage:self.dotImage];
        dotView.frame = CGRectMake(0, 0, self.dotSize.width, self.dotSize.height);
        dotView.contentMode = UIViewContentModeCenter;
    }
    
    if (dotView) {
        [self addSubview:dotView];
        [self.dots addObject:dotView];
    }
    
    dotView.userInteractionEnabled = YES;
    return dotView;
}

- (void)changeActivity:(BOOL)active atIndex:(NSInteger)index {
    if (self.dotViewClass) {
        NXDotView *dotView = (NXDotView *)[self.dots objectAtIndex:index];
        if ([dotView respondsToSelector:@selector(changeActiveState:)]) {
            [dotView changeActiveState:active];
        } else {
            NSLog(@"%@:%@ must implement an 'changeActivityState' method", self.dotViewClass, [dotView class]);
        }
    } else if (self.dotImage && self.currentDotImage) {
        UIImageView *dotView = (UIImageView *)[self.dots objectAtIndex:index];
        dotView.image = (active) ? self.currentDotImage : self.dotImage;
    }
}

@end
