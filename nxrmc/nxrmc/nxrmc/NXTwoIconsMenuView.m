//
//  NXTwoIconsMenuView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXTwoIconsMenuView.h"
#import "Masonry.h"
#import "NXCardStyleView.h"
#import "HexColor.h"
@interface NXTwoIconsMenuView ()
@property(nonatomic, strong) NSString *firstNormalIconName;
@property(nonatomic, strong) NSString *firstSelectIconName;
@property(nonatomic, strong) NSString *secondNormalIconName;
@property(nonatomic, strong) NSString *secondSelectIconName;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImageView *firstIconView;
@property(nonatomic, strong) UIImageView *repoIconView;
@property(nonatomic, strong) UIView *cardView;
@property(nonatomic, strong) UILabel *titleLabel;
@end
@implementation NXTwoIconsMenuView
- (instancetype)initWithFirstNormalIconName:(NSString *)firstNormal firstSelectIconName:(NSString *)selectedName secondNormalIconName:(NSString *)secondNormal secondSelectIconName:(NSString *)secondSelectName title:(NSString *)title {
    if (self = [super init]) {
        _firstNormalIconName = firstNormal;
        _firstSelectIconName = selectedName;
        _secondNormalIconName = secondNormal;
        _secondSelectIconName = secondSelectName;
        _title = title;
        [self commonInitUI];
    }
    return self;
 
}
- (void)commonInitUI {
    NXCardStyleView *cardView = [[NXCardStyleView alloc] init];
    [self addSubview:cardView];
    self.cardView = cardView;
    UIImageView *selectIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.firstNormalIconName]];
    [self addSubview:selectIconView];
    self.firstIconView = selectIconView;
    UIImageView *typeIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.secondNormalIconName]];
    [self addSubview:typeIconView];
    typeIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.repoIconView = typeIconView;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleLabel.text = self.title;
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(selectedMenu:)];
    [self addGestureRecognizer:tap];
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [selectIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.width.height.equalTo(@20);
        make.left.equalTo(self).offset(5);
    }];
    [typeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.width.height.equalTo(@20);
        make.left.equalTo(selectIconView.mas_right).offset(2);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.6);
        make.left.equalTo(typeIconView.mas_right).offset(5);
        make.right.equalTo(self).offset(-5);
    }];
}
- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    if (!userInteractionEnabled) {
        self.cardView.backgroundColor = [HXColor colorWithHexString:@"#F1F1F1"];
        self.firstIconView.backgroundColor = [HXColor colorWithHexString:@"#F1F1F1"];
        self.titleLabel.textColor = [HXColor colorWithHexString:@"#BABABA"];
        self.firstIconView.tintColor = [HXColor colorWithHexString:@"#F1F1F1"];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    if (!self.userInteractionEnabled) {
        return;
    }
    _isSelected = isSelected;
    if (isSelected) {
        self.cardView.backgroundColor = RMC_MAIN_COLOR;
        self.firstIconView.image = [UIImage imageNamed:self.firstSelectIconName];
        self.repoIconView.image = [UIImage imageNamed:self.secondSelectIconName];
        self.titleLabel.textColor = [UIColor whiteColor];
    }else{
        self.cardView.backgroundColor = [UIColor whiteColor];
        self.firstIconView.image = [UIImage imageNamed:self.firstNormalIconName];
        self.repoIconView.image = [UIImage imageNamed:self.secondNormalIconName];
        self.titleLabel.textColor = [UIColor blackColor];
    }
}
- (void)cancelSelect {
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.firstIconView.image = [UIImage imageNamed:self.firstNormalIconName];
}
- (void)selectedMenu:(id)sender {
    self.isSelected = YES;
    if (self.selectedCompletion) {
        self.selectedCompletion();
    }
    
}
@end
