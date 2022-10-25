//
//  NXRepoCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/26.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXRepoCell.h"
#import "Masonry.h"
#import "NXRepositoryModel.h"
#import "NXRMCDef.h"
@interface NXRepoCell ()
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *accountLabel;
@property(nonatomic, strong) UIImageView *rightView;// @"accessoryIcon"
@property(nonatomic, strong) NSDictionary *repoIconDict;
@end
@implementation NXRepoCell

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
- (void)commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *iconView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconView];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView = iconView;
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.titleLabel = titleLabel;
    UILabel *accountLabel = [[UILabel alloc] init];
    [self.contentView addSubview:accountLabel];
    self.accountLabel = accountLabel;
    accountLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    UIImageView *rightView = [[UIImageView alloc] init];
    [self.contentView addSubview:rightView];
    self.rightView = rightView;
    rightView.contentMode = UIViewContentModeScaleAspectFit;
    [rightView setImage:[UIImage imageNamed:@"accessoryIcon"]];
    
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.font = [UIFont systemFontOfSize:15];

    accountLabel.adjustsFontSizeToFitWidth = YES;
    accountLabel.textColor = [UIColor grayColor];
    accountLabel.font = [UIFont systemFontOfSize:12];
    
   
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15);
        make.height.width.equalTo(self.contentView.mas_height).multipliedBy(0.5);
    }];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@(20));
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(15);
        make.right.equalTo(rightView.mas_left).offset(-10);
        make.top.equalTo(self.contentView).offset(10);
        make.height.equalTo(@25);
    }];
    [accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.left.right.height.equalTo(titleLabel);
        make.height.equalTo(@20);
        
    }];
    
}
- (void)setModel:(NXRepositoryModel *)model {
    _model = model;
    if (model.isAddItem) {
        if ([model.service_alias isEqualToString:@"Files"]) {
            self.iconView.image = [UIImage imageNamed:@"FilesIcon"];
        }else{
           self.iconView.image = [UIImage imageNamed:@"SkyDRMIcon"];
        }
        self.accountLabel.hidden = YES;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.iconView.mas_right).offset(15);
            make.right.equalTo(self.rightView.mas_left).offset(-10);
            make.height.equalTo(@20);
        }];
    }else{
        self.iconView.image = self.repoIconDict[model.service_type];
        self.accountLabel.hidden = NO;
        self.accountLabel.text = model.service_account;
       
    }
     self.titleLabel.text = model.service_alias;
    
}
- (NSDictionary *)repoIconDict {
    if (!_repoIconDict) {
        _repoIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - black"],
                          [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - black"],
                          [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - black"],
                          [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - black"],
                          [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-color"],
                          [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - black"],
                          [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive"],
                          [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - black"],
                          [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:[UIImage imageNamed:@"sharepoint - black"],
                          
        };
    }
    return _repoIconDict;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
