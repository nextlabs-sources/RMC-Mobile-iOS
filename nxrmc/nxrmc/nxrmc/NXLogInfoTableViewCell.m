//
//  NXLogInfoTableViewCell.m
//  nxrmc
//
//  Created by helpdesk on 10/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXLogInfoTableViewCell.h"
#import "NXNXLFileLogManager.h"
#import "Masonry.h"
@interface NXLogInfoTableViewCell ()
@property(nonatomic, strong)UIImageView *leftImageView;
@property(nonatomic, strong)UILabel *userLabel;
@property(nonatomic, strong)UILabel *operationLabel;
@property(nonatomic, strong)UIButton *activityDetailBtn;
@property(nonatomic, strong)UILabel *timeLabel;
@property(nonatomic, strong)UILabel *deviceInfoLabel;
@property(nonatomic, strong)UILabel *resultLabel;
@end
@implementation NXLogInfoTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (BOOL)isShowActivityDetailInfo:(NSString *)operation {
    if ([operation isEqualToString:@"Added From"] || [operation isEqualToString:@"Saved as"] || [operation isEqualToString:@"Add file to"]) {
        return YES;
    }
    return NO;
}
- (void)setModel:(NXNXLFileLogModel *)model {
//    _model = model;
    self.userLabel.text = model.email;
    self.operationLabel.attributedText = [self createAttributeString:model.operation subTitle:@""];
    self.timeLabel.text = model.accessTimeStr;
    if ([model.accessResult isEqualToString:@"Allow"]) {
        self.leftImageView.image = [UIImage imageNamed:@"Allow"];
        self.resultLabel.text = @"Allow";
        self.resultLabel.textColor = RMC_MAIN_COLOR;
    }else {
        self.leftImageView.image = [UIImage imageNamed:@"Deny"];
        self.resultLabel.text = @"Deny";
        self.resultLabel.textColor = [UIColor redColor];
    }
    if (model.activityData && [self isShowActivityDetailInfo:model.operation]) {
        self.userInteractionEnabled = YES;
        self.activityDetailBtn.hidden = NO;
        
    }else{
        self.userInteractionEnabled = NO;
        self.activityDetailBtn.hidden = YES;
    }
    self.deviceInfoLabel.text = [NSString stringWithFormat:@"%@ %@", model.deviceType, model.deviceId];
    
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :RMC_MAIN_COLOR,NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    
    NSAttributedString *sub = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [myprojects appendAttributedString:sub];
    return myprojects;
}

- (void)commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *leftImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:leftImageView];
    self.leftImageView = leftImageView;
    UILabel *userLabel = [[UILabel alloc]init];
    userLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    userLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:userLabel];
    self.userLabel = userLabel;
    self.userLabel.accessibilityValue = @"FILE_ACTIVITY_USER_LAB";
    UILabel *operationLabel = [[UILabel alloc]init];
    [self.contentView addSubview:operationLabel];
    self.operationLabel = operationLabel;
    self.operationLabel.accessibilityValue = @"FILE_ACTIVITY_OPERATION_LAB";
    UIButton *activityDetailBtn = [[UIButton alloc] init];
    [self.contentView addSubview:activityDetailBtn];
    self.activityDetailBtn = activityDetailBtn;
    activityDetailBtn.hidden = YES;
    activityDetailBtn.enabled = NO;
    [activityDetailBtn setBackgroundImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    activityDetailBtn.imageView.backgroundColor = [UIColor blackColor];
    self.activityDetailBtn.accessibilityValue = @"FILE_ACTIVITY_DETAIL_BTN";
    UILabel *timeLabel = [[UILabel alloc]init];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    self.timeLabel.accessibilityValue = @"FILE_ACTIVITY_OPERATION_TIME_LAB";
    
    UILabel *deviceInfoLabel = [[UILabel alloc] init];
    deviceInfoLabel.textAlignment = NSTextAlignmentLeft;
    deviceInfoLabel.font = [UIFont systemFontOfSize:10];
    deviceInfoLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:deviceInfoLabel];
    self.deviceInfoLabel = deviceInfoLabel;
    
    UIView *segmentView = [[UIView alloc] init];
    segmentView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:segmentView];
    
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.textAlignment = NSTextAlignmentCenter;
    resultLabel.font = [UIFont systemFontOfSize:14.0];
    self.resultLabel = resultLabel;
    self.resultLabel.accessibilityValue = @"FILE_ACTIVITY_RESULT_LAB";
    [self.contentView addSubview:resultLabel];
    
    [leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12);
        make.left.equalTo(self.contentView).offset(5);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    [userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(leftImageView.mas_right).offset(5);
        make.height.equalTo(@25);
        make.width.equalTo(self.contentView).multipliedBy(0.55);
    }];
    [operationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userLabel.mas_bottom);
        make.left.and.height.width.equalTo(userLabel);
       
    }];
    
    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userLabel.mas_top).offset(10);
        make.left.equalTo(operationLabel.mas_right).offset(5);
        make.right.equalTo(self.contentView);
    }];
   
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resultLabel.mas_bottom).offset(2);
        make.right.equalTo(self.contentView);
        make.left.equalTo(operationLabel.mas_right).offset(5);
        make.height.equalTo(@15);
    }];
    [activityDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(operationLabel);
        make.right.equalTo(timeLabel.mas_left).offset(-30);
        make.height.width.equalTo(@18);
    }];
    [segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(operationLabel.mas_bottom).offset(10);
        make.left.equalTo(operationLabel.mas_left);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@0.5);
    }];
    
    [deviceInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(segmentView.mas_bottom).offset(5);
        make.left.equalTo(segmentView.mas_left);
        make.width.equalTo(self.contentView);
        make.height.equalTo(@12);
    }];
}

@end
