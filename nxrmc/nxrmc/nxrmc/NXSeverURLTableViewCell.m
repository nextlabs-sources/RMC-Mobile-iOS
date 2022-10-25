//
//  NXSeverURLTableViewCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/6/27.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXSeverURLTableViewCell.h"
#import "Masonry.h"
#import "NXRMCDef.h"
@interface NXSeverURLTableViewCell ()
@property (nonatomic, strong) UIImageView *selectView;
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation NXSeverURLTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setFrame:(CGRect)frame {
    frame.origin.x += kMargin * 2;
    frame.size.width -= kMargin * 4;
    [super setFrame:frame];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)setUrlStr:(NSString *)urlStr {
    _urlStr = urlStr;
    self.titleLabel.text = urlStr;
//    [self layoutSubviews];
}
- (void)commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"selectedIcon"];
    [self.contentView addSubview:imageView];
    self.selectView = imageView;
    imageView.hidden = YES;
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:titleLabel];
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel = titleLabel;
    UIButton *editBtn = [[UIButton alloc]init];
    [editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor colorWithRed:100/256.0 green:160/256.0 blue:240/256.0 alpha:1] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(editURL:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:editBtn];
    
    
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@25);
        make.width.equalTo(imageView.mas_height);
        make.left.equalTo(self.contentView).offset(kMargin);
    }];
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.and.height.equalTo(@40);
        make.right.equalTo(self.contentView).offset(-kMargin);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(kMargin);
        make.right.equalTo(editBtn.mas_left).offset(-kMargin);
        make.top.equalTo(self.contentView).offset(kMargin/2);
        make.bottom.equalTo(self.contentView).offset(-kMargin/2);
    }];
}
- (void)editURL:(id)sender {
    if (self.editURLHandle) {
        self.editURLHandle(self.urlStr);
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.selectView.hidden = NO;
    } else {
        self.selectView.hidden = YES;
    }
    // Configure the view for the selected state
}

@end
