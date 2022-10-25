//
//  NXAddToProjectCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/3/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXAddToProjectCell.h"
#import "Masonry.h"
#import "HexColor.h"
#import "NXProjectModel.h"
@interface NXAddToProjectCell ()
@property (nonatomic, strong)UIImageView *leftImageView;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UIImageView *rightImageView;
@property (nonatomic, strong)UILabel *ownerLabel;
//@property (nonatomic, strong)UILabel *dateLabel;
//@property (nonatomic, strong)UILabel *fileNumberLabel;
//@property (nonatomic, strong)UILabel *invitedByLabel;
//@property (nonatomic, strong)NSDateFormatter *formatter;
@end
@implementation NXAddToProjectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.formatter = [[NSDateFormatter alloc]init];
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.contentView addSubview:imageView];
    self.leftImageView = imageView;
    
    UILabel *nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:nameLabel];
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameLabel.font = [UIFont systemFontOfSize:16];
    self.nameLabel = nameLabel;
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedIcon"]];
    [self.contentView addSubview:rightImageView];
    rightImageView.hidden = YES;
    self.rightImageView = rightImageView;
    
    UILabel *ownerLabel = [[UILabel alloc] init];
    ownerLabel.numberOfLines = 0;
    ownerLabel.font = [UIFont systemFontOfSize:12];
    ownerLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    ownerLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:ownerLabel];
    self.ownerLabel = ownerLabel;
//    UILabel *dateLabel = [[UILabel alloc]init];
//    [self.contentView addSubview:dateLabel];
//    dateLabel.font = [UIFont systemFontOfSize:14];
//    self.dateLabel = dateLabel;
//
//    UILabel *invitedByLabel = [[UILabel alloc]init];
//    [self.contentView addSubview:invitedByLabel];
//    invitedByLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    invitedByLabel.hidden = YES;
//    invitedByLabel.font = [UIFont systemFontOfSize:12];
//    invitedByLabel.textColor = [HXColor colorWithHexString:@"#333333"];
//    self.invitedByLabel = invitedByLabel;
//
//    UILabel *fileNumberLabel = [[UILabel alloc]init];
//    [self.contentView addSubview:fileNumberLabel];
//    fileNumberLabel.font = [UIFont systemFontOfSize:14];
//    self.fileNumberLabel = fileNumberLabel;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView).offset(5);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kMargin * 2);
        make.width.equalTo(@19);
        make.height.equalTo(@27);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(imageView.mas_right).offset(10);
       make.right.equalTo(rightImageView.mas_left).offset(-kMargin);
        make.height.equalTo(@22);
//        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
    [ownerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(kMargin/2);
        make.left.equalTo(nameLabel);
        make.right.equalTo(rightImageView.mas_left).offset(-kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
//    [invitedByLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(nameLabel);
//        make.left.equalTo(nameLabel.mas_right).offset(5);
//        make.right.equalTo(self.contentView).offset(-5);
//        make.height.equalTo(@14);
//    }];
//    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(nameLabel.mas_bottom).offset(kMargin);
//        make.left.right.equalTo(nameLabel);
//        make.height.equalTo(@18);
//        make.bottom.equalTo(self.contentView).offset(-kMargin);
//    }];
//    [fileNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(dateLabel);
//        make.left.right.equalTo(invitedByLabel);
//        make.height.bottom.equalTo(dateLabel);
//    }];
    
    [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kMargin * 2);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    
}
- (void)setModel:(NXProjectModel *)model {
    _model = model;
    self.nameLabel.text = model.name;
    self.ownerLabel.text = [NSString stringWithFormat:@"Owner:%@",model.projectOwner.email];
//    self.dateLabel.text = [self becomeToDateFormTimestamp:model.createdTime];
//    self.fileNumberLabel.text = [NSString stringWithFormat:@"%ld Files",model.totalFiles];
    if (model.isOwnedByMe) {
        self.leftImageView.image = [UIImage imageNamed:@"CreatedbyMe"];
    }else {
        self.leftImageView.image = [UIImage imageNamed:@"InvitedbyOthers"];
//        self.invitedByLabel.hidden = NO;
//        self.invitedByLabel.text = [NSString stringWithFormat:@"invitedBy:%@",model.projectOwner.name];
    }
}
- (void)isShowRightImageView:(BOOL)isShow {
    if (isShow) {
        self.rightImageView.hidden = NO;
    }else{
        self.rightImageView.hidden = YES;
    }
}
- (void)isShowAccessBtnIconImage:(BOOL)isShow {
    if (isShow) {
        self.rightImageView.hidden = NO;
        self.rightImageView.image = [UIImage imageNamed:@"accessoryIcon"];
    }else{
        self.rightImageView.hidden = YES;
    }
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//   self.rightImageView.hidden =! selected;
//}
//- (NSString *)becomeToDateFormTimestamp:(NSTimeInterval)timestamp{
//    NSTimeInterval interval = timestamp / 1000.0;
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
//    [self.formatter setDateFormat:@"d MMM"];
//    NSString *dateString = [self.formatter stringFromDate:date];
//    return dateString;
//}
@end
