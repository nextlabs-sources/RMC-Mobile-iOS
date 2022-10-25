//
//  NXActionSheetCommonViewController.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 02/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXActionSheetItem.h"
#import "NXCustomActionSheetViewController.h"

@interface NXActionSheetCommonViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NXCustomActionSheetWindow *actionSheetWindow;

- (void)addItem:(NXActionSheetItem *)item;

@end
