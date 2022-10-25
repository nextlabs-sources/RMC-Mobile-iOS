//
//  NXNavigationBarView.m
//  AlphaVC
//
//  Created by helpdesk on 7/11/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXNavigationBarView.h"
#import "Masonry.h"

@implementation NXNavigationBarView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.leftBarBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftBarBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftBarBtn];
        self.leftBarLabel=[[UILabel alloc]init];
        [self addSubview:self.leftBarLabel];
        self.rightBarBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        self.rightBarBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        [self.rightBarBtn addTarget:self action:@selector(rightBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightBarBtn];
        self.rightBarBtn.hidden=YES;
        self.rightBarImageView=[[UIImageView alloc]init];
        self.rightBarImageView.image=[UIImage imageNamed:@"SkyDRM Logo - White - small"];
        [self addSubview:self.rightBarImageView];
        self.rightBarImageView.hidden=YES;
        
        [self.leftBarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(10);
            make.top.equalTo(self.mas_top).with.offset(5);
            make.width.equalTo(@(34));
            make.height.equalTo(@34);
            
        }];
        [self.leftBarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftBarBtn.mas_right).with.offset(5);
            make.top.equalTo(self.mas_top).with.offset(5);
            make.width.equalTo(@(100));
            make.height.equalTo(@34);
            
        }];
        [self.rightBarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).with.offset(-5);
            make.top.equalTo(self.mas_top).with.offset(5);
            make.width.equalTo(@(120));
            make.height.equalTo(@34);
            
        }];
        [self.rightBarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).with.offset(-10);
            make.top.equalTo(self.mas_top).with.offset(5);
            make.width.equalTo(@(130));
            make.height.equalTo(@30);
            
        }];
        [self setStyle:NXNavigationBarViewStyleSelected];
    }
    
        return self;
}
- (void)leftBarBtnClicked:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(leftBarBtnClicked:)]) {
        [self.delegate leftBarBtnClicked:sender];
    }
}
- (void)rightBarBtnClicked:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(rightBarBtnClicked:)]) {
        [self.delegate rightBarBtnClicked:sender];
    }
}
- (void)setStyle:(NXNavigationBarViewStyle)style{
    self.leftBarLabel.font=[UIFont boldSystemFontOfSize:17];
        if (style== NXNavigationBarViewStyleDefault) {
        [self.leftBarBtn setImage:nil forState:UIControlStateNormal];
        [self.leftBarBtn setImage:[UIImage imageNamed:@"Bulleted List_50"] forState:UIControlStateNormal];
        [self.leftBarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.leftBarLabel.text=@"Repositories";
         self.leftBarLabel.textColor=[UIColor whiteColor];
        self.rightBarImageView.hidden=NO;
        self.rightBarBtn.hidden=YES;
        self.backgroundColor = RMC_MAIN_COLOR;
    } else {
        [self.leftBarBtn setImage:[UIImage imageNamed:@"Cancel Black"] forState:UIControlStateNormal];
        self.leftBarLabel.text=@"Repositories";
        self.leftBarLabel.textColor=[UIColor blackColor];
        self.rightBarImageView.hidden=YES;
        self.rightBarImageView.contentMode=UIViewContentModeScaleAspectFit;
        self.rightBarBtn.hidden=NO;
        self.rightBarBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [self.rightBarBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
