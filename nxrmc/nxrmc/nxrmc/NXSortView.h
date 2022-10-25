//
//  NXSortView.h
//  nxrmc
//
//  Created by nextlabs on 2/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXFileSort.h"

#import "NXSortByButtonRoundView.h"

typedef void(^ClickBlock)(id sender);

@interface NXCircleButton : UIButton

@property(nonatomic, strong) UIColor *selectedBackgroundColor;
@property(nonatomic, strong) UIColor *normalBackgroundColor;

@property(nonatomic, copy) ClickBlock clickBlock;

- (instancetype)initWithRadius:(CGFloat)radius shadowOffset:(CGSize)shadowOffset shadowRadius:(CGFloat)shadowRadius;

@end

@interface NXSortItemView : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) NXCircleButton *itemButton;

@property(nonatomic, assign, getter=isSelected) BOOL selected;
@property(nonatomic, assign) NXSortOption sortOption;

@property(nonatomic, strong) ClickBlock clickBlock;

- (instancetype)initWithSortOption:(NXSortOption)sortOption;
- (void)removeItemButton;
@end

@class NXSortView;
@protocol NXSortViewDelegate <NSObject>

@optional
- (void)sortView:(NXSortView *)sortView didSelectedSortOption:(NXSortOption)option;

@end

@interface NXSortView : UIView

@property(nonatomic, strong) NSArray<NSNumber *> *sortOptions;
@property(nonatomic, assign) NXSortOption currentOption;

@property(nonatomic, weak) id<NXSortViewDelegate> delegate;

- (instancetype)initWithSortOptions:(NSArray *)options selectedOption:(NXSortOption)option;

@end
