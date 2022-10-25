//
//  NXHalfCornerButton.h
//  CoreAnimationDemo
//
//  Created by EShi on 11/11/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NXHalfCornerButtonCornerSide)
{
    NXHalfCornerButtonCornerSideLeft = 1,
    NXHalfCornerButtonCornerSideRight,
};

@interface NXHalfCornerButton : UIButton
- (instancetype)initWithFrame:(CGRect)frame cornerSide:(NXHalfCornerButtonCornerSide)cornerSide radius:(CGFloat) radius;
@end
