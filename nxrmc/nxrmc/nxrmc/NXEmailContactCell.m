//
//  NXEmailContactCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXEmailContactCell.h"
#import "Masonry.h"
#import "NXProjectMemberHeaderView.h"
#import "NXLocalContactsVC.h"
#import "NXRMCDef.h"
@interface NXEmailContactCell ()
@property(nonatomic, strong)NXProjectMemberHeaderView *headerView;
@property(nonatomic, strong)UILabel *fullNameLabel;
@property(nonatomic, strong)NXEmailBtnsView *emailView;
@end
@implementation NXEmailContactCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    NXProjectMemberHeaderView *headerView = [[NXProjectMemberHeaderView alloc]init];
    [self.contentView addSubview:headerView];
    headerView.sizeWidth = 35;
    self.headerView = headerView;
    UILabel *fullNameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:fullNameLabel];
    self.fullNameLabel = fullNameLabel;
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin * 1.5);
        make.left.equalTo(self.contentView).offset(kMargin);
        make.width.height.equalTo(@35);
    }];
    [fullNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(headerView.mas_right).offset(kMargin * 1.5);
        make.right.equalTo(self.contentView).offset(-kMargin);
        make.height.equalTo(@25);
    }];
}
- (void)setContactModel:(NXEmailContact *)contactModel {
    _contactModel = contactModel;
    self.fullNameLabel.text = contactModel.fullName;
    self.headerView.items = @[contactModel.fullName];
    if (self.emailView) {
        [self.emailView removeFromSuperview];
        self.emailView = nil;
    }
    self.emailView = [[NXEmailBtnsView alloc]initWithTitlesArray:contactModel.emails];
    [self.contentView addSubview:self.emailView];
    WeakObj(self);
    self.emailView.emailBtnClicked = ^(NSString *emailStr) {
        StrongObj(self);
        if ([self.delegate respondsToSelector:@selector(emailBtnWhichTitle:ClickedFromEmailBtnView:)]) {
            [self.delegate emailBtnWhichTitle:emailStr ClickedFromEmailBtnView:self.emailView];
        }
    };
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fullNameLabel.mas_bottom).offset(kMargin/2);
        make.left.equalTo(self.headerView.mas_right).offset(kMargin);
        make.right.equalTo(self.contentView).offset(-kMargin);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
}
@end
@implementation NXEmailBtnsView

- (instancetype)initWithTitlesArray:(NSArray *)titles {
    if (self = [super init]) {
        if (titles.count) {
            [self commonInitWithTitles:titles];
        }
    }
    return self;
}
- (void)commonInitWithTitles:(NSArray *)titles {
    UIButton *lastBtn = nil;
    for (int i = 0; i<titles.count; i++) {
        UIButton *emailBtn = [[UIButton alloc]init];
        [emailBtn setTitle:titles[i] forState:UIControlStateNormal];
        emailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [emailBtn setTitleColor:[UIColor colorWithRed:47.0/255.0 green:128.0/255.0 blue:237.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [emailBtn addTarget:self action:@selector(emailBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:emailBtn];
        if (titles.count > 1) {
            if (i == 0) {
                [emailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).offset(5);
                    make.left.equalTo(self).offset(5);
                    make.right.equalTo(self).offset(-5);
                    make.height.equalTo(@30);
                }];
            }else if(i == titles.count - 1){
                [emailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastBtn.mas_bottom).offset(5);
                    make.left.equalTo(self).offset(5);
                    make.right.equalTo(self).offset(-5);
                    make.height.equalTo(@30);
                    make.bottom.equalTo(self).offset(-5);
                }];
            }else if (i>0&&i<titles.count-1){
                [emailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastBtn.mas_bottom).offset(5);
                    make.left.equalTo(self).offset(5);
                    make.right.equalTo(self).offset(-5);
                    make.height.equalTo(@30);
                }];
            }
            lastBtn = emailBtn;
        }else{
            [emailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(5);
                make.left.equalTo(self).offset(5);
                make.right.equalTo(self).offset(-5);
                make.height.equalTo(@30);
                make.bottom.equalTo(self).offset(-5);
            }];
        }
        
        
    }
}
- (void)emailBtnClicked:(UIButton *)sender {
    if (self.emailBtnClicked) {
        self.emailBtnClicked(sender.currentTitle);
    }
}
@end
