//
//  NXFilterViewController.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 8/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXFilterViewController;
@protocol NXFilterViewControllerDelegate <NSObject>

- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType;

@end

@interface NXFilterViewController : UIViewController
@property(nonatomic, strong)NSArray *segmentItems;
@property(nonatomic, assign) id  delegate;
@property(nonatomic, assign) NSInteger selectedSortType;
@property(nonatomic, assign) BOOL isSupportRepo;
@end


