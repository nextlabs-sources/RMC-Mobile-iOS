//
//  NXDotView.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXDotView : UIView

@property(nonatomic, strong) UIColor *activeColor;
@property(nonatomic, strong) UIColor *deactiveColor;

- (void)changeActiveState:(BOOL)active;

@end
