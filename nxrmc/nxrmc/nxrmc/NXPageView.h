//
//  NXPageView.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXPageControl.h"

@interface NXPageView : UIView

@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UILabel *mainTextLabel;
@property(nonatomic, weak) UILabel *detailTextLabel;
@property(nonatomic, weak) NXPageControl *pageControl;

@end
