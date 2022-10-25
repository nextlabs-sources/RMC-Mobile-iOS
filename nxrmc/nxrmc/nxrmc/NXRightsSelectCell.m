//
//  NXRightsSelectCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXRightsSelectCell.h"

#import "Masonry.h"

#import "NXRightsCellModel.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "YYLabel.h"
#import "NXLFileValidateDateModel.h"
@interface NXRightsSelectCell ()<UIGestureRecognizerDelegate>

@property(nonatomic, weak) UILabel *titleLabel;

@end

@implementation NXRightsSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    
    if ([model.title isEqualToString:@"View"] || [model.title isEqualToString:@"Validity"]) {
        self.checkBoxButton.enabled = NO;
        [self.checkBoxButton setBackgroundImage:[UIImage imageNamed:@"disabled-selected"] forState:UIControlStateNormal];
    }else{
        self.checkBoxButton.selected = model.active;
    }
    self.switchButton.accessibilityValue = [NSString stringWithFormat:@"RIGHTS_SEL_SWITCH_%@", model.title];
    self.switchButton.accessibilityLabel =  [NSString stringWithFormat:@"RIGHTS_SEL_SWITCH_LAB_%@", model.title];
    NXLFileValidateDateModel *dateModel = [model.extDic objectForKey:@"VALIDITY_MODEL"];
    if (model.modelType == MODELTYPEValidity) {
        if (dateModel) {
            _fileValidityModel = dateModel;
        }else{
            _fileValidityModel = [NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate;
        }
       self.descriptionLabel.text = [_fileValidityModel getValidateDateDescriptionString];
    }
}

- (void)setFileValidityModel:(NXLFileValidateDateModel *)model
{
    _fileValidityModel = model;
    self.descriptionLabel.text = [_fileValidityModel getValidateDateDescriptionString];
}

//- (void)switchButtonClicked:(UISwitch *)switchButton {
//    self.model.active = switchButton.isOn;
//
//    if (self.actionBlock) {
//        self.actionBlock(switchButton.isOn);
//    }
//}
- (void)switchButtonClicked:(UIButton *)checkButton {
    self.model.active = checkButton.selected;
    checkButton.selected = !checkButton.selected;
    if (self.actionBlock) {
        self.actionBlock(checkButton.selected);
    }
}
- (void)onTapChangeLabel:(id)sender{
    if (self.tapChangeBlock) {
        self.tapChangeBlock(_fileValidityModel,self);
    }
}

#pragma mark
- (void)commonInit {
//    UISwitch *switchButton = [[UISwitch alloc]init];
//    [self.contentView addSubview:switchButton];
   //[self.contentView setBackgroundColor:[UIColor blueColor]];
    
    UILabel *label = [[UILabel alloc] init];
    [self.contentView addSubview:label];
    
    // for  nxl file validity
    YYLabel *descriptionLabel = [[YYLabel alloc] init];
//    descriptionLabel.textColor = [UIColor colorWithRed:172.0/255.0 green:172.0/255.0 blue:172.0/255.0 alpha:1.0];
    descriptionLabel.font = [UIFont systemFontOfSize:12.0];
   // descriptionLabel.text = @"Friday,November 3,2017 - Friday,December 29,2017"; //standard format for date range
    descriptionLabel.text = @"Friday,November 3,2017 - Friday,December 29,2017"; //standard format for
    descriptionLabel.numberOfLines = 0;
//    descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel = descriptionLabel;
    //descriptionLabel.backgroundColor  = [UIColor redColor];
    [self.contentView addSubview:descriptionLabel];
    
    UILabel *changeLabel = [[UILabel alloc] init];
    changeLabel.textAlignment = NSTextAlignmentLeft;
    changeLabel.textColor = [UIColor colorWithRed:74.0/255.0 green:143.0/255.0 blue:232.0/255.0 alpha:1.0];
    changeLabel.font = [UIFont italicSystemFontOfSize:14.0];
    UITapGestureRecognizer *changeLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapChangeLabel:)];
    changeLabelTapGestureRecognizer.delegate = self;
    [changeLabel addGestureRecognizer:changeLabelTapGestureRecognizer];
    changeLabel.userInteractionEnabled = YES;
    
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:@"Change" attributes:attribtDic];
    changeLabel.attributedText = attribtStr;
    self.changeLabel = changeLabel;
    [self.contentView addSubview:changeLabel];
    
//    [switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
//    switchButton.onTintColor = RMC_MAIN_COLOR;
//    switchButton.thumbTintColor = [UIColor whiteColor];
//    switchButton.tintColor = [UIColor lightGrayColor];
    UIButton *checkBoxBtn = [[UIButton alloc] init];
    [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"Selected"] forState:UIControlStateSelected];
    [checkBoxBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:checkBoxBtn];
    self.checkBoxButton = checkBoxBtn;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:kNormalFontSize];
    label.textAlignment = NSTextAlignmentCenter;
    
   // label.backgroundColor = [UIColor cyanColor];
    
    if (IS_IPHONE_X) {
         if (@available(iOS 11.0, *)) {
             
             [checkBoxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.left.equalTo(self.contentView.mas_safeAreaLayoutGuideLeft);
                 make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(10);
                 make.width.height.equalTo(@35);
             }];
             
             [label mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.left.equalTo(checkBoxBtn.mas_right).offset(kMargin * 1.5);
                 make.height.equalTo(@35);
                 make.centerY.equalTo(checkBoxBtn);
             }];
             
             [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.top.equalTo(checkBoxBtn.mas_bottom).offset(3);
                 make.left.equalTo(label);
                 make.right.equalTo(changeLabel.mas_left).offset(-kMargin/2);
                 make.height.equalTo(@50);
             }];
             
             [changeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.centerY.equalTo(descriptionLabel);
                 make.right.equalTo(self.contentView.mas_safeAreaLayoutGuideRight).offset(kMargin);
                 make.width.equalTo(@(60));
                 make.height.equalTo(@(20));
             }];
         }
    }
    else
    {
        
        [checkBoxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(10);
            make.width.height.equalTo(@35);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(checkBoxBtn.mas_right).offset(kMargin);
            make.centerY.equalTo(checkBoxBtn);
        }];
    
        [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(checkBoxBtn.mas_bottom).offset(3);
            make.left.equalTo(label);
            make.right.equalTo(changeLabel.mas_left).offset(-kMargin/2);
            make.height.equalTo(@50);
        }];
        [changeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(descriptionLabel);
            make.right.equalTo(self.contentView).offset(kMargin);
            make.width.equalTo(@(60));
            make.height.equalTo(@(20));
        }];
    }
    
    self.titleLabel = label;
//    self.switchButton = switchButton;
}

@end
