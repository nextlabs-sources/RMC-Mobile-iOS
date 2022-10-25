//
//  NXCarouselView.h
//  nxrmc
//
//  Created by nextlabs on 11/3/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXCarouselView;

//@protocol NXCarouseViewDelegate <NSObject>
//
//- (void)carouseView:(NXCarouselView *)carouseView didClickPage:(UIView *)view atIndex:(NSInteger)index;
//
//@end

@protocol NXCarouseViewDataSource <NSObject>

- (NSInteger)numberofPagecarouseView:(NXCarouselView *)carouseView;
- (UIView *)pageAtIndex:(NSInteger)index carouseView:(NXCarouselView *)carouseView;

@optional
- (UIImage *)selectedImageforPageControlInCarouselView:(NXCarouselView *)carouseView;
- (UIImage *)defaultImageforPageControlInCarouselView:(NXCarouselView *)carouseView;


@end

@interface NXCarouselView : UIView

@property(nonatomic, weak) id<NXCarouseViewDataSource> dataSource;
@property(nonatomic) BOOL showPageControl;

- (void)reloadData;

@end
