//
//  NXWaterMarkView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 10/11/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXWaterMarkView.h"
#import "YYText.h"
#import "Masonry.h"
#import "NXWatermarkWord.h"
#import "NXDateWatermarkWord.h"
#import "NXTimeWatermarkWord.h"
#import "NXNormalWatermarkWord.h"
#import "NSString+NXExt.h"
#import "UIView+UIExt.h"

#define  LIMITSTRNUMBER 50
#define  LINEBREAKSTR @"Line break"
#define  BORDERCOLOR [UIColor colorWithRed:203/255.0 green:234/255.0 blue:208/255.0 alpha:1]
#define  LINEBREAKCOLOR  [UIColor colorWithRed:244/255.0 green:140/255.0 blue:66/255.0 alpha:1]
@interface NXWaterMarkView ()<UIGestureRecognizerDelegate,YYTextViewDelegate>
@property (nonatomic, strong)YYTextView *textView;
@property (nonatomic, strong)UILabel *strNumLabel;
@property (nonatomic, strong)UIView *presetValueView;
@property (nonatomic, strong)UILabel *warnLabel;
@property (nonatomic, strong)NSMutableArray *valueForBtns;
@property (nonatomic, strong)NSMutableArray *nowValuesForTextViews;
@property (nonatomic, strong)NSMutableArray *lastValuesForTextViews;
@property (nonatomic, strong)NSMutableArray *valuesArray;
@property (nonatomic, strong)NSMutableAttributedString *originalText;
@end
@implementation NXWaterMarkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self commonInit];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
- (void)setOrigialWaterMarks:(NSArray *)origialWaterMarks {
    _origialWaterMarks = origialWaterMarks;
    NSMutableAttributedString *textStr = [[NSMutableAttributedString alloc]init];
    NSMutableString *numStr = [[NSMutableString alloc]init];
    if (origialWaterMarks) {
        for (NXWatermarkWord *word in origialWaterMarks) {
            NSString *UIStr = [word watermarkTextViewUIString];
            if (UIStr && ![UIStr isEqualToString:@""]) {
            if ([word isKindOfClass:[NXNormalWatermarkWord class]]) {
                [textStr appendAttributedString:[[NSAttributedString alloc]initWithString:UIStr]];
                [numStr appendString:UIStr];
            } else {
                NSMutableAttributedString *borderStr = [self getBackBorderAndColorAuttributedStringWithBaseString:UIStr];
                [textStr appendAttributedString:borderStr];
                [self.nowValuesForTextViews addObject:UIStr];
            }
            }
        }
    }
    self.originalText = textStr;
    self.originalText.yy_lineSpacing = 15;
    NSMutableSet *valuesSet = [[NSMutableSet alloc]initWithArray:self.valuesArray];
    NSMutableSet *nowValueSet = [[NSMutableSet alloc]initWithArray:self.nowValuesForTextViews];
    [valuesSet minusSet:nowValueSet];
    if (valuesSet.count > 0) {
        for (NSString *str in valuesSet) {
            [self.valueForBtns addObject:str];
        }
    }
    [self updateInitPresetValuesLabel];
    self.originalText.yy_font = [UIFont systemFontOfSize:17];
    self.textView.attributedText = self.originalText;
}

- (NSMutableArray *)valuesArray {
    if (!_valuesArray) {
        _valuesArray = @[@"Date",@"Time",@"UserID",LINEBREAKSTR].mutableCopy;
    }
    return _valuesArray;
}
- (NSMutableArray *)valueForBtns {
    if (!_valueForBtns) {
        _valueForBtns = [NSMutableArray array];
    }
    return _valueForBtns;
}
- (NSMutableArray *)nowValuesForTextViews {
    if (!_nowValuesForTextViews) {
        _nowValuesForTextViews = [NSMutableArray array];
    }
    return _nowValuesForTextViews;
}
- (NSMutableArray *)lastValuesForTextViews {
    if (!_lastValuesForTextViews) {
        _lastValuesForTextViews = [NSMutableArray array];
    }
    return _lastValuesForTextViews;
}
- (void)updateInitPresetValuesLabel {
    for (UIView *subView in self.presetValueView.subviews) {
        [subView removeFromSuperview];
    }
    if ([self.valueForBtns containsObject:LINEBREAKSTR]) {
        [self.valueForBtns removeObject:LINEBREAKSTR];
    }
    UIButton *currrentBtn = nil;
    for (int i = 0; i < self.valueForBtns.count; i++) {
        NSString *typeStr = self.valueForBtns[i];
        UIButton *presetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        presetBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [presetBtn setTitle:typeStr forState:UIControlStateNormal];
        presetBtn.backgroundColor = BORDERCOLOR;
        [presetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [presetBtn addTarget:self action:@selector(addPresetValuesToTextView:) forControlEvents:UIControlEventTouchUpInside];
        [self.presetValueView addSubview:presetBtn];
        [presetBtn cornerRadian:5];
        if (i == 0) {
            [presetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.equalTo(self.presetValueView);
                make.height.equalTo(@30);
            }];
        }else {
            [presetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.presetValueView);
                make.left.equalTo(currrentBtn.mas_right).offset(5);
                make.height.equalTo(@30);
            }];
        }
        currrentBtn = presetBtn;
    }
    
}
-(void)commonInit {
    
    UIImageView *exclamationMarkIcon = [[UIImageView alloc] init];
    [exclamationMarkIcon setImage:[UIImage imageNamed:@"Vector"]];
    [self addSubview:exclamationMarkIcon];
    
    UILabel *hintLabel = [[UILabel alloc]init];
    hintLabel.textColor = [UIColor grayColor];
    hintLabel.numberOfLines = 0;
    hintLabel.font = [UIFont boldSystemFontOfSize:12];
    hintLabel.text = @"Edit the existing watermark by either typing a custom value or selecting the preset values.";
    [self addSubview:hintLabel];

    YYTextView *textView = [[YYTextView alloc]init];
    [self addSubview:textView];
    textView.delegate = self;
    self.textView = textView;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    tapGesture.delegate = self;
    [textView addGestureRecognizer:tapGesture];
    textView.layer.borderColor = [UIColor blackColor].CGColor;
    textView.layer.borderWidth = 1;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    textView.font = [UIFont systemFontOfSize:20];
    textView.scrollIndicatorInsets = textView.contentInset;
    
    UILabel *warnLabel = [[UILabel alloc]init];
    [self addSubview:warnLabel];
    warnLabel.textColor = [UIColor redColor];
    warnLabel.font = [UIFont systemFontOfSize:12];
    UILabel *strNumberLabel = [[UILabel alloc]init];
    warnLabel.numberOfLines = 0;
    self.warnLabel = warnLabel;
    strNumberLabel.text = @"50/50";
    [self addSubview:strNumberLabel];
    self.strNumLabel = strNumberLabel;
    UILabel *addPresetLabel = [[UILabel alloc]init];
    addPresetLabel.text = @"Add preset values";
    addPresetLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:addPresetLabel];
    
    UIView *presetValuesView = [[UIView alloc]init];
    [self addSubview:presetValuesView];
    self.presetValueView = presetValuesView;
    
    UIButton *addLineBtn = [[UIButton alloc]init];
    [addLineBtn setTitle:@"Add line break" forState:UIControlStateNormal];
    [addLineBtn addTarget:self action:@selector(addLineBreak:) forControlEvents:UIControlEventTouchUpInside];
    [addLineBtn setImage:[UIImage imageNamed:@"LineBreak"] forState:UIControlStateNormal];
    addLineBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addLineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:addLineBtn];
    
    [exclamationMarkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(14);
        make.left.equalTo(self).offset(10);
        make.width.equalTo(@8);
        make.height.equalTo(@8);
    }];
    
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(exclamationMarkIcon).offset(10);
        make.right.equalTo(self).offset(-10);
    }];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hintLabel.mas_bottom).offset(10);
        make.left.equalTo(hintLabel);
        make.right.equalTo(self).offset(-10);
        make.height.equalTo(@80);
    }];
    [strNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView.mas_bottom).offset(3);
        make.right.equalTo(textView);
    }];
    [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView.mas_bottom).offset(3);
        make.left.equalTo(textView);
        make.width.equalTo(textView).multipliedBy(0.7);
    }];
    [addPresetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(warnLabel.mas_bottom).offset(15);
        make.left.equalTo(textView);
        make.height.equalTo(@30);
    }];
    [presetValuesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addPresetLabel.mas_bottom).offset(5);
        make.left.width.equalTo(addPresetLabel);
        make.height.equalTo(@44);
    }];
    [addLineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addPresetLabel);
        make.right.equalTo(strNumberLabel);
    }];
}
#pragma mark ----> add preset values
- (void)addPresetValuesToTextView:(UIButton *)sender {
    NSString *titleStr = sender.titleLabel.text;
  NSMutableAttributedString *valueStr = [self getBackBorderAndColorAuttributedStringWithBaseString:titleStr];
        NSMutableAttributedString *textStr = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
        [textStr appendAttributedString:valueStr];
        textStr.yy_lineSpacing = 15;
        textStr.yy_font = [UIFont systemFontOfSize:17];
        self.textView.attributedText = [textStr copy];
        self.textView.selectedRange = NSMakeRange(textStr.length+1, 0);
    if ([self.valueForBtns containsObject:titleStr]) {
        [self.valueForBtns removeObject:titleStr];
        [self updateInitPresetValuesLabel];
    }
}

- (NSMutableAttributedString *)getBackBorderAndColorAuttributedStringWithBaseString:(NSString *)string {
    if (!string) {
        return nil;
    }
    UIColor *tagFillColor = BORDERCOLOR;
    if ([string isEqualToString:LINEBREAKSTR]) {
        tagFillColor = LINEBREAKCOLOR;
    }
    NSMutableAttributedString *lastStr = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString *spaceStr = [[NSMutableAttributedString alloc]initWithString:@" "];
    [spaceStr yy_setLink:[NSString stringWithFormat:@"%@Space",string] range:spaceStr.yy_rangeOfAll];
    NSMutableAttributedString *valueStr = [[NSMutableAttributedString alloc]init];
    [valueStr appendAttributedString:spaceStr];
    NSMutableAttributedString *baseStr = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString *borderStr = [[NSMutableAttributedString alloc]initWithString:string];
    borderStr.yy_font = [UIFont boldSystemFontOfSize:17];
    borderStr.yy_color = [UIColor blackColor];
    YYTextBorder *border = [[YYTextBorder alloc]init];
    border.fillColor = tagFillColor;
    border.cornerRadius = 8;
    border.lineJoin = kCGLineJoinBevel;
    border.insets = UIEdgeInsetsMake(-3, -2,-3, -2);
    [borderStr yy_setTextBackgroundBorder:border range:[borderStr.string rangeOfString:string]];
    
    [baseStr appendAttributedString:borderStr];
    [baseStr appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
    
    [baseStr yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:baseStr.yy_rangeOfAll];
    [baseStr yy_setLink:string range:baseStr.yy_rangeOfAll];
    YYTextHighlight *highlight = [[YYTextHighlight alloc]init];
    [highlight setColor:[UIColor whiteColor]];
    [baseStr yy_setTextHighlight:highlight range:baseStr.yy_rangeOfAll];
    baseStr.yy_lineSpacing = 15;
    baseStr.yy_lineBreakMode = NSLineBreakByWordWrapping;
    
    [valueStr appendAttributedString:baseStr];
    [valueStr appendAttributedString:spaceStr];
    [lastStr appendAttributedString:valueStr];
    return lastStr;
}

#pragma mark -----> add lline break
- (void)addLineBreak:(UIButton *)sender {
    NSMutableAttributedString *valueStr = [self getBackBorderAndColorAuttributedStringWithBaseString:LINEBREAKSTR];
    NSMutableAttributedString *textStr = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
    [textStr appendAttributedString:valueStr];
    textStr.yy_lineSpacing = 12;
    textStr.yy_font = [UIFont systemFontOfSize:17];
    self.textView.attributedText = [textStr copy];
    self.textView.selectedRange = NSMakeRange(textStr.length+1, 0);
}

#pragma mark ------> 手势代理事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    [self.textView resignFirstResponder];
    return NO;
}
#pragma mark ------> YYTextView delegate
- (void)textViewDidChange:(YYTextView *)textView {
    [self.nowValuesForTextViews removeAllObjects];
    __block  NSString *numStr = textView.attributedText.string;
    [textView.attributedText enumerateAttribute:NSLinkAttributeName inRange:textView.attributedText.yy_rangeOfAll options:NSAttributedStringEnumerationReverse usingBlock:^(NSString *value, NSRange range, BOOL * _Nonnull stop) {
        if (value && ![value containsString:@"Space"]) {
            numStr = [numStr stringByReplacingCharactersInRange:range withString:@""];
            [self.nowValuesForTextViews addObject:value];
        }
    }];
    NSMutableSet *nowSet = [NSMutableSet setWithArray:self.nowValuesForTextViews];
    NSMutableSet *lastSet = [NSMutableSet setWithArray:self.lastValuesForTextViews];
    [lastSet minusSet:nowSet];
    if (lastSet.count > 0) {
        for (NSString *valueStr in lastSet) {
            [self.valueForBtns addObject:valueStr];
            [self updateInitPresetValuesLabel];
        }
    }
    self.lastValuesForTextViews = [NSMutableArray arrayWithArray:self.nowValuesForTextViews];
    
  BOOL isvaild = [self updateNumberLabelNumber];
    if ([self.delegate respondsToSelector:@selector(watermarkViewTextDidChange:)]) {
        [self.delegate watermarkViewTextDidChange:isvaild];
    }
}

- (void)textView:(YYTextView *)textView didTapHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect {
    NSMutableAttributedString *textStr = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
    NSRange newRange;
    if (characterRange.location+characterRange.length < textStr.length) {
          newRange = NSMakeRange(characterRange.location, characterRange.length+1);
    }else {
          newRange = NSMakeRange(characterRange.location, characterRange.length);
    }
     [textStr replaceCharactersInRange:newRange withString:@""];
    textStr.yy_font = [UIFont systemFontOfSize:17];
    self.textView.attributedText = [textStr copy];
    self.textView.selectedRange = NSMakeRange(textStr.length+1, 0);
    NSArray *currentArray = [self getTheWaterMarkValuesFromTextViewUI];
    [self setTextViewUIWithArray:currentArray];
}
- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![self isCanEditTextView]&&range.length == 0) {
        if (range.location > 0) {
           return NO;
        }
        
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
#pragma mark ----- update numberLabel
- (BOOL)updateNumberLabelNumber {
    NSMutableAttributedString *attributedStr = [self getTheServerTypeWatermarkStringFromTextViewUI];
    NSString *textStr = attributedStr.string;
    NSInteger strNum = textStr.length;
    NSString *notSpaceStr = [textStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (notSpaceStr.length < 1) {
        strNum = 0;
    }
    if (LIMITSTRNUMBER - strNum < 0) {
        self.strNumLabel.text = [NSString stringWithFormat:@"%ld/%d",LIMITSTRNUMBER-strNum,LIMITSTRNUMBER];
//        self.strNumLabel.attributedText = [self createAttributeString:[NSString stringWithFormat:@"-%ld",strNum-LIMITSTRNUMBER] subTitle:[NSString stringWithFormat:@"/%d",LIMITSTRNUMBER]];
        self.warnLabel.text = @"Watermark string exceeds 50 characters";
        return NO;
    }else {
        self.strNumLabel.text = [NSString stringWithFormat:@"%ld/%d",LIMITSTRNUMBER - strNum,LIMITSTRNUMBER];
        self.warnLabel.text = @"";
    }
    if (strNum == 0) {
        self.warnLabel.text = @"Default watermark cannot be set empty.";
        self.textView.attributedText = [[NSAttributedString alloc]initWithString:@""];
        return NO;
    }
    return YES;
}
- (BOOL)isCanEditTextView {
    NSMutableAttributedString *attributedStr = [self getTheServerTypeWatermarkStringFromTextViewUI];
    NSString *textStr = attributedStr.string;
    NSInteger strNum = textStr.length;
    NSString *notSpaceStr = [textStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (notSpaceStr.length < 1) {
        strNum = 0;
    }
    if (LIMITSTRNUMBER - strNum <= 0) {
        return NO;
    }
    return YES;
}
- (void)setTextViewUIWithArray:(NSArray*)watermarks {
        NSMutableAttributedString *textStr = [[NSMutableAttributedString alloc]init];
        if (watermarks) {
            for (NXWatermarkWord *word in watermarks) {
                NSString *UIStr = [word watermarkTextViewUIString];
                if (UIStr && ![UIStr isEqualToString:@""]) {
                    if ([word isKindOfClass:[NXNormalWatermarkWord class]]) {
                        [textStr appendAttributedString:[[NSAttributedString alloc]initWithString:UIStr]];
                    } else {
                        NSMutableAttributedString *borderStr = [self getBackBorderAndColorAuttributedStringWithBaseString:UIStr];
                        [textStr appendAttributedString:borderStr];
                    }
                }
            }
        }
    textStr.yy_lineSpacing = 12;
    textStr.yy_font = [UIFont systemFontOfSize:17];
    self.textView.attributedText = [textStr copy];
    
}
#pragma mark ----- convert textView to array
- (NSArray *)getTheWaterMarkValuesFromTextViewUI {
    NSMutableAttributedString *textStr = [self getTheServerTypeWatermarkStringFromTextViewUI];
    NSArray *array = [textStr.string parseWatermarkWords];
    return array;
}
- (NSMutableAttributedString *)getTheServerTypeWatermarkStringFromTextViewUI {
    __block  NSMutableAttributedString *textStr = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];

    [textStr enumerateAttribute:NSLinkAttributeName inRange:textStr.yy_rangeOfAll options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value) {
            NSRange newRange = NSMakeRange(range.location, range.length);
            if ([value isEqualToString:LINEBREAKSTR]) {
                [textStr replaceCharactersInRange:newRange withString:@"$(Break)"];
            } else if ([value isEqualToString:@"UserID"]){
                [textStr replaceCharactersInRange:newRange withString:@"$(User)"];
            }else if([value isEqualToString:@"Time"] || [value isEqualToString:@"Date"]){
                [textStr replaceCharactersInRange:newRange withString:[NSString stringWithFormat:@"$(%@)",value]];
            }
        }
    }];
    [textStr enumerateAttribute:NSLinkAttributeName inRange:textStr.yy_rangeOfAll options:NSAttributedStringEnumerationReverse usingBlock:^(NSString *value, NSRange range, BOOL * _Nonnull stop) {
        if ([value containsString:@"Space"]) {
            NSAttributedString *spaceStr1 = [textStr attributedSubstringFromRange:range];
            NSString *str = [spaceStr1.string stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (range.length > 1 && str.length < 1) {
                    [textStr replaceCharactersInRange:range withString:@""];
            }else{
                 NSRange spaceRange = NSMakeRange(range.location, 1);
                 NSAttributedString *spaceStr = [textStr attributedSubstringFromRange:spaceRange];
                if ([spaceStr.string isEqualToString:@" "]) {
                     [textStr replaceCharactersInRange:spaceRange withString:@""];
                }
            }
        }
    }];
    return textStr;
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    [myprojects appendAttributedString:sub1];
    return myprojects;
}
- (void)closeTheKeyBoardIfNeed{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
}
@end

