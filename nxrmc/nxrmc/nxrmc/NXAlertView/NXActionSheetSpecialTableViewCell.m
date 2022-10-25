//
//  NXActionSheetSpecialTableViewCell.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 10/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXActionSheetSpecialTableViewCell.h"

#import "NXActionSheetTableViewCell.h"
#import "Masonry.h"
#import "NXDefine.h"

@interface NXActionSheetSpecialTableViewCell ()

@property (nonatomic,strong) UILabel *promptLabel;
@property (nonatomic,strong) UIImageView *dividerImageView;
@end

@implementation NXActionSheetSpecialTableViewCell

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
    self.promptLabel.text = @"";
    self.promptLabel = nil;
    self.dividerImageView = nil;
    
    UILabel *promptLabel = [[UILabel alloc] init];
    
    promptLabel.font = [UIFont systemFontOfSize:14.0];
    promptLabel.textColor = [UIColor blackColor];
    promptLabel.textAlignment = NSTextAlignmentLeft;
    promptLabel.numberOfLines = 0;
    promptLabel.userInteractionEnabled = YES;
    self.promptLabel = promptLabel;
    
    [self addSubview:promptLabel];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(12);
        make.left.equalTo(self).offset(13);
        make.right.equalTo(self).offset(-5);
    }];
    
    UIImageView *dividerLineImageView = [[UIImageView alloc] init];
    dividerLineImageView.backgroundColor = [UIColor blackColor];
    self.dividerImageView = dividerLineImageView;
    [self addSubview:dividerLineImageView];
    
    [dividerLineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(14);
        make.top.equalTo(self).offset(18);
        make.height.equalTo(@2);
        make.width.equalTo(@135);
    }];
    
    if (item.promptTitle.length > 0) {
        self.promptLabel.text = item.promptTitle;
        [self.promptLabel setHidden:NO];
        self.backgroundColor = NXColor(237, 237, 241);
    }
    else
    {
        self.promptLabel.text = @"";
        [self.promptLabel setHidden:YES];
    }
    
    if (item.shouldDisplayDividerLine == YES)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self.dividerImageView setHidden:NO];
      
    }
    else
    {
        [self.dividerImageView setHidden:YES];
    }
    
    [self setUserInteractionEnabled:NO];
}

@end

