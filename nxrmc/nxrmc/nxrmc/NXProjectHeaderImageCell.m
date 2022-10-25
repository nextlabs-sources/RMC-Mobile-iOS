//
//  NXProjectHeaderImageCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 2/13/17.
//  Copyright © 2017 zhuimengfuyun. All rights reserved.
//

#import "NXProjectHeaderImageCell.h"

#import "Masonry.h"

@interface NXProjectHeaderImageCell ()

@property(nonatomic, weak) UIImageView *imageView;

@end

@implementation NXProjectHeaderImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if (image == _image) {
        return;
    }
    _image = image;
    self.imageView.image = image;
}

#pragma mark
- (void)commonInit {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:imageView];
    
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.backgroundColor = [UIColor clearColor];
    
    self.imageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
