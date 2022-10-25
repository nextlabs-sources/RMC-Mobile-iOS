//
//  UIImage+ColorToImage.m
//
//
//  Created by tim on 16/5/17.
//  Copyright © 2016年 tim. All rights reserved.
//

#import "UIImage+ColorToImage.h"

@implementation UIImage (ColorToImage)
+ (UIImage *)imageWithColor:(UIColor*) color {
    CGRect rect =CGRectMake(0, 0, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithSize:(CGSize)size colors:(NSArray*)colors gradientType:(GradientType)gradientType {
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) {
        [array addObject:(__bridge id)color.CGColor];
    }
    
    CGPoint start, end;
    switch (gradientType) {
        case GradientTypeLeftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0);
            break;
        case GradientTypeTopToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case GradientTypeUpLeftToLowRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case GradientTypeUpRightToLowLeft:
            start = CGPointMake(size.width, 0);
            end = CGPointMake(0.0, size.height);
            break;
        default:
            break;
    }
    
    CGFloat *colorLocations = (CGFloat *)malloc(sizeof(CGFloat) * colors.count);
    colorLocations[0] = 0;
    for (int i = 1; i < colors.count; ++i) {
        colorLocations[i] = 1.0/(CGFloat)(colors.count - 1) + colorLocations[i-1];
    }
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (__bridge CFArrayRef)array, colorLocations);
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    free(colorLocations);
    UIGraphicsEndImageContext();
    
    return image;
}

@end
