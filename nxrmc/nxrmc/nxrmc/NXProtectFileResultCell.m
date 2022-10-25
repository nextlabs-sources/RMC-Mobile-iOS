//
//  NXProtectFileResultCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/3/4.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXProtectFileResultCell.h"
#import "Masonry.h"
#import "NXFileBase.h"
#import "NXCommonUtils.h"
@implementation NXResultModel
@end

@interface NXProtectFileResultCell ()
@property(nonatomic, strong)UIImageView *fileIconImageView;
@property(nonatomic, strong)UIImageView *statusImageView;
@property(nonatomic, strong)UILabel *fileNameLabel;
@property(nonatomic, strong)UILabel *statusLabel;
@end
@implementation NXProtectFileResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonUIInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonUIInit];
    }
    return self;
}
- (void)commonUIInit {
    UIImageView *fileIconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:fileIconImageView];
    self.fileIconImageView = fileIconImageView;
    
    UIImageView *rightImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:rightImageView];
    self.statusImageView = rightImageView;
    
    UILabel *fileNameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:fileNameLabel];
    self.fileNameLabel = fileNameLabel;
    
    UILabel *statusLabel = [[UILabel alloc] init];
    self.statusLabel = statusLabel;
    [self.contentView addSubview:statusLabel];
    
    
    [fileIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kMargin);
        make.width.equalTo(@30);
        make.height.equalTo(@35);
    }];
    [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kMargin);
        make.height.width.equalTo(@30);
    }];
    [fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin*1.5);
        make.left.equalTo(fileIconImageView.mas_right).offset(kMargin*1.5);
        make.right.equalTo(rightImageView.mas_left).offset(-kMargin);
        make.height.equalTo(@30);
    }];
    [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileNameLabel.mas_bottom).offset(kMargin/2);
        make.left.right.equalTo(fileNameLabel);
        make.height.equalTo(@20);
        make.bottom.equalTo(self.contentView).offset(-kMargin*1.5);
    }];
    
}
- (void)setModel:(NXResultModel *)model {
    _model = model;
    NSString *imageName = [NXCommonUtils getImagebyExtension:model.fileItem.name];
    self.fileIconImageView.image = [UIImage imageNamed:imageName];
    self.fileNameLabel.text = model.fileItem.name;
    if (!model.isSuccess) {
        self.statusLabel.text = @"Unbale to protect";
        self.statusLabel.textColor = [UIColor redColor];
        self.statusImageView.image = [UIImage imageNamed:@"HighPriority"];
    }else{
        self.statusLabel.text = @"Successfully protected";
        self.statusLabel.textColor = RMC_MAIN_COLOR;
        self.statusImageView.image = [UIImage imageNamed:@"Allow"];
    }
}
@end
