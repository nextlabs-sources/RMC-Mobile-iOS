//
//  NXHalfCornerButton.m
//  CoreAnimationDemo
//
//  Created by EShi on 11/11/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXHalfCornerButton.h"
#import "UIView+UIExt.h"
@interface NXHalfCornerButton()
@property(nonatomic, assign) CGFloat radius;
@property(nonatomic, assign) NXHalfCornerButtonCornerSide cornerSide;
@end

@implementation NXHalfCornerButton

- (void)drawRect:(CGRect)rect {
    [self dwMakeBottomRoundCornerWithRadius:self.radius cornerSide:self.cornerSide];

}

- (void)dwMakeBottomRoundCornerWithRadius:(CGFloat)radius cornerSide:(NXHalfCornerButtonCornerSide)cornerSide
{
    CAShapeLayer *shapeLayer = NULL;
    
    if (cornerSide == NXHalfCornerButtonCornerSideLeft) {
        CGSize size = self.frame.size;
        shapeLayer = [CAShapeLayer layer];
        [shapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, size.width, 0);
        CGPathAddLineToPoint(path, NULL, radius, 0);
        CGPathAddArc(path, NULL, radius, radius, radius, 3*M_PI/2, M_PI, YES);
        CGPathAddLineToPoint(path, NULL, 0, size.height - radius);
        CGPathAddArc(path, NULL, radius, size.height - radius, radius, M_PI, M_PI/2, YES);
        CGPathAddLineToPoint(path, NULL, size.width, size.height);
        CGPathCloseSubpath(path);
        [shapeLayer setPath:path];
        CGPathRelease(path);
        
        
        CGMutablePathRef borderPath = CGPathCreateMutable();
        CGPathMoveToPoint(borderPath, NULL, size.width, 0.5);
        CGPathAddLineToPoint(borderPath, NULL, radius, 0.5);
        CGPathAddArc(borderPath, NULL, radius, radius, radius - 0.5, 3*M_PI/2, M_PI, YES);
        CGPathAddLineToPoint(borderPath, NULL, 0.5, size.height - radius - 0.5);
        CGPathAddArc(borderPath, NULL, radius, size.height - radius, radius - 0.5, M_PI, M_PI/2, YES);
        CGPathAddLineToPoint(borderPath, NULL, size.width, size.height -0.5);

        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddPath(ctx, borderPath);
        CGContextSetStrokeColorWithColor(ctx,[UIColor blackColor].CGColor);
        CGContextStrokePath(ctx);
        CGPathRelease(borderPath);
        
    }else if(cornerSide == NXHalfCornerButtonCornerSideRight){
        
        CGSize size = self.frame.size;
        shapeLayer = [CAShapeLayer layer];
        [shapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, size.height);
        CGPathAddLineToPoint(path, NULL, size.width - radius, size.height);
        CGPathAddArc(path, NULL, size.width - radius, size.height - radius, radius, M_PI/2, 2*M_PI, YES);
        CGPathAddLineToPoint(path, NULL, size.width, radius);
        CGPathAddArc(path, NULL, size.width - radius, radius, radius, 2*M_PI, 3*M_PI/2, YES);
        CGPathAddLineToPoint(path, NULL, 0, 0);
        CGPathCloseSubpath(path);
        [shapeLayer setPath:path];
        CGPathRelease(path);
        
        
        CGMutablePathRef borderPath = CGPathCreateMutable();
        CGPathMoveToPoint(borderPath, NULL, 0, size.height - 0.5);
        CGPathAddLineToPoint(borderPath, NULL, size.width - radius, size.height - 0.5);
        CGPathAddArc(borderPath, NULL, size.width - radius, size.height - radius, radius - 0.5, M_PI/2, 2*M_PI, YES);
        CGPathAddLineToPoint(borderPath, NULL, size.width - 0.5, radius);
        CGPathAddArc(borderPath, NULL, size.width - radius, radius, radius - 0.5, 2*M_PI, 3*M_PI/2, YES);
        CGPathAddLineToPoint(borderPath, NULL, 0, 0.5);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddPath(ctx, borderPath);
        CGContextSetStrokeColorWithColor(ctx,[UIColor blackColor].CGColor);
        CGContextStrokePath(ctx);
        CGPathRelease(borderPath);
    }
    
    if (shapeLayer) {
        self.layer.mask = shapeLayer;
        //self.layer.masksToBounds = NO;
    }
}

- (instancetype)initWithFrame:(CGRect)frame cornerSide:(NXHalfCornerButtonCornerSide)cornerSide radius:(CGFloat) radius
{
    if (self = [super initWithFrame:frame]) {
        _radius = radius;
        _cornerSide = cornerSide;
    }
    return self;
}



@end
