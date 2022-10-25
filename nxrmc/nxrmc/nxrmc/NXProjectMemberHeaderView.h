//
//  NXProjectMemberHeaderView.h
//  nxrmc
//
//  Created by helpdesk on 23/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXProjectMemberHeaderView : UIView
- (instancetype)initWithFrame:(CGRect)frame withItems:(NSArray *)items andMaxCount:(NSInteger)maxCount;
@property(nonatomic, strong)NSArray *items;
@property(nonatomic, assign)NSInteger maxCount;
@property(nonatomic, assign)CGFloat sizeWidth;
@end
