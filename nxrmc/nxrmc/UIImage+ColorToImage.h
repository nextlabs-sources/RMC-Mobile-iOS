//
//  UIImage+ColorToImage.h
//  
//
//  Created by tim on 16/5/17.
//  Copyright © 2016年 tim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GradientType) {
    GradientTypeTopToBottom = 0,
    GradientTypeLeftToRight = 1,
    GradientTypeUpLeftToLowRight = 2,
    GradientTypeUpRightToLowLeft = 3
};

@interface UIImage (ColorToImage)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha;

+ (UIImage *)imageWithSize:(CGSize)size colors:(NSArray*)colors gradientType:(GradientType)gradientType;

@end
