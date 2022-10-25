//
//  NXCustomActionSheetViewController.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 28/04/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXActionSheetItem.h"

@interface NXCustomActionSheetViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *currentItems;

- (void)show;
- (void)addItem:(NXActionSheetItem *)item;

@end
typedef NS_ENUM(NSInteger, NXActionSheetWindowBackgroundStyle) {
    NXActionSheetWindowBackgroundStyleSolid = 0,    // 平面的
    NXActionSheetWindowBackgroundStyleGradient      // 聚光的
};

@interface NXCustomActionSheetWindow : UIWindow

/** ActionSheet Window background style */
@property (nonatomic, assign) NXActionSheetWindowBackgroundStyle style;

- (void)dismiss;


@end
