//
//  NXAccountInputCell.m
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAccountInputCell.h"

#import "Masonry.h"
#import "NXRMCDef.h"

@interface NXAccountInputCell()<UITextFieldDelegate>

@property(nonatomic, weak) UILabel *promptLabel;

@end

@implementation NXAccountInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}

- (void)setModel:(NXAccountInputCellModel *)model {
    if ([_model isEqual:model]) {
        return;
    }
    _model = model;
    
    self.textField.placeholder = model.placeholder;
    self.textField.text = [self textTwoLongDotsInMiddleWithStr:model.text];
    self.promptLabel.text = model.promptText;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
- (void)commonInit {
    NXAccountInputTextField *textField = [[NXAccountInputTextField alloc] init];
    UILabel *promptLabel = [[UILabel alloc] init];
    
    [self.contentView addSubview:promptLabel];
    [self.contentView addSubview:textField];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            
            [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView.mas_safeAreaLayoutGuideLeft).offset(kMargin * 2);
                make.right.equalTo(self.contentView.mas_safeAreaLayoutGuideRight).offset(-kMargin * 2);
                make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(kMargin/2);
            }];
            
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(promptLabel);
                make.right.equalTo(promptLabel);
                make.top.equalTo(promptLabel.mas_bottom);
                make.height.equalTo(@34);
                make.bottom.equalTo(self.contentView.mas_safeAreaLayoutGuideBottom).offset(-kMargin/2);
            }];
        }
    }
    else
    {
        [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kMargin * 2);
            make.right.equalTo(self.contentView).offset(-kMargin * 2);
            make.top.equalTo(self.contentView).offset(kMargin/2);
        }];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(promptLabel);
            make.right.equalTo(promptLabel);
            make.top.equalTo(promptLabel.mas_bottom);
            make.height.equalTo(@34);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-kMargin/2);
        }];
    }

    promptLabel.textColor = [UIColor lightGrayColor];
    promptLabel.font = [UIFont systemFontOfSize:14];
    
    textField.font = [UIFont systemFontOfSize:13];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate = self;
    
    self.promptLabel = promptLabel;
    _textField = textField;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //hidden separater line
    self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width *3, 0, 0);

#if 0
    textField.backgroundColor = [UIColor blueColor];
    promptLabel.backgroundColor = [UIColor redColor];
    self.backgroundColor = [UIColor orangeColor];
#endif
}
- (NSString *)textTwoLongDotsInMiddleWithStr:(NSString *)str {
    NSString *newStr = nil;
    if (str.length>35) {
        NSString *frontStr = [str substringToIndex:15];
        NSString *behindStr = [str substringFromIndex:str.length-15];
        NSString *dotStr = @"...";
        newStr = [NSString stringWithFormat:@"%@%@%@",frontStr,dotStr,behindStr];
        return newStr;
    }
    return str;
}
@end
