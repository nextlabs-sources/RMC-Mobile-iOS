//
//  NXLeftImageButton.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/12/20.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXLeftImageButton.h"

@implementation NXLeftImageButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat titleX = 5 + contentRect.size.height;
    CGFloat titleWidth = contentRect.size.width*0.7;
    CGFloat titleHight = contentRect.size.height;
    return CGRectMake(titleX, 0,titleWidth,titleHight);
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat imageHight = contentRect.size.height * 0.5;
    CGFloat imageWidth = imageHight;
    return CGRectMake(10,imageHight/2,imageWidth ,imageHight);
}

@end
