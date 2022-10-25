//
//  NXClassificationHeaderView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXClassificationHeaderView.h"
#import "Masonry.h"
#import "NXClassificationCategory.h"
@interface NXClassificationHeaderView ()
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UILabel *markLabel;
@end
@implementation NXClassificationHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - setter

- (void)setCategory:(NXClassificationCategory *)category {
    _category = category;
    self.titleLabel.text = category.name;
    if (category.mandatory) {
        self.markLabel.hidden = NO;
        self.markLabel.textColor = category.selectedLabs.count > 0 ? [UIColor grayColor] : [UIColor redColor];
    }
}
#pragma mark -
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview: titleLabel];
    self.titleLabel = titleLabel;
     self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    UILabel *markLabel = [[UILabel alloc]init];
    markLabel.text = NSLocalizedString(@"UI_MANDATORY", NULL);
    [self addSubview:markLabel];
    self.markLabel = markLabel;
    markLabel.hidden = YES;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self);
        make.width.lessThanOrEqualTo(self).multipliedBy(0.65);
    }];
    [markLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(titleLabel);
        make.left.equalTo(titleLabel.mas_right).offset(3);
        make.width.equalTo(@100);
    }];
    _titleLabel = titleLabel;
}


@end
