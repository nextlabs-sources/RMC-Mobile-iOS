//
//  NXPeopleInfoHeaderView.m
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPeopleInfoHeaderView.h"

#import "UIView+UIExt.h"
#import "Masonry.h"

@interface NXPeopleInfoHeaderView ()

@property(nonatomic, weak) UIImageView *avatarImageView;
@property(nonatomic, weak) UILabel *nameLabel;
@property(nonatomic, weak) UILabel *timeLabel;

@end

@implementation NXPeopleInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.avatarImageView borderColor:[UIColor whiteColor]];
    [self.avatarImageView borderWidth:5];
    [self.avatarImageView cornerRadian:self.avatarImageView.bounds.size.width/2];
    self.avatarImageView.clipsToBounds = YES;
}

- (void)setModel:(id)model {
    _model = model;
    self.avatarImageView.image = [UIImage imageNamed:@"Profile"];
    self.nameLabel.text  = @"Alexander Zaytsev";
    self.timeLabel.attributedText = [self timeStr:@"13 Nov 2015"];
}

- (NSAttributedString *)timeStr:(NSString *)modelStr {
    NSMutableAttributedString *prompt = [[NSMutableAttributedString alloc] initWithString:@"Joined on " attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    
    NSAttributedString *modeAttristr = [[NSAttributedString alloc] initWithString:modelStr attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [prompt appendAttributedString:modeAttristr];
    return prompt;
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    UIImageView *avatorImageView = [[UIImageView alloc] init];
    [self addSubview:avatorImageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview:titleLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    [self addSubview:timeLabel];
    
    avatorImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatorImageView.userInteractionEnabled = YES;
    
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.avatarImageView = avatorImageView;
    self.timeLabel = timeLabel;
    self.nameLabel = titleLabel;
    
    [avatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.centerX.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.4);
        make.width.equalTo(avatorImageView.mas_height);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(avatorImageView.mas_bottom).offset(kMargin);
        make.left.equalTo(self).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(kMargin);
        make.left.equalTo(self).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin);
    }];
#if 1
    avatorImageView.image = [UIImage imageNamed:@"Profile"];
#endif
}

@end
