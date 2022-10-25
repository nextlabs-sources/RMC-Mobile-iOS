//
//  NXTextView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXTextView.h"

@implementation NXTextView

- (instancetype)init {
    if (self = [super init]) {
        [self common];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self common];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self common];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!self.text.length) {
        NSDictionary *dictionary = @{NSFontAttributeName: _placeholderFont, NSForegroundColorAttributeName: _placeholderColor};
        [self.placeholder drawInRect:CGRectMake(4, 7, self.bounds.size.width, self.bounds.size.height) withAttributes:dictionary];
    }
}
#pragma mark - setter
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

#pragma mark
- (void)textChange:(NSNotification *)notification {
    [self setNeedsDisplay];
}

#pragma mark
- (void)common {
    _placeholderFont = [UIFont systemFontOfSize:13];
    _placeholderColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
}

@end
