//
//  NXRepoTableViewCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/16.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXRepoTableViewCell.h"
#import "Masonry.h"
#import "NXRepositoryModel.h"
#import "NXCommonUtils.h"
@interface NXRepoTableViewCell ()
@property(nonatomic, strong)UIImageView *repoImageView;
@property(nonatomic, strong)UILabel *repoNameLabel;
@property(nonatomic, strong)UILabel *userNameLabel;
@property(nonatomic, strong)UIImageView *providerClassImageView;
@property(nonatomic, strong)UIImageView *rightImageView;
@end
@implementation NXRepoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    long maxWidth = [UIScreen mainScreen].bounds.size.width-10*2-30-10*2-20-25-28;
    UIImageView *repoIconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:repoIconImageView];
    self.repoImageView = repoIconImageView;
    repoIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *repoNameLabel = [[UILabel alloc] init];
    repoNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    repoNameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:repoNameLabel];
    self.repoNameLabel = repoNameLabel;
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:userNameLabel];
    self.userNameLabel = userNameLabel;
    userNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    userNameLabel.font = [UIFont systemFontOfSize:12];
    userNameLabel.textColor = [UIColor blueColor];
    
    UIImageView *providerClassImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:providerClassImageView];
    self.providerClassImageView = providerClassImageView;
    providerClassImageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImageView *rightImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:rightImageView];
    self.rightImageView = rightImageView;
    rightImageView.image = [UIImage imageNamed:@"accessoryIcon"];
    rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [self.repoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(self.contentView);
        make.height.width.equalTo(@40);
    }];
    [self.repoNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.repoImageView.mas_right).offset(10);
        make.width.lessThanOrEqualTo(@(maxWidth));
        make.height.equalTo(@30);
    }];
    [self.providerClassImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repoNameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.repoNameLabel);
        make.width.height.equalTo(@25);
    }];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-10);
        make.left.equalTo(self.repoNameLabel);
        make.top.equalTo(self.repoNameLabel.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@20);
        make.width.equalTo(@(20));
        make.right.equalTo(self.contentView).offset(-10);
    }];
}
- (void)setModel:(NXRepositoryModel *)model {
    _model = model;
    self.repoImageView.image = [NXCommonUtils getRepoIconByRepoType:model.service_type.integerValue];
    self.repoNameLabel.text = model.service_alias;
    self.providerClassImageView.image = [NXCommonUtils getProviderIconByRepoProviderClass:model.service_providerClass];
    self.userNameLabel.hidden = YES;
    if ([model.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", NULL)]) {
        [self.repoNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
        }];
    }else{
        [self.repoNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
        }];
        self.userNameLabel.hidden = NO;
        self.userNameLabel.text = model.service_account;
    }
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
