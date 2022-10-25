//
//  NXCustomTabBarView.h
//  nxrmc
//
//  Created by helpdesk on 9/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXCustomTabBarView : UIView
@property(nonatomic, strong)UIView *slideView;
@property(nonatomic, strong)UIImageView *selectImageView;
@property(nonatomic, assign)NSInteger currentIndex;
@property(nonatomic, assign)id delegate;
-(instancetype)initWithsubViewsPictures:(NSArray *)normalImages andSelectImages:(NSArray *)selectImages andButtonTitles:(NSArray*)titlearray;
- (void)amountClickTabBarItem:(NSInteger)integer;
@end
@protocol NXCustomTabBarViewDelegate <NSObject>

-(void)NXCustomTabBarView:(NXCustomTabBarView *)tabBarView selectMenuButtonClicked:(UIButton*)sender;
@end
