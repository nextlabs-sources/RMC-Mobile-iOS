//
//  UIImage+Cutting.m
//  nxrmc
//
//  Created by nextlabs on 8/11/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "UIImage+Cutting.h"

@implementation UIImage (Cutting)
- (UIImage *)imageCuttingToSize:(CGSize)size {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(0, 0, size.width, size.height));
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)imageScaleToSize:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);//thiswillcrop
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *)base64StrWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    return  [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (UIImage *)imageWithBase64Str:(NSString *)encodedImageStr {
    if (!encodedImageStr) {
        return nil;
    }
    NSData *decodedImageData = [[NSData alloc]initWithBase64EncodedString:encodedImageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:decodedImageData];
}

+ (NSData *)zipImage:(UIImage *)image size:(CGFloat)fileSize {
    if (!image) {
        return nil;
    }
    
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    
    while ([compressedData length] > fileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    
    return compressedData;
}

+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)width {
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth/heightScale, height)];
    } else {
        [image drawInRect:CGRectMake(0, 0, width, imageHeight/widthScale)];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
