//
//  NXOverlayView.m
//  nxrmc
//
//  Created by nextlabs on 7/20/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "NXOverlayView.h"
#import "NXCommonUtils.h"

#define HORIZONTAL_SPACE_PIXEL          50  // horizontal space between two label, 10 pixel.
#define VERTICAL_DUPLICATE_FONTHEIGHT   80   // vertial space between two label, 10 pixel

#define  DEFAULTROTATIONANGLE  M_PI_4   //default rotatioin angle.

@interface NXOverlayView()
{
    NSString *_displayText;
    CGFloat _transparency;  // 0.0 ~ 1.0
    UIFont *_font;          // contents fontSize and FontName.
    UIColor *_textColor;
    CGFloat _rotation;
    CGSize _labelSize;
    BOOL _clockRotation;
}
@property(nonatomic, strong)CALayer *overlayView;
@end

@implementation NXOverlayView

- (instancetype)initWithFrame:(CGRect)frame Obligation:(NXOverlayTextInfo *)overlaytextInfo{
    if (self = [super initWithFrame:frame]) {
        _rotation = DEFAULTROTATIONANGLE;
        [self initProperty:overlaytextInfo];
        self.overLayInfo = overlaytextInfo;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _rotation = DEFAULTROTATIONANGLE;
        NXOverlayTextInfo *info = [[NXOverlayTextInfo alloc] init];
        [self initProperty:info];
    }
    return self;
}

#pragma mark

- (void)initProperty:(NXOverlayTextInfo *) obligation {
    _displayText = obligation.text;
    _transparency = 1 - [obligation.transparency floatValue]/100;
    _font = obligation.font;
    _textColor = obligation.textColor;
    _clockRotation = obligation.isclockwiserotation;
    _labelSize = [self calculateLabelSize:_displayText];
}

- (void)drawRect:(CGRect)rect {
    if (self.overlayView) {
        return;
    }
    
    CGSize displaySize = rect.size;
    CGFloat maxLine = MAX(displaySize.height, displaySize.width);
    maxLine = maxLine / cosf(_rotation);
    CALayer *contentLayer = [CALayer layer];
    contentLayer.frame = CGRectMake(-maxLine, -maxLine, 3*maxLine, 3*maxLine);
    contentLayer.opaque = NO;
    
    [self.layer addSublayer:contentLayer];
    self.overlayView = contentLayer;

    for (CGFloat x = 0; x < 3*maxLine; x += _labelSize.width + HORIZONTAL_SPACE_PIXEL) {
        for (CGFloat y = 0; y < 3*maxLine; y += _labelSize.height + VERTICAL_DUPLICATE_FONTHEIGHT) {
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.frame = CGRectMake(x, y, _labelSize.width, _labelSize.height);
            CFStringRef fontName = (__bridge CFStringRef)_font.fontName;
            textLayer.font = CGFontCreateWithFontName(fontName);
            textLayer.fontSize = _font.pointSize;
            textLayer.alignmentMode = kCAAlignmentCenter;
            textLayer.wrapped = YES;
            textLayer.opaque = NO;
            textLayer.foregroundColor = _textColor.CGColor;
            textLayer.string = _displayText;
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            textLayer.opacity = _transparency;
            [contentLayer addSublayer:textLayer];
        }
    }
    if (_clockRotation) {
        contentLayer.affineTransform = CGAffineTransformMakeRotation(_rotation);
    }else {
        contentLayer.affineTransform = CGAffineTransformMakeRotation(-_rotation);
    }
    
}

- (CGSize)calculateLabelSize:(NSString *)displayText {
    return [displayText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_font} context:nil].size;
}

@end
