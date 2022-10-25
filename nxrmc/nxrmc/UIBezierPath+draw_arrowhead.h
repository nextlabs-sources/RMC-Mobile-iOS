//
//  UIBezierPath+draw_arrowhead.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 22/11/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIBezierPath (draw_arrowhead)

+ (UIBezierPath *)draw_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength;

@end
