
//
//  UIView+UIExt.m
//  CoreAnimationDemo
//
//  Created by EShi on 11/3/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "UIView+UIExt.h"
#import <objc/runtime.h>

#define DEFAULT_SHADOW_WIDTH 3
#define DEFAULT_SHADOW_OPACITY 0.2f

@implementation UIView (UIExt)
- (void) cornerRadian:(CGFloat) radian
{
    [self cornerRadian:radian clipsToBounds:YES];
}

- (void)cornerRadian:(CGFloat)radian clipsToBounds:(BOOL) shouldClip
{
    [self.layer setCornerRadius:radian];
    self.clipsToBounds = shouldClip;
}

- (void)borderWidth:(CGFloat) width
{
    [self.layer setBorderWidth:width];
}

- (void)borderColor:(UIColor *) color
{
    [self.layer setBorderColor:color.CGColor];
}

- (void)addShadow:(UIViewShadowPosition)position color:(UIColor *) color
{
    [self addShadow:position color:color width:DEFAULT_SHADOW_WIDTH Opacity:DEFAULT_SHADOW_OPACITY];
}

- (void)addShadow:(UIViewShadowPosition)position color:(UIColor *) color width:(CGFloat)width Opacity:(float) opacity
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = 1.0f;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    
    if (position & UIViewShadowPositionTop)     [self addShadowTopPath:shadowPath pathWidth:width];
    if (position & UIViewShadowPositionBottom)  [self addShadowBottomPath:shadowPath pathWidth:width];
    if (position & UIViewShadowPositionLeft)    [self addShadowLeftPath:shadowPath pathWidth:width];
    if (position & UIViewShadowPositionRight)   [self addShadowRightPath:shadowPath pathWidth:width];
    
    [self drawShadow:shadowPath];
}


- (UIBezierPath *)addShadowTopPath:(UIBezierPath *)path pathWidth:(CGFloat)pathWidth

{
    CGPoint p1 = CGPointMake(self.bounds.origin.x, self.bounds.origin.y - pathWidth);
    CGPoint p2 = CGPointMake(self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y - pathWidth);
    CGPoint p3 = CGPointMake(self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y);
    CGPoint p4 = CGPointMake(self.bounds.origin.x, self.bounds.origin.y);
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    
    return path;
}

- (UIBezierPath *)addShadowBottomPath:(UIBezierPath *)path pathWidth:(CGFloat)pathWidth
{
    CGPoint p1 = CGPointMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height);
    CGPoint p2 = CGPointMake(self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + self.bounds.size.height);
    CGPoint p3 = CGPointMake(self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + self.bounds.size.height + pathWidth);
    CGPoint p4 = CGPointMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height + pathWidth);
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    return path;
    
}

- (UIBezierPath *)addShadowLeftPath:(UIBezierPath *)path pathWidth:(CGFloat)pathWidth
{
    CGPoint p1 = CGPointMake(self.bounds.origin.x - pathWidth, self.bounds.origin.y);
    CGPoint p2 = CGPointMake(self.bounds.origin.x, self.bounds.origin.y);
    CGPoint p3 = CGPointMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height);
    CGPoint p4 = CGPointMake(self.bounds.origin.x - pathWidth, self.bounds.origin.y + self.bounds.size.height);
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    return path;
    
}

- (UIBezierPath *)addShadowRightPath:(UIBezierPath *)path pathWidth:(CGFloat)pathWidth
{
    CGPoint p1 = CGPointMake(self.bounds.size.width + self.bounds.origin.x, self.bounds.origin.y);
    CGPoint p2 = CGPointMake(self.bounds.size.width + self.bounds.origin.x + pathWidth, self.bounds.origin.y);
    CGPoint p3 = CGPointMake(self.bounds.size.width + self.bounds.origin.x + pathWidth, self.bounds.origin.y + self.bounds.size.height);
    CGPoint p4 = CGPointMake(self.bounds.size.width + self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height);
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    return path;
}
+ (Class)layerClass {
    return [CAGradientLayer class];
}

+ (UIView *)az_gradientViewWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    UIView *view = [[self alloc] init];
    [view az_setGradientBackgroundWithColors:colors locations:locations startPoint:startPoint endPoint:endPoint];
    return view;
}

- (void)az_setGradientBackgroundWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    NSMutableArray *colorsM = [NSMutableArray array];
    for (UIColor *color in colors) {
        [colorsM addObject:(__bridge id)color.CGColor];
    }
    self.az_colors = [colorsM copy];
    self.az_locations = locations;
    self.az_startPoint = startPoint;
    self.az_endPoint = endPoint;
}

#pragma mark- Getter&Setter

- (NSArray *)az_colors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAz_colors:(NSArray *)colors {
    objc_setAssociatedObject(self, @selector(az_colors), colors, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setColors:self.az_colors];
    }
}

- (NSArray<NSNumber *> *)az_locations {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAz_locations:(NSArray<NSNumber *> *)locations {
    objc_setAssociatedObject(self, @selector(az_locations), locations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setLocations:self.az_locations];
    }
}

- (CGPoint)az_startPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setAz_startPoint:(CGPoint)startPoint {
    objc_setAssociatedObject(self, @selector(az_startPoint), [NSValue valueWithCGPoint:startPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setStartPoint:self.az_startPoint];
    }
}

- (CGPoint)az_endPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setAz_endPoint:(CGPoint)endPoint {
    objc_setAssociatedObject(self, @selector(az_endPoint), [NSValue valueWithCGPoint:endPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setEndPoint:self.az_endPoint];
    }
}


- (void)drawShadow:(UIBezierPath *)path
{
    self.layer.shadowPath = path.CGPath;
}
@end
