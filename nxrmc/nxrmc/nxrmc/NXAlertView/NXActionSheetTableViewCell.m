//
//  NXActionSheetTableViewCell.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 05/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXActionSheetTableViewCell.h"
#import "Masonry.h"

@interface NXActionSheetTableViewCell ()

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *rightImageView;
@end

@implementation NXActionSheetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithActionSheetItem:(NXActionSheetItem *)item
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    self.iconImageView = nil;
    self.titleLabel = nil;
    self.rightImageView = nil;
    long maxWidth = [UIScreen mainScreen].bounds.size.width -44-30;
    UIImageView *iconImageView = [[UIImageView alloc] init];
    self.iconImageView = iconImageView;
    iconImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:iconImageView];
    
    UIImageView *rightImageView = [[UIImageView alloc] init];
    self.rightImageView = rightImageView;
    rightImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:rightImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.left.equalTo(self).offset(12);
        make.width.equalTo(@32);
        make.height.equalTo(@32);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.userInteractionEnabled = YES;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.titleLabel = titleLabel;
    
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(13);
        make.left.equalTo(self).offset(56);
        make.width.lessThanOrEqualTo(@(maxWidth));
    }];
    [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(5);
        make.centerY.equalTo(iconImageView);
        make.height.width.equalTo(@20);
    }];
    self.iconImageView.image = item.image;
    self.titleLabel.text = item.title;
    if (item.rightImage) {
        self.rightImageView.image = item.rightImage;
        self.rightImageView.hidden = NO;
    }else{
        self.rightImageView.hidden = YES;
    }
   
}

@end
