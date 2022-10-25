//
//  NXProjectTabBarController.h
//  Demo
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 Bill (Guobin) Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXMasterTabBarViewController.h"
#import "NXProjectModel.h"

#define kProjectTabBarDefaultSelectedIndex 1


@interface NXProjectTabBarController : UITabBarController

@property(nonatomic, weak) UITabBarController *preTabBarController;
@property(nonatomic, strong) NXProjectModel *projectModel;

- (instancetype)initWithProject:(NXProjectModel *)projectModel;

@end
