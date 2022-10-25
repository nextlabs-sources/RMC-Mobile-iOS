//
//  NXAccountInputTextField.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAccountInputTextField.h"

#define kInset 1

@interface NXAccountInputTextField()

@property(nonatomic, strong) CALayer *bottomlayer;

@end

@implementation NXAccountInputTextField

- (instancetype)init {
    if (self = [super init]) {
        _offset = 0;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _offset = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

#pragma mark
- (CGRect)borderRectForBounds:(CGRect)bounds {
    return [super borderRectForBounds:bounds];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    return CGRectMake(rect.origin.x + _offset * 2, rect.origin.y - _offset, rect.size.width, rect.size.height);;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect rect = [super placeholderRectForBounds:bounds];
    rect.origin.x = rect.origin.x + _offset;
    return  rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super editingRectForBounds:bounds];
    return CGRectMake(rect.origin.x + _offset * 2, rect.origin.y - _offset, rect.size.width, rect.size.height);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect rect = [super clearButtonRectForBounds:bounds];
    rect.origin.y = rect.origin.y - _offset;
    return rect;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    rect.origin.y = rect.origin.y - _offset;
    rect.origin.x = rect.origin.x + _offset * 2;
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super rightViewRectForBounds:bounds];
    rect.origin.y = rect.origin.y - 2;
    rect.origin.x = rect.origin.x + 2;

    return rect;
}

#pragma mark
- (CGFloat)underLineWidth {
    if (!_underLineWidth) {
        _underLineWidth = 1;
    }
    return _underLineWidth;
}

- (UIColor *)underLineColor {
    if (!_underLineColor) {
        _underLineColor = [UIColor blackColor];
    }
    return _underLineColor;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.underLineColor.CGColor);
    CGContextSetLineWidth(context, self.underLineWidth);
    
    CGContextMoveToPoint(context, CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds) - self.underLineWidth);
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - self.underLineWidth);
    CGContextStrokePath(context);
}

@end
