//
//  NXAllProjectDetailCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 31/10/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXAllProjectDetailCell.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXProjectModel.h"
@interface NXAllProjectDetailCell ()
@property (nonatomic, weak)UILabel *nameLabel;
@property (nonatomic, weak)UILabel *ownerLabel;
@property (nonatomic, weak)UILabel *ownerNameLabel;
@property (nonatomic, weak)UILabel *numberLabel;
@end
@implementation NXAllProjectDetailCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
}
- (void)commonInit {
    [self cornerRadian:5];
    self.contentView.backgroundColor = [UIColor whiteColor];
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.textColor = RMC_MAIN_COLOR;
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *ownerLabel = [[UILabel alloc]init];
    ownerLabel.textColor = [UIColor grayColor];
    ownerLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:ownerLabel];
    self.ownerLabel = ownerLabel;
    UILabel *ownerNameLabel = [[UILabel alloc]init];
    ownerNameLabel.textColor = [UIColor blackColor];
    ownerNameLabel.font = [UIFont systemFontOfSize:12];
    ownerNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:ownerNameLabel];
    self.ownerNameLabel = ownerNameLabel;
    
    UILabel *numberLabel = [[UILabel alloc]init];
    [self.contentView addSubview:numberLabel];
    numberLabel.textAlignment = NSTextAlignmentRight;
    numberLabel.font = [UIFont systemFontOfSize:12];
    self.numberLabel = numberLabel;
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    [ownerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(10);
        make.left.right.equalTo(nameLabel);
    }];
    
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ownerLabel.mas_bottom).offset(10);
        make.width.equalTo(@130);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    [ownerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ownerLabel.mas_bottom).offset(10);
        make.left.equalTo(ownerLabel);
        make.right.equalTo(numberLabel.mas_left).offset(-3);
    }];
}

- (void)setModel:(id)model {
    if ([model isKindOfClass:[NXProjectModel class]]) {
        NXProjectModel *projectModel = (NXProjectModel *)model;
        self.nameLabel.text = projectModel.name;
        self.ownerLabel.text = @"Owner:";
        self.ownerNameLabel.text = projectModel.projectOwner.name;
        NSString *filesStr = nil;
        NSString *membersStr = nil;
        if (projectModel.totalFiles > 1) {
            filesStr = [NSString stringWithFormat:@"%ld Files",projectModel.totalFiles];
        }else {
            filesStr = [NSString stringWithFormat:@"%ld File",projectModel.totalFiles];
        }
        if (projectModel.totalMembers > 1) {
            membersStr = [NSString stringWithFormat:@"%ld Members",projectModel.totalMembers];
        }else {
            membersStr = [NSString stringWithFormat:@"%ld Member",projectModel.totalMembers];
        }
        self.numberLabel.text = [NSString stringWithFormat:@"%@, %@",filesStr,membersStr];
    }
}
@end
@implementation NXAllProjectAddItemCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitAddItem];
    }
    return self;
}
- (void)commonInitAddItem {
    [self cornerRadian:5];
    self.contentView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"GreenPlusButton"];
    [self.contentView addSubview:imageView];
    UILabel *itemLabel = [[UILabel alloc]init];
    [self.contentView addSubview:itemLabel];
    itemLabel.text = @"Create new project";
    [itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.height.equalTo(self.contentView).multipliedBy(0.5);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.width.equalTo(@35);
        make.right.equalTo(itemLabel.mas_left).offset(-15);
    }];
    
    
}
@end
