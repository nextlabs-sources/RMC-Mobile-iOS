//
//  NXPeopleItemCell.m
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPeopleItemCell.h"

#import "Masonry.h"
#import "UIImage+Cutting.h"
#import "UIView+UIExt.h"
#import "NXLoginUser.h"
#import "NXProjectMemberHeaderView.h"

@interface NXPeopleItemCell()

@property(nonatomic, weak) UIImageView *thumbImageView;
@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, weak) UILabel *timeLabel;
@property(nonatomic, weak) UILabel *promptLabel;
@property(nonatomic, weak) UILabel *hostLabel;
@property(nonatomic, weak) NXProjectMemberHeaderView *headerView;

@end

@implementation NXPeopleItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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

- (void)setModel:(NXProjectMemberModel *)model {
    _model = model;
    [self.accessButton setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    self.accessButton.accessibilityValue = @"PROJECT_MEMBER_ACCESS_BUTTON";
    self.accessButton.userInteractionEnabled = YES;
    if (!model.isProjectOwner) {
        self.hostLabel.hidden = YES;
    } else {
        self.hostLabel.hidden = NO;
    }
    
    self.titleLabel.text = model.displayName;
    self.timeLabel.accessibilityValue = @"PROJECT_MEMEBER_NAME";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.joinTime]];
    self.timeLabel.text = strDate;
    
    self.promptLabel.text = NSLocalizedString(@"UI_COM_JOINED", NULL);
    
    UIImage *headImage = [UIImage imageWithBase64Str:model.avatarBase64];
    if (headImage) {
        self.headerView.hidden = YES;
        self.thumbImageView.hidden = NO;
        self.thumbImageView.image = headImage;
    }
    else
    {
//        self.thumbImageView.image = [UIImage imageNamed:@"Account"];
        self.thumbImageView.hidden = YES;
        self.headerView.hidden = NO;
        self.headerView.items = @[model.displayName];
    }
}

- (void)setPendingModel:(NXPendingProjectInvitationModel *)pendingModel {
    if (_pendingModel == pendingModel) {
        return;
    }
    self.titleLabel.text = pendingModel.inviteeEmail;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:pendingModel.inviteTime/1000]];
    self.timeLabel.text = strDate;
    self.promptLabel.text = NSLocalizedString(@"Invited ", NULL);
    //    self.thumbImageView.image = [UIImage imageNamed:@"Account"];
    self.headerView.items = @[pendingModel];
    self.thumbImageView.hidden = YES;
    self.headerView.hidden = NO;
    [self.accessButton setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    self.hostLabel.hidden = YES;
}

#pragma mark
- (void)accessViewClicked:(id)sender {
    if (self.accessBlock) {
        self.accessBlock(sender);
    }
}

- (void)commonInit {
    
    //file icon
    UIImageView *mainImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:mainImageView];
    NXProjectMemberHeaderView *headerView = [[NXProjectMemberHeaderView alloc]init];
    [self.contentView addSubview:headerView];
    UILabel *mainLabel = [[UILabel alloc] init];
    [self.contentView addSubview:mainLabel];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    [self.contentView addSubview: promptLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:timeLabel];
    UILabel *hostLabel = [[UILabel alloc]init];
    hostLabel.text = NSLocalizedString(@"UI_HOST", NULL);
    hostLabel.textAlignment = NSTextAlignmentCenter;
    hostLabel.backgroundColor = RMC_MAIN_COLOR;
    hostLabel.font = [UIFont boldSystemFontOfSize:12];
    hostLabel.textColor = [UIColor whiteColor];
    hostLabel.hidden = YES;
    [self.contentView addSubview:hostLabel];
    [hostLabel cornerRadian:3];
//    UIImageView *ownerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    ownerImageView.image = [UIImage imageNamed:@"Owner_40"];
//    self.accessoryView = ownerImageView;
    
    UIButton *accessButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.accessoryView = accessButton;
    
    [accessButton setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    accessButton.contentMode = UIViewContentModeScaleAspectFit;
    self.accessButton = accessButton;
    [accessButton addTarget:self action:@selector(accessViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [mainImageView cornerRadian:(30/2)];
    mainImageView.clipsToBounds = YES;
    
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.font = [UIFont boldSystemFontOfSize:14];
    mainLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    mainLabel.numberOfLines = 1;
    
    promptLabel.textColor = [UIColor lightGrayColor];
    promptLabel.font = [UIFont systemFontOfSize:12];
   
    
    timeLabel.textColor = [UIColor darkGrayColor];
    timeLabel.font = [UIFont boldSystemFontOfSize:12];
    
    self.thumbImageView = mainImageView;
    self.titleLabel = mainLabel;
    self.timeLabel = timeLabel;
    self.headerView = headerView;
    self.promptLabel = promptLabel;
    self.hostLabel = hostLabel;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
            }];
        }
    }
    
    [mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.height.equalTo(@30);
        make.width.equalTo(mainImageView.mas_height);
    }];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(11);
        make.height.equalTo(@32);
        make.width.equalTo(mainImageView.mas_height);
    }];
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(mainImageView.mas_right).offset(16);
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
    [hostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel);
        make.left.equalTo(timeLabel.mas_right).offset(kMargin);
        make.bottom.equalTo(timeLabel);
        make.width.equalTo(@45);
    }];
}

@end
