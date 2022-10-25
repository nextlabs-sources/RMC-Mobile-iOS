//
//  NXProfileCell.m
//  nxrmc
//
//  Created by nextlabs on 11/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXProfileCell.h"
#import "NXRMCDef.h"
#import "Masonry.h"

@interface NXProfileCell()

@end

@implementation NXProfileCell

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

- (void)setModel:(NXProfilePageCellModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
//    self.messageLabel.text = model.message;
    self.infoLabel.text = model.message;
    self.messageLabel.text = model.operation;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAccssViewHidden:(BOOL)accssViewHidden {
    if (_accssViewHidden == accssViewHidden) {
        return;
    }
    _accssViewHidden = accssViewHidden;
    if (_accssViewHidden) {
        [self removeCustomAccessView];
    } else {
        [self addCustomAccessView];
    }
    
    [self.contentView layoutIfNeeded];
}

- (void)removeCustomAccessView {
    [self.customAccessView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.and.with.equalTo(@0);
    }];

    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
            }];
        }
    }
    else
    {
        [self.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kMargin);
        }];
    }
}

- (void)addCustomAccessView {
    [self.customAccessView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
            }];
        }
    }
    else
    {
        [self.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.customAccessView.mas_left).offset(-kMargin/4);
        }];
    }
}

#pragma mark 
- (void)commonInit {

    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    [self.contentView addSubview:messageLabel];
    UILabel *infoLabel = [[UILabel alloc]init];
    [self.contentView addSubview:infoLabel];
    infoLabel.numberOfLines = 0;
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    [self.contentView addSubview:accessoryView];
    
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor blackColor];
    
    messageLabel.font = [UIFont systemFontOfSize:12];
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.textAlignment = NSTextAlignmentRight;
    infoLabel.font = [UIFont systemFontOfSize:12];
    accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                //        make.centerY.equalTo(self.contentView);
                make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(kMargin);
                make.left.equalTo(self.contentView.mas_safeAreaLayoutGuideLeft).offset(15);
                make.height.equalTo(@30);
            }];
            
            [accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_safeAreaLayoutGuideCenterY);
                make.right.equalTo(self.contentView.mas_safeAreaLayoutGuideRight).offset(-kMargin);
                make.height.equalTo(@20);
                make.width.equalTo(@20);
            }];
            
            [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_safeAreaLayoutGuideCenterY);
                make.right.equalTo(self.contentView.mas_safeAreaLayoutGuideRight).offset(-kMargin);
                make.width.equalTo(@80);
            }];
            [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(titleLabel.mas_bottom);
                make.left.equalTo(titleLabel);
                make.right.equalTo(messageLabel.mas_left).offset(-kMargin);
                make.bottom.equalTo(self.contentView).offset(-kMargin);
            }];
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.edges.equalTo(self).insets(self.safeAreaInsets);
                } else {
                    // Fallback on earlier versions
                    make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, kMargin, 0, kMargin));
                }
            }];
        }
    }
    else
    {
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            //        make.centerY.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(kMargin);
            make.left.equalTo(self.contentView).offset(15);
            make.height.height.equalTo(@30);
        }];
        
        [accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-kMargin);
            make.height.equalTo(@20);
            make.width.equalTo(@20);
        }];
        
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(accessoryView.mas_left).offset(-kMargin/4);
            make.width.equalTo(@80);
        }];
        [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom);
            make.left.equalTo(titleLabel);
            make.right.equalTo(messageLabel.mas_left).offset(-kMargin);
            make.bottom.equalTo(self.contentView).offset(-kMargin);
        }];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
   
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, kMargin, 0, kMargin));
        }];
    }
    
//    self.layoutMargins = UIEdgeInsetsZero;
//    self.preservesSuperviewLayoutMargins = NO;
    self.separatorInset = UIEdgeInsetsMake(0, kMargin * 2, 0, kMargin);
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _titleLabel = titleLabel;
    _messageLabel = messageLabel;
    _customAccessView = accessoryView;
    _infoLabel = infoLabel;
    if (self.accssViewHidden) {
        [self removeCustomAccessView];
    } else {
        [self addCustomAccessView];
    }
    
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

@end
