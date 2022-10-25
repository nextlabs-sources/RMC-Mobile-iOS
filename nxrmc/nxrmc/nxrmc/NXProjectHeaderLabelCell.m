//
//  NXProjectHeaderLabelCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 2/13/17.
//  Copyright © 2017 zhuimengfuyun. All rights reserved.
//

#import "NXProjectHeaderLabelCell.h"

#import "Masonry.h"

@interface NXProjectHeaderLabelCell ()

@property(nonatomic, weak) UILabel *titleLabel;

@end

@implementation NXProjectHeaderLabelCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    if (title == _title) {
        return;
    }
    _title = title;
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.titleLabel.backgroundColor = [UIColor orangeColor];
}

#pragma mark
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:titleLabel];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 2;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor whiteColor];
    
    self.titleLabel = titleLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
