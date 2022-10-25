//
//  projectContentTableViewCell.m
//  nxrmc
//
//  Created by xx-huang on 07/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectMemberDetailCell.h"
#import "Masonry.h"

@implementation dataModel

- (instancetype)initWithTittle:(NSString *)tittle content:(NSString *)content
{
    self = [super init];
    
    if (self) {
        self.title = tittle;
        self.content = content;
    }
    
    return self;
}

@end

@interface NXProjectMemberDetailCell ()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation NXProjectMemberDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithMemberModel:(NXProjectMemberModel *)memberModel
{
   
}

- (void)configureCellWithDataModel:(dataModel *)model
{
    UILabel *titleLabel = [[UILabel alloc] init];
    UILabel *contentLabel = [[UILabel alloc] init];
    
    [self addSubview:titleLabel];
    [self addSubview:contentLabel];
    
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.userInteractionEnabled = YES;
    titleLabel.text = model.title;
    
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.userInteractionEnabled = YES;
    contentLabel.text = model.content;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.left.equalTo(self).offset(kMargin*5);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel).offset(kMargin*2);
        make.left.equalTo(self).offset(kMargin*5);
    }];
}

@end
