//
//  NXPageControl.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/4/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXPageControl : UIControl

@property(nonatomic, strong) UIImage *dotImage;
@property(nonatomic, strong) UIImage *currentDotImage;

@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;

@property(nonatomic) BOOL hidesForSinglePage;

@property(nonatomic, strong) UIColor *pageIndicatorTintColor;
@property(nonatomic, strong) UIColor *currentPageIndicatorTintColor;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

@end
