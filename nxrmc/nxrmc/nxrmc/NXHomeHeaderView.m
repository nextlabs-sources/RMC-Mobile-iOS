//
//  NXHomeHeaderView.m
//  nxrmc
//
//  Created by helpdesk on 10/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXHomeHeaderView.h"
#import "NXProcessPercentView.h"
#import "NXLoginUser.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "UIImage+Cutting.h"
#import "NXLProfile.h"
static const CGFloat kTopSpaces = 20.f;
@interface NXHomeHeaderView ()
@property(nonatomic, weak) UIButton *mySpaceButton;

@end
@implementation NXHomeHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}
#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    UILabel *welcome = [[UILabel alloc] init];
    [self addSubview:welcome];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [self addSubview:nameLabel];
    
    UIImageView *avaterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [self addSubview:avaterView];
    
    //   tim test
    self.percentView=[[NXProcessPercentView alloc]init];
    [self addSubview:self.percentView];
    
    welcome.text = @"Welcome ";
    welcome.textColor = [UIColor lightGrayColor];
    welcome.font = [UIFont systemFontOfSize:16];
    
    nameLabel.text = [NXLoginUser sharedInstance].profile.userName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    avaterView.image = [UIImage imageNamed:@"Account"];
    if ([NXLoginUser sharedInstance].profile.avatar) {
        avaterView.image = [UIImage imageWithBase64Str:[NXLoginUser sharedInstance].profile.avatar];
    }
    
    UIButton *spaceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:spaceButton];
    [spaceButton setTitle:@" Goto MySpace " forState:UIControlStateNormal];
    [spaceButton setTitleColor:[UIColor colorWithRed:48/256.0 green:128/256.0 blue:237/256.0 alpha:1] forState:UIControlStateNormal];
    [spaceButton addTarget:self action:@selector(GotoMySpace:) forControlEvents:UIControlEventTouchUpInside];
    spaceButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    self.mySpaceButton = spaceButton;
    _avaterImageView = avaterView;
    _nameLabel = nameLabel;
    
    [welcome mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kTopSpaces*1.5);
        make.left.equalTo(self).offset(kMargin * 2);
    }];
    
    
    [avaterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(welcome);
        make.right.equalTo(self).offset(-kMargin * 2);
        make.height.equalTo(@25);
        make.width.equalTo(@25);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(welcome);
        make.left.equalTo(welcome.mas_right).offset(kMargin);
        make.right.equalTo(avaterView.mas_left).offset(-kMargin);
    }];
    [self.percentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(avaterView.mas_bottom).offset(kTopSpaces*1.5);
        make.left.equalTo(welcome);
        make.right.equalTo(avaterView);
    }];
    
    [spaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.percentView.mas_bottom).offset(kTopSpaces);
        make.centerX.equalTo(self);
        make.height.equalTo(@44);
        make.width.equalTo(self).multipliedBy(0.4);
        make.bottom.equalTo(self).offset(-kTopSpaces);
    }];
}
#pragma mark ---->goto mySpace
- (void)GotoMySpace:(id)sender {
    if (self.goToMySpaceFinishedBlock) {
        self.goToMySpaceFinishedBlock(sender);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.mySpaceButton cornerRadian:5];
    [self.mySpaceButton borderWidth:0.2];
    [self.mySpaceButton borderColor:[UIColor lightGrayColor]];
    [_avaterImageView cornerRadian:25/2];
}


@end
