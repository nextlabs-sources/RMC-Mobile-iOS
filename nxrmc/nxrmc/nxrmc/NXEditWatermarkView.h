//
//  NXEditWatermarkView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/11/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXEditWatermarkView;

typedef void (^onOkClickHandle)(NSArray *changedWatermarks);
@interface NXEditWatermarkView : UIView
@property (nonatomic, copy) onOkClickHandle onOkClickHandle;
@property (nonatomic, strong) NSArray *waterMarks;
- (instancetype)initWithWatermarks:(NSArray *)watermarks InviteHander:(onOkClickHandle)hander;
- (void)show;
@end
