//
//  NXWorkSpaceTabBarViewController.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/10/15.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXMasterTabBarViewController.h"

#define KWorkSpaceTabBarDefaultSelectedIndex 1
@interface NXWorkSpaceTabBarViewController : UITabBarController
@property(nonatomic, weak) NXMasterTabBarViewController *preTabBarController;
@end


