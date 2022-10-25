//
//  NXNormalCell.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXFileBase;
@interface NXNormalCell : UITableViewCell
@property(nonatomic, strong)NXFileBase *model;
- (void)reSet;

- (void)setRightImage:(UIImage *)rightImage forState:(UIControlState)state;
- (void)setLeftImage:(UIImage *)leftImage forState:(UIControlState)state;
- (void)setMainTitle:(NSString *)mainTitle forState:(UIControlState)state;
- (void)setSubTitle:(NSString *)subTitle forState:(UIControlState)state;

- (void)setMainTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setSubTitleColor:(UIColor *)color forState:(UIControlState)state;

@end
