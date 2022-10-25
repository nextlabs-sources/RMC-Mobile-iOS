//
//  NXEmptyView.m
//  nxrmc
//
//  Created by nextlabs on 12/15/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXEmptyView.h"

#import "Masonry.h"

@interface NXEmptyView ()

@property(nonatomic, strong) UIScrollView *scrollView;

@end

@implementation NXEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat scrollHeight = CGRectGetHeight(self.bounds) > 240 ? CGRectGetHeight(self.bounds):240;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds),scrollHeight);
}


#pragma mark 
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:imageView];
    
    UILabel *textLabel = [[UILabel alloc] init];
    [self.scrollView addSubview:textLabel];
    
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:18];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.textColor = [UIColor colorWithRed:0.76 green:0.76 blue:0.79 alpha:1.0];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _textLabel = textLabel;
    _imageView = imageView;
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scrollView);
        make.top.equalTo(self.scrollView).offset(kMargin * 12);
        make.width.equalTo(@120);
        make.height.equalTo(imageView.mas_width);
    }];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(kMargin * 2);
        make.centerX.equalTo(self.scrollView);
        make.width.equalTo(self).multipliedBy(0.8);
    }];
}

@end
