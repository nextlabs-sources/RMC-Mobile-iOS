//
//  NXSetSeverURLView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/4/24.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXSetSeverURLView.h"
#import "Masonry.h"
#import "NXCommonUtils.h"
@interface NXSetSeverURLView ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UISwitch *remberSwitch;
@property (nonatomic, strong) UILabel *remberLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *lineLabel;
@property (nonatomic, strong) UILabel *hintURLLabel;
@property (nonatomic, strong) UILabel *changeURLLabel;
@property (nonatomic, strong) UIButton *manageURLBtn;
@end
@implementation NXSetSeverURLView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)tap:(id)sender {
    [self.textField resignFirstResponder];
}
- (void)closeTheKeyBoard {
     [self.textField resignFirstResponder];
}
- (void)setUrlViewType:(NXSetSeverURLViewType)urlViewType {
    _urlViewType = urlViewType;
    self.hintURLLabel.textColor = [UIColor lightGrayColor];
    self.changeURLLabel.hidden = YES;
    self.remberSwitch.hidden = YES;
    self.remberLabel.hidden = YES;
    self.manageURLBtn.hidden = YES;
    self.textField.rightView = nil;
    self.textField.text = nil;
    switch (urlViewType) {
         case NXSetSeverURLViewTypeCommanyEdit:
            self.hintURLLabel.text = NSLocalizedString(@"UI_ENTER_URL", NULL);
            self.textField.textColor = [UIColor blackColor];
            self.textField.placeholder = @"example https://nextlabs.com";
            self.changeURLLabel.hidden = NO;
            self.remberSwitch.hidden = NO;
            self.remberLabel.hidden = NO;
            break;
        case NXSetSeverURLViewTypeCommanySelect:
            self.hintURLLabel.text = @"Company account URL";
            self.manageURLBtn.hidden = NO;
            UIButton *button = [[UIButton alloc]init];
            [button setBackgroundImage:[UIImage imageNamed:@"down arrow - black1"] forState:UIControlStateNormal];
            button.bounds = CGRectMake(0, 0, 20, 10);
            [button addTarget:self action:@selector(pullDown:) forControlEvents:UIControlEventTouchUpInside];
            self.textField.rightView = button;
            self.textField.rightViewMode = UITextFieldViewModeAlways;
            self.textField.textColor = [UIColor blackColor];
            break;
    }
}
- (void)commonInit {
    UILabel *enterURLLabel = [[UILabel alloc]init];
    enterURLLabel.text = NSLocalizedString(@"UI_ENTER_SERVER_URL", NULL);
    [self addSubview:enterURLLabel];
    self.hintURLLabel = enterURLLabel;
    UITextField *textField = [[UITextField alloc]init];
    textField.keyboardType = UIKeyboardTypeURL;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    enterURLLabel.font = [UIFont systemFontOfSize:17];
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.backgroundColor = [UIColor whiteColor];
    textField.accessibilityValue = @"SETURL_TEXTFIELD";
    
    [self addSubview:textField];
    self.textField = textField;
    UILabel *lineLabel = [[UILabel alloc]init];
    [self addSubview:lineLabel];
    lineLabel.backgroundColor = [UIColor blackColor];
    self.lineLabel = lineLabel;
    UILabel *changeURLLabel = [[UILabel alloc]init];
    changeURLLabel.text = NSLocalizedString(@"UI_YOU_CAN_CHANGE_THE_URL", NULL);
    changeURLLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:changeURLLabel];
    self.changeURLLabel = changeURLLabel;
    UIButton *manageURLBtn = [[UIButton alloc]init];
    [manageURLBtn setTitle:NSLocalizedString(@"UI_MANAGE_URL", NULL) forState:UIControlStateNormal];
    [manageURLBtn setTitleColor:[UIColor colorWithRed:100/256.0 green:160/256.0 blue:240/256.0 alpha:1] forState:UIControlStateNormal];
    [self addSubview:manageURLBtn];
    [manageURLBtn addTarget:self action:@selector(manageURLBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    manageURLBtn.accessibilityValue = @"MANAGE_URL_BUTTON";
    
    self.manageURLBtn = manageURLBtn;
    UISwitch *remberSwitch = [[UISwitch alloc]init];
    remberSwitch.onTintColor = RMC_MAIN_COLOR;
    [remberSwitch setOn:YES];
    remberSwitch.tintColor = [UIColor colorWithRed:246/256.0 green:246/256.0 blue:246/256.0 alpha:1];
    remberSwitch.thumbTintColor = [UIColor lightGrayColor];
    self.remberSwitch = remberSwitch;
    [self addSubview:remberSwitch];
    UILabel *remberLabel = [[UILabel alloc]init];
    remberLabel.text = NSLocalizedString(@"UI_REMEMBER_URL", NULL);
    remberLabel.font = [UIFont systemFontOfSize:16];
    self.remberLabel = remberLabel;
    [self addSubview:remberLabel];
    UILabel *errorLabel = [[UILabel alloc]init];
    errorLabel.text = NSLocalizedString(@"UI_THE_URL_IS_NOT_VALID", NULL);
    errorLabel.textColor = [UIColor redColor];
    enterURLLabel.font = [UIFont systemFontOfSize:14];
    errorLabel.hidden = YES;
    self.errorLabel = errorLabel;
    [self addSubview:errorLabel];
    
    [enterURLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(5);
        make.right.equalTo(self).offset(-5);
        make.height.equalTo(@30);
    }];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(enterURLLabel.mas_bottom).offset(kMargin);
        make.left.right.equalTo(enterURLLabel);
        make.height.equalTo(@40);
    }];
    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom);
        make.left.right.equalTo(textField);
        make.height.equalTo(@1);
    }];
    [changeURLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineLabel.mas_bottom);
        make.left.equalTo(lineLabel);
        make.height.equalTo(@30);
    }];
    [manageURLBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(changeURLLabel);
        make.right.equalTo(lineLabel);
    }];
    [remberSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(changeURLLabel.mas_bottom).offset(kMargin * 2);
        make.left.equalTo(enterURLLabel);
    }];
    [remberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(remberSwitch);
        make.left.equalTo(remberSwitch.mas_right).offset(kMargin * 3);
        make.right.equalTo(enterURLLabel);
    }];
    [errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remberSwitch.mas_bottom).offset(kMargin * 2);
        make.right.left.equalTo(enterURLLabel);
        make.bottom.equalTo(self).offset(-kMargin);
    }];
}
- (void)manageURLBtnClick:(id)sender {
    if (self.manageUrlBlock) {
        self.manageUrlBlock();
    }
}
- (void)pullDown:(id)sender {
    if (self.pullDownBlock) {
        self.pullDownBlock();
    }
}
- (BOOL)isRemberURL {
    if (self.remberSwitch.isOn) {
        return YES;
    }
    return NO;
}
- (NSString *)URLStr {
    return self.textField.text;
}
- (void)setURLStr:(NSString *)URLStr {
    self.textField.text = URLStr;
}
- (void)showErrorMessage {
    self.lineLabel.backgroundColor = [UIColor redColor];
    self.errorLabel.hidden = NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.errorLabel.hidden = YES;
    self.lineLabel.backgroundColor = [UIColor blackColor];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.urlViewType == NXSetSeverURLViewTypeCommanyEdit) {
        return YES;
    }
    return NO;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.errorLabel.hidden = YES;
    self.lineLabel.backgroundColor = [UIColor blackColor];
}
@end
