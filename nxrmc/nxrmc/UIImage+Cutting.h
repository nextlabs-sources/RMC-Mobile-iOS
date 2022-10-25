//
//  UIImage+Cutting.h
//  nxrmc
//
//  Created by nextlabs on 8/11/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Cutting)
- (UIImage *)imageCuttingToSize:(CGSize)size;
- (UIImage *)imageScaleToSize:(CGSize)size;
+ (UIImage *)imageWithBase64Str:(NSString *)encodedImageStr;
+ (NSString *)base64StrWithImage:(UIImage *)image;
+ (NSData *)zipImage:(UIImage *)image size:(CGFloat)fileSize;
+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)width;

@end
