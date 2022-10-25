//
//  NXProjectMemberDetailHeaderView.m
//  nxrmc
//
//  Created by xx-huang on 06/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectMemberDetailHeaderView.h"
#import "UIView+UIExt.h"
#import "Masonry.h"
#import "UIImage+Cutting.h"
#import "NXProjectMemberHeaderView.h"
@interface NXProjectMemberDetailHeaderView()

@end

@implementation NXProjectMemberDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.avatarImageView cornerRadian:self.avatarImageView.bounds.size.width/2];
    self.avatarImageView.clipsToBounds = YES;
}

#pragma mark
- (void)commonInit {
    UIImageView *avatorImageView = [[UIImageView alloc] init];
    UILabel *nameLabel = [[UILabel alloc] init];
    UILabel *joinTimeLabel = [[UILabel alloc] init];
    NXProjectMemberHeaderView *memheaderLabel = [[NXProjectMemberHeaderView alloc]init];
    memheaderLabel.hidden = YES;
    avatorImageView.hidden = YES;
//    UILabel *invitedByLabel = [[UILabel alloc] init];
    [self addSubview:avatorImageView];
    [self addSubview:nameLabel];
    [self addSubview:joinTimeLabel];
    [self addSubview:memheaderLabel];
//    [self addSubview:invitedByLabel];
    
    avatorImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatorImageView.userInteractionEnabled = YES;
    
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.userInteractionEnabled = YES;
    
    joinTimeLabel.font = [UIFont systemFontOfSize:14];
    joinTimeLabel.textColor = [UIColor blackColor];
    joinTimeLabel.textAlignment = NSTextAlignmentCenter;
    joinTimeLabel.userInteractionEnabled = YES;
    
//    invitedByLabel.font = [UIFont systemFontOfSize:14];
//    invitedByLabel.textColor = [UIColor blackColor];
//    invitedByLabel.textAlignment = NSTextAlignmentCenter;
//    invitedByLabel.userInteractionEnabled = YES;
    _avatarImageView = avatorImageView;
    _nameLabel = nameLabel;
    _joinTimeLabel = joinTimeLabel;
    _memHeaderLabel = memheaderLabel;
//    _invitedByLabel = invitedByLabel;
    self.backgroundColor = [UIColor whiteColor];
    
    [avatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin*3);
        make.centerX.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.3);
        make.width.equalTo(avatorImageView.mas_height);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(avatorImageView.mas_bottom).offset(kMargin*3.5);
        make.centerX.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.9);
    }];
    
    [joinTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(kMargin *4);
        make.centerX.equalTo(self);
    }];
    [_memHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin*3);
        make.centerX.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.3);
        make.width.equalTo(avatorImageView.mas_height);
    }];
//    [invitedByLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(joinTimeLabel.mas_bottom).offset(kMargin * 3);
//        make.centerX.equalTo(self);
//        make.width.equalTo(self).multipliedBy(0.9);
//    }];
}
- (void)setNameStr:(NSString *)nameStr {
    self.memHeaderLabel.hidden = NO;
    self.memHeaderLabel.items = @[nameStr];
    self.memHeaderLabel.sizeWidth = 80;
}
@end
