//
//  NXProcessPercentView.h
//  NXGradientProcessView
//
//  Created by helpdesk on 12/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NXProcessItemModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) double percentAge;
@property(nonatomic, strong) NSString *usageStr;
@property(nonatomic, strong) NSArray *percentAges;
@end
@interface NXProcessPercentView : UIView
- (instancetype)initWithFrame:(CGRect)frame;
- (void)makeProcessViewTypeWithItems:(NSDictionary *)dic;
- (void)makeProcessViewAnimatedWithDuration:(CGFloat)animatedTime;
@end
