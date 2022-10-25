//
//  NXPageView.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXPageView.h"

#import "Masonry.h"

@interface NXPageView()

@end

@implementation NXPageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.centerX.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.5);
        make.width.equalTo(self).multipliedBy(0.7);
    }];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *mainLabel = [[UILabel alloc] init];
    [self addSubview:mainLabel];
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(kMargin);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.centerX.equalTo(self);
    }];
    
    mainLabel.numberOfLines = 0;
    mainLabel.textAlignment = NSTextAlignmentCenter;
    mainLabel.font = [UIFont systemFontOfSize:22.0];
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.adjustsFontSizeToFitWidth = YES;
    
    UILabel *detailLabel = [[UILabel alloc] init];
    
    [self addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainLabel.mas_bottom).offset(10);
        make.left.equalTo(self).offset(kMargin * 2);
        make.right.equalTo(self).offset(-kMargin * 2);
    }];
    
    detailLabel.numberOfLines = 0;
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.font = [UIFont systemFontOfSize:14.0f];
    detailLabel.textColor = [UIColor lightGrayColor];
    detailLabel.adjustsFontSizeToFitWidth = YES;
    
    NXPageControl *pageControl = [[NXPageControl alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self addSubview:pageControl];
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-kMargin * 2);
        make.centerX.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5);
        make.height.equalTo(@(30));
    }];
    
    self.imageView = imageView;
    self.mainTextLabel = mainLabel;
    self.detailTextLabel = detailLabel;
    self.pageControl = pageControl;

#if 0
    self.imageView.backgroundColor = [UIColor blueColor];
    self.mainTextLabel.backgroundColor = [UIColor yellowColor];
    self.detailTextLabel.backgroundColor = [UIColor brownColor];
    self.pageControl.backgroundColor = [UIColor greenColor];
#endif
}


@end
