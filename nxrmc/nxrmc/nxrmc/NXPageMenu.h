//
//  NXPageMenu.h
//  nxrmc
//
//  Created by nextlabs on 1/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXPageMenu;
@protocol NXPageMenuDelegate <NSObject>

- (void)pageMenu:(NXPageMenu *)pageMenu didMoveToPage:(UIViewController *)viewController index:(NSInteger)index;

@end

@interface NXPageMenuSetting : NSObject

@property(nonatomic, strong) UIColor *menuTinColor;
@property(nonatomic, strong) UIColor *menuSelectedTinColor;
@property(nonatomic, assign) CGFloat menuHeight;
@property(nonatomic, strong) UIColor *menuBackgroundColor;

@property(nonatomic, strong) UIColor *viewBackgroundColor;
//TO DO ADD some other property.

@end

@interface NXPageMenu : UIViewController

@property(nonatomic, strong, readonly) NSArray *controllers;
@property(nonatomic, strong, readonly) NSArray *menuItems;

@property(nonatomic, assign) NSInteger currentPageIndex;

@property(nonatomic, weak) id<NXPageMenuDelegate>delegate;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers setting:(NXPageMenuSetting *)setting;

@end
