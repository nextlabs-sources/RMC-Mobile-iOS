//
//  NXActionSheetNavigationViewController.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 02/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXCustomActionSheetViewController.h"

@interface NXActionSheetNavigationViewController : UINavigationController

@property CGFloat tableviewItemsCount;

@property (nonatomic, weak) NXCustomActionSheetWindow *actionSheetWindow;

@end
