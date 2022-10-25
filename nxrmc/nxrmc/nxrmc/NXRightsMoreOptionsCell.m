//
//  NXRightsMoreOptionsCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/6/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXRightsMoreOptionsCell.h"
#import "Masonry.h"
#import "NXRightsCellModel.h"
@interface NXRightsMoreOptionsCell ()
@property(nonatomic, strong)UILabel *titleLabel;
//@property(nonatomic, strong)UISwitch *switchButton;
@property(nonatomic, strong) UIButton *checkBoxButton;
@end

@implementation NXRightsMoreOptionsCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}
- (void)setModel:(NXRightsCellModel *)model {
    if (_model == model) {
        return;
    }
    _model = model;
    self.titleLabel.text = model.title;
    self.checkBoxButton.selected = model.active;
}
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
//    UISwitch *switchButton = [[UISwitch alloc]init];
//    [self.contentView addSubview:switchButton];
//    [switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
//    switchButton.onTintColor = RMC_MAIN_COLOR;
//    switchButton.thumbTintColor = [UIColor whiteColor];
//    switchButton.tintColor = [UIColor lightGrayColor];
//    self.switchButton = switchButton;
    UIButton *checkBoxBtn = [[UIButton alloc] init];
    [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"Selected"] forState:UIControlStateSelected];
    [checkBoxBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:checkBoxBtn];
    self.checkBoxButton = checkBoxBtn;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kMargin * 4);
        make.width.equalTo(@150);
        make.height.equalTo(@40);
    }];
    [checkBoxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kMargin * 4);
        make.width.height.equalTo(@35);
    }];
}
- (void)switchButtonClicked:(UIButton *)checkButton {
    checkButton.selected = !checkButton.selected;
    self.model.active = checkButton.selected;
    if (self.actionBlock) {
        self.actionBlock(checkButton.selected);
    }
}
@end
