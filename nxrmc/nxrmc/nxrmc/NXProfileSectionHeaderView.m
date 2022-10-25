//
//  NXProfileSectionHeaderView.m
//  nxrmc
//
//  Created by nextlabs on 11/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXProfileSectionHeaderView.h"

#import "Masonry.h"

@interface NXProfileSectionHeaderView ()

@property(nonatomic, weak) UILabel *titleLabel;

@end

@implementation NXProfileSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)setModel:(NSString *)model {
    if ([_model isEqualToString:model]) {
        return;
    }
    self.titleLabel.text = model;
}
#pragma mark 
- (void)commonInit {
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kMargin * 2);
        make.right.equalTo(self).offset(-kMargin * 2);
        make.bottom.equalTo(self).offset(-4);
    }];

    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    
    self.titleLabel = titleLabel;
    
}
@end
