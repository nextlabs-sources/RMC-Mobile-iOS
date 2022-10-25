//
//  NXPageSelectMenuView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 4/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXPageSelectMenuView : UIView
@property(nonatomic, assign)NSInteger currentIndex;
@property(nonatomic, assign)id delegate;
@property(nonatomic, assign)CGRect currentFrame;
- (instancetype)initWithFrame:(CGRect)frame andItems:(NSArray *)items;
- (void)commonInitWithItems:(NSArray *)itemsArray;
- (void)setSelectIndex:(NSInteger)index;
- (void)setUnableForButtons:(NSArray *)itemArray andDefaultSelect:(NSInteger)defaultIndex;
- (void)cancelUnableForButtions:(NSArray *)itemArray;
@end
@protocol NXPageSelectMenuViewDelegate <NSObject>

-(void)withNXPageSelectMenuView:(NXPageSelectMenuView *)selectMenuView selectMenuButtonClicked:(UIButton*)sender;

@end
