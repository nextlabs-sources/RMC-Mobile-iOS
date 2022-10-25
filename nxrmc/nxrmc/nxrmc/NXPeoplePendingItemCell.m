//
//  NXPeoplePendingItemCell.m
//  nxrmc
//
//  Created by helpdesk on 21/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXPeoplePendingItemCell.h"
#import "Masonry.h"
#import "UIImage+Cutting.h"
#import "UIView+UIExt.h"
#import "NXPendingProjectInvitationModel.h"
#import "NXProjectMemberHeaderView.h"
@interface NXPeoplePendingItemCell ()
@property(nonatomic, weak) UIImageView *thumbImageView;
@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, weak) UILabel *timeLabel;
@property(nonatomic, weak) NXProjectMemberHeaderView *headerView;
@property(nonatomic, weak) UIButton *accessButton;

@end
@implementation NXPeoplePendingItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}
- (void)setModel:(NXPendingProjectInvitationModel *)model {
    _model = model;
    
    [self.accessButton setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    
    self.titleLabel.text = model.inviteeEmail;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.inviteTime/1000]];
    self.timeLabel.text = strDate;
//    self.thumbImageView.image = [UIImage imageNamed:@"Account"];
    self.headerView.items = @[model.displayName];
}

- (void)commonInit {
    
    //file icon
//    UIImageView *mainImageView = [[UIImageView alloc] init];
//    [self.contentView addSubview:mainImageView];
    NXProjectMemberHeaderView *headerView = [[NXProjectMemberHeaderView alloc]init];
    [self.contentView addSubview:headerView];
    UILabel *mainLabel = [[UILabel alloc] init];
    [self.contentView addSubview:mainLabel];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    [self.contentView addSubview: promptLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:timeLabel];
    
    UIButton *accessButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.accessoryView = accessButton;
    
    [accessButton setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    accessButton.contentMode = UIViewContentModeScaleAspectFit;
    self.accessButton = accessButton;
    [accessButton addTarget:self action:@selector(accessViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.font = [UIFont boldSystemFontOfSize:14];
    mainLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    mainLabel.numberOfLines = 1;
    
    promptLabel.textColor = [UIColor lightGrayColor];
    promptLabel.font = [UIFont systemFontOfSize:12];
    promptLabel.text = NSLocalizedString(@"Invited ", NULL);
    
    timeLabel.textColor = [UIColor darkGrayColor];
    timeLabel.font = [UIFont boldSystemFontOfSize:12];
    
    self.headerView = headerView;
    self.titleLabel = mainLabel;
    self.timeLabel = timeLabel;
    
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(11);
        make.height.equalTo(@32);
        make.width.equalTo(headerView.mas_height);
    }];
    
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(headerView.mas_right).offset(16);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainLabel.mas_bottom).offset(kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.left.equalTo(mainLabel);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptLabel);
        make.left.equalTo(promptLabel.mas_right).offset(kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark
- (void)accessViewClicked:(id)sender {
    if (self.accessBlock) {
        self.accessBlock(sender);
    }
}

@end
