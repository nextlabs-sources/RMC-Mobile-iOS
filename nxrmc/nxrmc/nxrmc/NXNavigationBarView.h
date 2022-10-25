//
//  NXNavigationBarView.h
//  AlphaVC
//
//  Created by helpdesk on 7/11/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXNavigationBarView : UIView
typedef NS_ENUM(NSInteger,NXNavigationBarViewStyle ) {
    NXNavigationBarViewStyleDefault = 0,
    NXNavigationBarViewStyleSelected
};
@property (nonatomic,assign) id delegate;
@property (nonatomic,strong) UIButton *leftBarBtn;
@property (nonatomic,strong) UILabel *leftBarLabel;
@property (nonatomic,strong) UIImageView *rightBarImageView;
@property (nonatomic,strong) UIButton *rightBarBtn;
- (void)setStyle:(NXNavigationBarViewStyle)style;

@end
@protocol NXNavigationBarViewDelegate <NSObject>

@optional
- (void)leftBarBtnClicked:(UIButton*)sender ;
- (void)rightBarBtnClicked:(UIButton*)sender ;
@end