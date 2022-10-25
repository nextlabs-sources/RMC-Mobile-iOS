//
//  NXCommentInputView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXCommentInputView.h"
#import "NXTextView.h"

#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXRMCDef.h"

@interface NXCommentInputView()<UITextViewDelegate>

@property(nonatomic, strong) UILabel *promptLabel;
@property(nonatomic, strong) NXTextView *textView;

@property(nonatomic, strong) UILabel *maxCharactersLabel;
@property(nonatomic, strong) UILabel *warningLabel;

@property(nonatomic, strong) UIView *backView;

@end

@implementation NXCommentInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        self.maxCharacters = 250;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.backView addShadow:UIViewShadowPositionTop | UIViewShadowPositionLeft | UIViewShadowPositionBottom | UIViewShadowPositionRight color:[UIColor darkGrayColor] width:0.5 Opacity:0.5];
    [self.backView cornerRadian:5];
    [self.backView borderWidth:0.3];
    [self.backView borderColor:[UIColor lightGrayColor]];
}

- (void)setMaxCharacters:(NSInteger)maxCharacters {
    _maxCharacters = maxCharacters;
    if (self.textView.text.length > maxCharacters) {
        self.textView.text = [self.textView.text substringToIndex:maxCharacters-1];
    }
    if (maxCharacters < 0) {
        self.maxCharactersLabel.hidden = YES;
    }else {
        self.maxCharactersLabel.hidden = NO;
    }
    self.maxCharactersLabel.text = [NSString stringWithFormat:@"%ld/%ld", maxCharacters-self.textView.text.length, maxCharacters];
    self.warningLabel.text = [NSString stringWithFormat:NSLocalizedString(@"UI_COMMENT_MESSAGE_EXCEED", NULL), maxCharacters];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"%s", __FUNCTION__);
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(commentInputViewDidEndEditing:)]) {
        [self.delegate commentInputViewDidEndEditing:self];
    }
    self.maxCharactersLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.maxCharacters-self.textView.text.length, self.maxCharacters];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([self.delegate respondsToSelector:@selector(commentInputView:shouldChangeTextInRange:replacementText:)]) {
        [self.delegate commentInputView:self shouldChangeTextInRange:range replacementText:newString];
    }
    //return key
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return YES;
//    }
    
    if (newString.length > self.maxCharacters) {
        self.warningLabel.hidden = NO;
        textView.text = [newString substringToIndex:self.maxCharacters];
        self.maxCharactersLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.maxCharacters-self.textView.text.length, self.maxCharacters];
        return NO;
    } else {
        self.warningLabel.hidden = YES;
    }
    return YES;
}

#pragma mark
- (void)commonInit {
    self.clipsToBounds = YES;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kMargin/4);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin/2);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin/2);
                make.height.equalTo(@30);
            }];
        }
    }
    else{
        [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin/4);
            make.left.equalTo(self).offset(kMargin/2);
            make.right.equalTo(self).offset(-kMargin/2);
            make.height.equalTo(@30);
        }];
    }
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.promptLabel.mas_bottom).offset(kMargin);
        make.left.and.right.equalTo(self.promptLabel);
        make.bottom.equalTo(self.maxCharactersLabel.mas_top).offset(-4);
    }];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textView).insets(UIEdgeInsetsMake(-kMargin/4, -kMargin/4, -kMargin/4, -kMargin/4));
    }];
    
    [self.maxCharactersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.promptLabel);
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.bottom.equalTo(self).offset(-1);
    }];
    
    [self.warningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.maxCharactersLabel);
        make.left.equalTo(self.promptLabel);
        make.right.equalTo(self.maxCharactersLabel.mas_left).offset(-4);
    }];
    [self sendSubviewToBack:self.backView];
#if 0
    self.textView.backgroundColor = [UIColor orangeColor];
    self.promptLabel.backgroundColor = [UIColor magentaColor];
    self.warningLabel.backgroundColor = [UIColor blueColor];
    self.maxCharactersLabel.backgroundColor = [UIColor greenColor];
    self.backView.backgroundColor = [UIColor magentaColor];
#endif
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        UILabel *promptLabel = [[UILabel alloc] init];
        [self addSubview:promptLabel];
        promptLabel.font = [UIFont systemFontOfSize:14];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"UI_COMMENT_MESSAGE", NULL) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14], NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        [attri appendAttributedString:[[NSAttributedString alloc]initWithString:NSLocalizedString(@"UI_COMMENT_OPTIONAL", NULL) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor lightGrayColor]}]];
        
        promptLabel.attributedText = attri;
        _promptLabel = promptLabel;
    }
    return _promptLabel;
}

- (NXTextView *)textView {
    if (!_textView) {
        NXTextView *textView = [[NXTextView alloc] init];
        [self addSubview:textView];
        textView.font = [UIFont systemFontOfSize:13];
        textView.placeholder = NSLocalizedString(@"UI_COMMENT_PLACEHOLDER", NULL);
        textView.accessibilityValue = @"EMAIL_COMMENT_TEXT_VIEW";
        textView.delegate = self;
        textView.tintColor = [UIColor lightGrayColor];
        _textView = textView;
    }
    return _textView;
}

- (UILabel *)maxCharactersLabel {
    if (!_maxCharactersLabel) {
        UILabel *maxCharactersLabel = [[UILabel alloc] init];
        [self addSubview:maxCharactersLabel];
        
        maxCharactersLabel.textColor = [UIColor darkGrayColor];
        maxCharactersLabel.textAlignment = NSTextAlignmentRight;
        maxCharactersLabel.font = [UIFont systemFontOfSize:14];
        
        _maxCharactersLabel = maxCharactersLabel;
    }
    return _maxCharactersLabel;
}

- (UILabel *)warningLabel {
    if (!_warningLabel) {
        UILabel *warningLabel = [[UILabel alloc] init];
        [self addSubview:warningLabel];
        warningLabel.numberOfLines = 0;
        warningLabel.textColor = [UIColor redColor];
        warningLabel.textAlignment = NSTextAlignmentLeft;
        warningLabel.font = [UIFont systemFontOfSize:14];
        warningLabel.hidden = YES;
        
        _warningLabel = warningLabel;
    }
    return _warningLabel;
}

- (UIView *)backView {
    if (!_backView) {
        UIView *backView = [[UIView alloc] init];
        [self addSubview:backView];
        _backView = backView;
    }
    return _backView;
}

@end
