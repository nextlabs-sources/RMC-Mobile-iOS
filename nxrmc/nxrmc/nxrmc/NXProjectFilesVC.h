//
//  NXProjectFilesVC.h
//  Demo
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 Bill (Guobin) Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXProjectBaseVC.h"

#import "NXProjectFileNavViewController.h"

@interface NXProjectFilesVC : NXProjectBaseVC

@property(nonatomic, strong) NXProjectFileNavViewController *projectFileListNav;

- (void)configureNavigationRightBarButtons;

@end
