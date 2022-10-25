//
//  NXPullDownButton.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 9/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXPullDownButton.h"

@implementation NXPullDownButton
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat titleX = contentRect.size.width*0.15;
    CGFloat titleWidth = contentRect.size.width*0.7;
    CGFloat titleHight = contentRect.size.height;
    return CGRectMake(titleX, 0,titleWidth,titleHight);
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat imageX = contentRect.size.width*0.9+3;
    CGFloat imageY = contentRect.size.height/2-5;
//    CGFloat titleWidth = contentRect.size.width*0.3;
//    CGFloat titleHight = contentRect.size.height*0.3;
    return CGRectMake(imageX,imageY,12 ,10);
}

@end
